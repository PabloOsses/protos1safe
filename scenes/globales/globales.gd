extends Node2D
#const api_base_url = "http://localhost:3000"

const Config = preload("res://config.gd")
var api_base_url = Config.API_BASE_URL
@onready var http_request = HTTPRequest.new()
@onready var dificultad = "facil"

var is_online : bool = false
var modo_offline : bool = false

var logros_usuario = []  # Almacenará los logros del usuario
var usuario_email = ""   # Email del usuario logueado
#------
var carga_datos=false


#_____________

var logro_1 
var logro_2 

var ar_juegos_completados=[false,false,false,false,false]

var logro_3 
var logro_4 

var logro_5 
var sin_perder_vidas
var juegos_sin_perder_vidas=0
var hay_conexion: bool
var hay_persistencia: bool
#--------------
var caso2_persiste
func _ready() -> void:
	await get_tree().create_timer(2.0).timeout

	#______
	
	logro_1 = false
	logro_2 = false
	#print("GLOBAL NO Comletados : "+str(ar_juegos_completados.count(false)))
	logro_3 = false
	logro_4 = false
	sin_perder_vidas=false
	logro_5 = false
	#_____
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	
	print("GLOBAL Conexión: " + str(hay_conexion))
	print("GLOBAL Persistencia: " + str(hay_persistencia))
	
	if is_online and hay_persistencia:
		print("GLOBAL DIFICULTAD CASO 1 CONEXIÓN Y PERSISTENCIA")
		# Cargar logros del usuario si hay conexión y persistencia
		await cargar_logros_usuario()
		#await get_tree().create_timer(9.0).timeout
		carga_datos=true
		
		print("GLOBAL ready: " , logros_usuario[0]["desbloqueado"])
		global_act_logros()
	elif is_online and not hay_persistencia:
		print("GLOBAL DIFICULTAD CASO 2 CONEXIÓN NO PERSISTENCIA")
		dificultad = "facil"
	#else:
		#print("DIFICULTAD CASO 3 NO CONEXIÓN NO PERSISTENCIA")
		#dificultad = "facil"
	#print("GLOBAL PRUEBA CARGA")
	
func global_act_logros():
	logro_1=logros_usuario[0]["desbloqueado"]
	logro_2=logros_usuario[1]["desbloqueado"]	
	logro_3=logros_usuario[2]["desbloqueado"]
	logro_4=logros_usuario[3]["desbloqueado"]
	logro_5=logros_usuario[4]["desbloqueado"]
	
#func load_session():
	#var config = ConfigFile.new()
	#var err = config.load("user://session.cfg")
	#if err == OK:  # Si el archivo existe
		#var username = config.get_value("session", "mail", "")
		#return {"mail": mail}
	#return null  # No hay sesión guardada
func load_session():
	#EXPERIMENTAL NO TOCAR
	var config = ConfigFile.new()
	var err = config.load("user://session.cfg")
	if err == OK:  # Si el archivo existe
		var mailusername = config.get_value("session", "mail", "")
		#Globales.usuario_email="juan.perez@example.com"
		usuario_email=mailusername
		print("GLOBAL: usuario guardado: "+str(mailusername))
		
		return true
	
	return false  # No hay sesión guardada	
	
func _process(delta: float) -> void:
	if ar_juegos_completados.count(true)>=3 and logro_2==false:
		final_logro_2()
	if juegos_sin_perder_vidas >=1 and logro_5==false:
		f_logro_5()
	
	pass
func f_logro_1():
	if logro_1!=true:
		logro_1=true
		desbloquear_logro(1)
	print("logro1")
	
func f_logro_2(i):
	ar_juegos_completados[i]=true
	print("avansando....logro2")
func final_logro_2():
	logro_2 = true
	desbloquear_logro(2)
	print("logro2")
func f_logro_3():
	logro_3=true
	desbloquear_logro(3)
	print("logro3")
func f_logro_4():
	
	logro_4=true
	desbloquear_logro(4)
	
func f_logro_5():
	sin_perder_vidas=true
	logro_5 = true
	desbloquear_logro(5)

func cargar_logros_usuario() -> void:
	if usuario_email == "":
		return
	
	var url = api_base_url + "/logros-usuario?email=" + usuario_email
	var headers = ["Accept: application/json; charset=utf-8"]  # Forzar UTF-8
	
	var error = http_request.request(url, headers)
	if error != OK:
		print("Error al solicitar logros del usuario: ", error)
		return
	
	# Esperar a que la solicitud HTTP se complete
	var result = await http_request.request_completed
	
	# Verificar si la solicitud fue exitosa
	var response_code = result[1]
	if response_code != 200:
		print("Error en la respuesta HTTP: ", response_code)
		return
	
	# Procesar los datos recibidos
	var json = JSON.new()
	var parse_result = json.parse(result[3].get_string_from_utf8())
	
	if parse_result != OK:
		print("Error al parsear JSON: ", json.get_error_message())
		return
	
	logros_usuario = json.get_data()
	print("Logros cargados exitosamente")
# Función para desbloquear un logro
func desbloquear_logro(id_logro: int) -> void:
	if usuario_email == "" or not is_online:
		return
	
	var url = api_base_url + "/desbloquear-logro"
	var headers = [
		"Content-Type: application/json; charset=utf-8",
		"Accept: application/json; charset=utf-8"
	]
	var body = JSON.stringify({
		"email": usuario_email,
		"id_logro": id_logro
	})
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("Error al intentar desbloquear logro: ", error)
# Manejo de respuestas HTTP
func _on_request_completed(result, response_code, headers, body):
	# Primero verifica si la request fue exitosa
	if result != HTTPRequest.RESULT_SUCCESS:
		print("GLOBAL Error en la conexión: ", result)
		return
	
	# Intenta decodificar el cuerpo de la respuesta
	var body_text = body.get_string_from_utf8()
	if body_text == "":
		print("Respuesta vacía recibida")
		return
	
	# Verifica si es JSON válido
	var json = JSON.new()
	var parse_error = json.parse(body_text)
	
	if parse_error != OK:
		print("Error parseando JSON: ", json.get_error_message())
		print("Respuesta cruda: ", body_text)
		return
	
	var response = json.get_data()
	
	# Manejo de la respuesta según el endpoint
	if response_code == 200:
		if typeof(response) == TYPE_ARRAY:
			logros_usuario = response
			print("Logros actualizados:", logros_usuario)
		elif typeof(response) == TYPE_DICTIONARY and response.has("message"):
			print("Logro desbloqueado:", response)
			await cargar_logros_usuario()
	else:
		print("Error en la respuesta (", response_code, "): ", response)

# Obtener configuración
func obtener_configuracion_usuario(email: String):
	var url = api_base_url + "/configuracion-usuario?email=" + email
	var error = http_request.request(url)
	
	if error != OK:
		return null
	
	var response = await http_request.request_completed
	if response[0] != HTTPRequest.RESULT_SUCCESS:
		return null
	
	var body = JSON.parse_string(response[3].get_string_from_utf8())
	return body

# Actualizar configuración
func actualizar_configuracion(email: String, config: Dictionary):
	var url = api_base_url + "/actualizar-configuracion"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"email": email,
		"volumen_musica": config.get("volumen_musica", 1.0),
		"volumen_efectos": config.get("volumen_efectos", 1.0),
		"dificultad": config.get("dificultad", "facil")
	})
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_PUT, body)
	if error != OK:
		return false
	
	var response = await http_request.request_completed
	return response[0] == HTTPRequest.RESULT_SUCCESS
	
	
#ESTO PODRIA EXPLOTAR PERO EL RIESGO VALE LA PENA
# ES UN MODIFICADO DE CONFIG USUARIo
func cargar_configuracion_usuario():
	# Obtener el email del usuario (de tu sistema de persistencia)
	var email_usuario = usuario_email  # Asume que tienes esto almacenado
	
	# Llamar a la función y esperar la respuesta
	var configuracion = await obtener_configuracion_usuario(Globales.usuario_email)
	
	if configuracion == null:
		print("Error al obtener configuración")
		# Usar valores por defecto
		configuracion = {
			"volumen_musica": 1.0,
			"volumen_efectos": 1.0,
			"dificultad": "facil"
		}
	print("GLOBAL CONFIG ES: ", configuracion)
	
	# Aplicar la configuración en tu juego
	aplicar_configuracion(configuracion)

func aplicar_configuracion(config):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("music"),
		linear_to_db(config.volumen_musica)
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("sfx"),
		linear_to_db(config.volumen_efectos)
	)
	dificultad = config.dificultad
	
func acumular_puntuacion(email: String, id_nivel: int, puntos: int) -> void:
	var endpoint = "/acumular-puntuacion"  # Parte dinámica de la URL
	var full_url = api_base_url + endpoint
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Usamos un nombre único para el callback
	http_request.request_completed.connect(
		self._on_puntuacion_request_completed.bind(email, id_nivel, puntos, http_request)
	)
	
	# Crear el cuerpo de la petición
	var body = {
		"email": email,
		"id_nivel": id_nivel,
		"puntos": puntos
	}
	
	# Convertir a JSON
	var json_body = JSON.stringify(body)
	
	# Configurar los headers
	var headers = ["Content-Type: application/json"]
	
	# Hacer la petición POST
	var error = http_request.request(full_url, headers, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		push_error("Error al crear la petición HTTP")
		http_request.queue_free()

# Callback con nombre único y manejo del HTTPRequest
func _on_puntuacion_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray,
	email: String,
	id_nivel: int,
	puntos: int,
	request_node: HTTPRequest
) -> void:
	if is_instance_valid(request_node):
		request_node.queue_free()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Error en la conexión HTTP")
		return
	
	# Parsear la respuesta
	var json = JSON.new()
	var parse_error = json.parse(body.get_string_from_utf8())
	
	if parse_error != OK:
		push_error("Error al parsear la respuesta JSON")
		return
	
	var response = json.get_data()
	
	if response_code == 200:
		# Éxito - puedes usar los datos de la respuesta
		print("Puntuación acumulada exitosamente: ", response)
		
		# Ejemplo de cómo acceder a los datos:
		var puntos_totales = response["puntos_totales"]
		print("Puntos totales ahora: ", puntos_totales)
		
		# Emitir señal o actualizar UI aquí
		# Ejemplo: emit_signal("puntuacion_actualizada", puntos_totales)
	else:
		# Manejar errores
		push_error("Error en la API: ", response.get("error", "Desconocido"))
		print("Detalles: ", response.get("details", "Sin detalles"))
