extends Node


@onready var http_request = HTTPRequest.new()
@onready var dificultad = "facil"
#@onready var dificultad = "medio"
#@onready var dificultad = "dificil"

var is_online : bool = false

#este detecta si se presiono el enorme boton de jugar al principio
var modo_offline : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if check_connection():
		#get_tree().change_scene_to_file("res://scenes/inicio/vista_inicio_v_1.tscn")
	#else:
		#get_tree().change_scene_to_file("res://scenes/inicio/vista_inicio_v_1.tscn")
	
	add_child(http_request)
	var hay_coneccion=await check_internet_connection()
	var hay_persistencia = persistencia()
	print("Coneccion: "+str(hay_coneccion))
	print("persistencia: "+str(hay_persistencia))
	if hay_coneccion and hay_persistencia:
		print("DIFICULTAD CASO 1 CONECCION Y PERSISTENCIA")
		
	elif hay_coneccion and not hay_persistencia:
		print("DIFICULTAD CASO 2 CONECCION NO PERSISTENCIA")
		dificultad = "facil"
	else:
		print("DIFICULTAD CASO 3 NO CONECCION NO PERSISTENCIA")
		dificultad = "facil"
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
func check_internet_connection() -> bool:
	var url = "https://www.google.com"
	var timeout_sec = 5  # Tiempo máximo de espera
	
	# Configurar timeout manualmente (opcional)
	var timer = get_tree().create_timer(timeout_sec)
	
	var error = http_request.request(url)
	if error != OK:
		print("Error al crear la petición HTTP")
		return false
	
	# Esperar respuesta o timeout
	var response = await http_request.request_completed
	var result = response[0]  # Código de error (0 = OK)
	var response_code = response[1]  # HTTP status (200, 404, etc.)
	
	is_online = (result == OK and response_code == 200)
	print("✅ Conectado a Internet" if is_online else "❌ Sin Internet")
	return is_online


func persistencia():
	var config = ConfigFile.new()
	var err = config.load("user://session.cfg")
	if err == OK:  # Si el archivo existe
		var mailusername = config.get_value("session", "mail", "")
		print("DIFICULTAD usuario guardado: "+str(mailusername))
		return true
	return false  # No hay sesión guardada
