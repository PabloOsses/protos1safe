extends Control


@onready var mail=$mail
@onready var contrasenia=$contrasenia
@onready var estado=$estado

func _ready() -> void:
	
	$AuthManager.login_success.connect(_on_login_success)
	$AuthManager.login_failed.connect(_on_login_failed)
	


func _process(delta: float) -> void:
	pass


func _on_inicio_pressed() -> void:
	#print(mail.text)
	$AuthManager.login_user(mail.text, contrasenia.text)
	estado.text="Procesando solicitud"
func _on_login_success(id_usuario: int, message: String):
	print("Login exitoso! ID de usuario: ", id_usuario)
	save_session(mail.text)
	estado.text="Bienvenido! "+mail.text
	Globales.modo_offline=false
	#Globales.usuario_email=mail.text
	#await Globales.cargar_logros_usuario()
	# TO DO Guardar el ID de usuario en alguna variable global
	# Cambiar a la escena principal del juego (de online)
	
	
	#CARGAR COSAS QUE DEBERIAN SUCEDER EN ESTA SITUACION
	Globales.load_session() 
	await Globales.cargar_logros_usuario()
	Globales.global_act_logros()
	await Globales.cargar_configuracion_usuario()
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")
func _on_login_failed(error_message: String):
	print("Error en login: ", error_message)
	
	estado.text="CREDENCIAL ERRONEA"
	mail.text=""
	contrasenia.text=""

func save_session(mail: String):
	var config = ConfigFile.new()
	config.set_value("session", "mail", mail)
	config.save("user://session.cfg")  # Guarda en la carpeta del usuario

#SIN USAR
func load_session():
	var config = ConfigFile.new()
	var err = config.load("user://session.cfg")
	if err == OK:  # Si el archivo existe
		var username = config.get_value("session", "mail", "")
		return {"mail": mail}
	return null  # No hay sesión guardada



func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	pass # Replace with function body.


func _on_registro_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/registro/registro.tscn")
	pass # Replace with function body.


func _on_recuperar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/recuperar/recuperar.tscn")
	pass # Replace with function body.
