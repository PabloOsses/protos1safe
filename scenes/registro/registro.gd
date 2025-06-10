extends Control

@onready var nombre_usuario=$nombre_usuario
@onready var mail=$mail
@onready var contrasenia=$contrasenia
@onready var repetir_contrasenia=$repetir_contrasenia
@onready var mensaje_oculto:Label=$mensaje_oculto

@onready var carga_registro=$carga_buena

var velocidad_desplazamiento: float = 60.0 

var mensajes: Array = [
	"Por favor completa todos los campos",
	"Mail ya registrado",
	"Contraseña no válida "
]
var mensaje_actual: String = "ACTUAL ACTUAL"

var mostrar:bool=false
func _ready() -> void:
	$AuthManager.registration_successful.connect(_on_registration_successful)
	$AuthManager.registration_failed.connect(_on_registration_failed)
	
	mensaje_oculto.text = mensaje_actual
	mensaje_oculto.position.x = get_viewport_rect().size.x  # Comienza fuera de pantalla a la derecha
	mensaje_oculto.autowrap_mode = TextServer.AUTOWRAP_OFF  # Para que no haga saltos de línea
	
	carga_registro.desaparecer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mostrar:
		mensaje_oculto.visible=true
		mensaje_oculto.position.x -= velocidad_desplazamiento * delta
		
		# Reiniciar posición cuando el texto sale completamente por la izquierda
		if mensaje_oculto.position.x < -mensaje_oculto.size.x:
			mensaje_oculto.position.x = get_viewport_rect().size.x
			#cambiar_mensaje()
	else:
		mensaje_oculto.visible=false
func colocar_mensaje(delta: float):
	mensaje_oculto.position.x -= velocidad_desplazamiento * delta
	
	# Reiniciar posición cuando el texto sale completamente por la izquierda
	if mensaje_oculto.position.x < -mensaje_oculto.size.x:
		mensaje_oculto.position.x = get_viewport_rect().size.x
		
func cambiar_mensaje(cambio_mensaje):
	mostrar = true
	
	mensaje_oculto.text =  cambio_mensaje # Repetir para efecto continuo

func _on_registration_successful(user_data: Dictionary):
	print("Registro exitoso!", user_data)
	# Guardar datos del usuario, cambiar escena, etc.

func _on_registration_failed(error_message: String):
	print("Error en registro DOS: ", error_message)
	cambiar_mensaje(error_message)


func _on_registrarse_pressed() -> void:
	var username = nombre_usuario.text.strip_edges()
	
	var email = mail.text.strip_edges()
	var password = contrasenia.text
	var password_repeat = repetir_contrasenia.text

# Validaciones (mantén tu código actual)
	if username == "" or email == "" or password == "" or password_repeat == "":
		cambiar_mensaje("Por favor completa todos los campos")
		return

	if not "@" in email or "." not in email.split("@")[-1]:
		cambiar_mensaje("Por favor ingresa un correo electrónico válido")
		return

	if password != password_repeat:
		cambiar_mensaje("Las contraseñas no coinciden")
		return

	if password.length() < 6:
		cambiar_mensaje("La contraseña debe tener al menos 6 caracteres")
		return

	print("REGISTRANDO ......")
	carga_registro.aparecer()
	
	# Elimina el await get_tree().create_timer(5.0).timeout
	
	var result = await $AuthManager.register_user(username, email, password)
	carga_registro.desarrollo()
	await get_tree().create_timer(3.0).timeout
	carga_registro.desaparecer()

	#print("Resultado del registro: ", result)
	
	
	cambiar_mensaje("REGISTRO LOGRADO")
	get_tree().change_scene_to_file("res://scenes/inicio_sesion/vista_inicio_credenciales.tscn")
	
	
	
func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/inicio_sesion/vista_inicio_credenciales.tscn")
	
