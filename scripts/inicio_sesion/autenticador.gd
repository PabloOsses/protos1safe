extends Node

# URL del endpoint de login
const Config = preload("res://config.gd")
var LOGIN_URL = Config.API_BASE_URL


signal login_success(id_usuario: int, message: String)
signal login_failed(error_message: String)

func login_user(email: String, password: String) -> void:
	# Hashear la contraseña del mismo modo que en el registro
	var hashed_password = hash_password_client_side(password)
	
	# Crear el cuerpo de la petición con la contraseña hasheada
	var body = {
		"email": email,
		"contrasena": hashed_password  # Usamos la versión hasheada
	}
	
	# Convertir el cuerpo a JSON
	var json_body = JSON.stringify(body)
	
	# Crear la petición HTTP
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_login_request_completed.bind(http_request))
	
	# Configurar los headers
	var headers = ["Content-Type: application/json"]
	
	# Hacer la petición POST
	var error = http_request.request(LOGIN_URL, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		login_failed.emit("Error al crear la petición HTTP")
		http_request.queue_free()

# La misma función de hashing que usas en el registro
func hash_password_client_side(password: String) -> String:
	# Usamos el hash SHA-256 que viene con Godot
	var sha256 = HashingContext.new()
	sha256.start(HashingContext.HASH_SHA256)
	sha256.update(password.to_utf8_buffer())
	var hash_bytes = sha256.finish()
	
	# Convertimos a string hexadecimal
	return hash_bytes.hex_encode()

func _on_login_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	# Eliminar el HTTPRequest cuando termine
	http_request.queue_free()
	
	# Verificar si hubo error en la conexión
	if result != HTTPRequest.RESULT_SUCCESS:
		print("AQUI AQUI AQUI")
		login_failed.emit("Error de conexión con el servidor")
		return
	
	# Verificar el código de respuesta
	if response_code == 200:
		# Login exitoso
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response = json.get_data()
			login_success.emit(response["id_usuario"], response["message"])
		else:
			login_failed.emit("Error al procesar la respuesta del servidor")
	else:
		# Error en el login
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response = json.get_data()
			login_failed.emit(response["error"])
		else:
			login_failed.emit("Error desconocido (código %d)" % response_code)
