extends Control

@onready var enviocorreo=$enviocorreo
@onready var correo=$enviocorreo/mail
@onready var nueva_contra=$nueva_contrasenia
@onready var pantalla_carga=$carga_buena
@onready var correo_instruc=$enviocorreo/intrucciones_mail
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enviocorreo.visible=true
	nueva_contra.visible=false
	pantalla_carga.desaparecer()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/inicio_sesion/vista_inicio_credenciales.tscn")
	


func _on_boton_nueva_contraseña_pressed() -> void:
	print("IR A OTRA ESCENA")
	pantalla_carga.editar_mensaje_carga("Cargando")
	pantalla_carga.aparecer()
	await get_tree().create_timer(2.0).timeout
	pantalla_carga.editar_mensaje_carga("")
	pantalla_carga.desaparecer()
	get_tree().change_scene_to_file("res://scenes/recuperar/recuperar_parte_2.tscn")
	pass # Replace with function body.
	
func _on_boton_enviar_mail_pressed() -> void:
	enviocorreo.visible = false
	nueva_contra.visible = true
	pantalla_carga.editar_mensaje_carga("Verificando email...")
	pantalla_carga.aparecer()
	
	var email = correo.text.strip_edges()
	print("Email para recuperación: ", email)
	
	# Verificar primero si el email existe
	var endpoint_verificar = Globales.api_base_url + "/verificar-email?email=%s" % email.uri_encode()
	#---------
	Globales.usuario_email=email
	#---------
	var http_verificar = HTTPRequest.new()
	add_child(http_verificar)
	http_verificar.request_completed.connect(_on_verificacion_completada.bind(email))
	
	var error = http_verificar.request(endpoint_verificar)
	print("RECUPERAR el error o algo:",error)
	if error != OK:
		print("RECUPERAR ERROR")
		pantalla_carga.desaparecer()
		mostrar_error("Error en la conexión. Intenta nuevamente.")
		http_verificar.queue_free()

func _on_verificacion_completada(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, email: String):
	var http_verificar = get_node_or_null("HTTPRequest") # Manejo seguro si el nodo ya no existe
	if http_verificar:
		http_verificar.queue_free()
	
	if response_code != 200:
		pantalla_carga.desaparecer()
		mostrar_error("Error del servidor (Código %d)" % response_code)
		print("CASO MAIL INCORRECTO")
		enviocorreo.visible = true
		nueva_contra.visible = false
		correo_instruc.visible=true
		correo_instruc.add_theme_color_override("font_color", Color.RED)
		correo_instruc.text="Escriba un mail válido"
		
		return
	
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		pantalla_carga.desaparecer()
		mostrar_error("Error al leer la respuesta")
		return
	
	var response = json.get_data()
	
	if not response.get("existe", false):
		pantalla_carga.desaparecer()
		mostrar_error("No se encontró una cuenta con ese email")
		return
	
	# Si el email existe, proceder con recuperación
	pantalla_carga.editar_mensaje_carga("Generando contraseña...")
	
	var endpoint_recuperar = Globales.api_base_url + "/auth/olvide-contrasena"
	var request_headers = ["Content-Type: application/json"]
	var body_data = JSON.stringify({"email": email})
	
	var http_recuperar = HTTPRequest.new()
	add_child(http_recuperar)
	http_recuperar.request_completed.connect(_on_recuperacion_completada)
	
	if http_recuperar.request(endpoint_recuperar, request_headers, HTTPClient.METHOD_POST, body_data) != OK:
		http_recuperar.queue_free()
		pantalla_carga.desaparecer()
		mostrar_error("Error al enviar la solicitud")

func _on_recuperacion_completada(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var http_recuperar = get_node_or_null("HTTPRequest")
	print("RECUPERAR COMPLETADA",http_recuperar)
	if http_recuperar:
		http_recuperar.queue_free()
	
	pantalla_carga.desaparecer()
	
	match response_code:
		200:
			mostrar_mensaje_exito("Se ha enviado una contraseña provisional a tu email")
		400:
			mostrar_error("Email no válido")
		500:
			#print("recuperar AQUI AQUI AQUI!!!")
			mostrar_error("Error interno del servidor")
		_:
			mostrar_error("Error desconocido (Código %d)" % response_code)

# funciones auxiliares 
func mostrar_error(mensaje: String):
	
	
	print("ERROR: ", mensaje)

func mostrar_mensaje_exito(mensaje: String):
	
	
	print("ÉXITO: ", mensaje)
