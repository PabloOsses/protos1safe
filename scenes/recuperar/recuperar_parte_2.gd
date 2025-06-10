extends Control

@onready var contrasenia = $contrasenia
@onready var repetir_contra = $repetir_contrasenia
@onready var pantalla_carga = $carga_buena
@onready var http_request = HTTPRequest.new()
@onready var mensaje_error = $mensaje_error  # Asume que tienes un Label para errores

# Variable para almacenar el email del usuario
var user_email=Globales.usuario_email

func _ready() -> void:
	pantalla_carga.desaparecer()
	add_child(http_request)
	http_request.request_completed.connect(self._on_request_completed)
	mensaje_error.hide()  # Ocultar mensaje de error inicialmente

func _on_boton_nueva_contraseña_pressed() -> void:
	# Validaciones
	if contrasenia.text != repetir_contra.text:
		mostrar_error("Las contraseñas no coinciden")
		return
	
	if contrasenia.text.length() < 6:
		mostrar_error("La contraseña debe tener al menos 6 caracteres")
		return
	
	if user_email.strip_edges() == "":
		mostrar_error("No se ha identificado el usuario")
		return
	
	# Mostrar pantalla de carga
	pantalla_carga.aparecer()
	
	# Hashear la contraseña
	var contrasena_hash = hash_password(contrasenia.text)
	
	# Crear el cuerpo de la petición
	var body = {
		"email": user_email,
		"contrasenaHash": contrasena_hash
	}
	
	# Convertir a JSON
	var json_body = JSON.stringify(body)
	
	# Configurar headers
	var headers = ["Content-Type: application/json"]
	
	# Construir URL completa
	var endpoint = Globales.api_base_url + "/actualizar-contrasena"
	
	# Enviar la petición PUT
	var error = http_request.request(
		endpoint,
		headers,
		HTTPClient.METHOD_PUT,
		json_body
	)
	
	if error != OK:
		pantalla_carga.desaparecer()
		mostrar_error("Error al conectar con el servidor")

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	pantalla_carga.desaparecer()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		mostrar_error("Error de conexión con el servidor")
		return
	
	# Parsear la respuesta JSON
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		mostrar_error("Error al procesar la respuesta del servidor")
		return
	
	var response = json.get_data()
	
	if response_code == 200:
		if response.get("success", false):
			# Contraseña actualizada exitosamente
			print("Contraseña actualizada correctamente")
			get_tree().change_scene_to_file("res://scenes/inicio_sesion/vista_inicio_credenciales.tscn")
		else:
			mostrar_error(response.get("message", "Error al actualizar contraseña"))
	elif response_code == 400:
		mostrar_error("Datos incompletos para la solicitud")
	elif response_code == 404:
		mostrar_error("Usuario no encontrado")
	else:
		mostrar_error("Error del servidor: Código " + str(response_code))

# Función para hashear la contraseña
func hash_password(password: String) -> String:
	return password.sha256_text()

# Función para mostrar errores al usuario
func mostrar_error(mensaje: String) -> void:
	mensaje_error.text = mensaje
	mensaje_error.show()
	await get_tree().create_timer(3.0).timeout  # Mostrar por 3 segundos
	mensaje_error.hide()

# Función para establecer el email del usuario
func set_user_email(email: String) -> void:
	user_email = email
	print("Email establecido para cambio de contraseña:", user_email)
