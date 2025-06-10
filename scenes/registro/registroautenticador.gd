extends Node

const API_URL = "https://mibackend-4urp.onrender.com"  # Asegúrate de que esta URL es correcta

signal registration_successful(user_data: Dictionary)
signal registration_failed(error_message: String)

func register_user(username: String, email: String, password: String, hash_password: bool = true) -> Dictionary:
	var endpoint = "/auth/register"
	var url = API_URL + endpoint
	
	var request_data = {
		"nombre_usuario": username,
		"email": email,
		"contrasena": password
	}
	
	if hash_password:
		request_data["contrasena"] = await hash_password_client_side(password)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Variable para almacenar el resultado
	var response_data: Dictionary = {"success": false, "error": "Timeout"}
	
	http_request.request_completed.connect(
		func(result: int, code: int, headers: PackedStringArray, body: PackedByteArray):
			var response = _process_request_response(result, code, headers, body)
			response_data = response
			http_request.queue_free()
	)
	
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(request_data))
	
	if error != OK:
		http_request.queue_free()
		return {"success": false, "error": "Error al crear la petición HTTP"}
	
	# Esperamos con timeout por si falla la conexión
	var timeout = 0
	while response_data.has("error") and response_data["error"] == "Timeout" and timeout < 30: # 0.5 segundos
		timeout += 1
		await get_tree().create_timer(0.1).timeout
	
	return response_data

func _process_request_response(result: int, code: int, headers: PackedStringArray, body: PackedByteArray) -> Dictionary:
	var response_body = body.get_string_from_utf8()
	var json = JSON.new()
	var error = json.parse(response_body)
	
	if code == HTTPClient.RESPONSE_CREATED:  # 201
		if error == OK:
			var data = json.get_data()
			emit_signal("registration_successful", data)
			return {"success": true, "data": data}
		else:
			var error_msg = "Error al procesar respuesta"
			emit_signal("registration_failed", error_msg)
			return {"success": false, "error": error_msg}
	else:
		var error_message = "Error desconocido"
		if error == OK:
			var error_data = json.get_data()
			error_message = error_data.get("error", error_data.get("message", "Error desconocido"))
		emit_signal("registration_failed", error_message)
		return {"success": false, "error": "Error %d: %s" % [code, error_message]}

func hash_password_client_side(password: String) -> String:
	var sha256 = HashingContext.new()
	sha256.start(HashingContext.HASH_SHA256)
	sha256.update(password.to_utf8_buffer())
	var hash_bytes = sha256.finish()
	return hash_bytes.hex_encode()
