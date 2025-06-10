extends Control

const Config = preload("res://config.gd")

const API_URL = Config.API_BASE_URL+"/ranking"
const PLAYER_SCORE_URL = Config.API_BASE_URL+"/puntaje-usuario"
const TOP_PLAYERS_TO_SHOW = 5

# Nodos HTTPRequest separados
@onready var http_request_ranking = $HTTPRequestRanking
@onready var http_request_score = $HTTPRequestScore

# Labels para mostrar la información
@onready var player_labels = [$Label1, $Label2, $Label3, $Label4, $Label5]
@onready var puntajejugador = $puntajejugador

func _ready():
	# Inicializar labels con valores por defecto
	initialize_labels()
	
	# Conectar señales de los HTTPRequests
	http_request_ranking.request_completed.connect(_on_ranking_completed)
	http_request_score.request_completed.connect(_on_score_completed)
	
	# Hacer las peticiones
	fetch_ranking()
	fetch_player_score()

func initialize_labels():
	# Configurar texto inicial en los labels
	for i in range(TOP_PLAYERS_TO_SHOW):
		player_labels[i].text = "   %d- Cargando..." % (i + 1)
	puntajejugador.text = "Tu puntaje: Cargando..."

func fetch_ranking():
	var error = http_request_ranking.request(API_URL)
	if error != OK:
		print("Error al iniciar request de ranking:", error)
		show_error("Error al cargar ranking")

func fetch_player_score():
	var user_email = get_saved_email()
	if user_email:
		var url = "%s?email=%s" % [PLAYER_SCORE_URL, user_email]
		var error = http_request_score.request(url)
		if error != OK:
			print("Error al iniciar request de puntaje:", error)
			show_error("Error al cargar tu puntaje")

func get_saved_email():
	var config = ConfigFile.new()
	var err = config.load("user://session.cfg")
	if err == OK:
		var mailusername = config.get_value("session", "mail", "")
		if mailusername != "":
			print("Email recuperado:", mailusername)
			return mailusername
	print("No se encontró email guardado")
	return null

func _on_ranking_completed(result, response_code, headers, body):
	handle_ranking_response(body, response_code)

func _on_score_completed(result, response_code, headers, body):
	handle_score_response(body, response_code)

func handle_ranking_response(body, response_code):
	if response_code != 200:
		print("Error en respuesta de ranking:", response_code)
		show_error("Error al obtener ranking")
		return
	
	var data = parse_json(body)
	if data == null:
		return
	
	if typeof(data) == TYPE_ARRAY:
		print("Datos de ranking recibidos (", data.size(), " jugadores)")
		process_ranking_data(data)
	else:
		print("Formato de ranking inesperado:", typeof(data))
		show_error("Formato de ranking incorrecto")

func handle_score_response(body, response_code):
	if response_code != 200:
		print("Error en respuesta de puntaje:", response_code)
		show_error("Error al obtener tu puntaje")
		return
	
	var data = parse_json(body)
	if data == null:
		return
	
	if typeof(data) == TYPE_DICTIONARY:
		print("Datos de puntaje recibidos:", data)
		process_score_data(data)
	else:
		print("Formato de puntaje inesperado:", typeof(data))
		show_error("Formato de puntaje incorrecto")

func parse_json(body):
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	if error != OK:
		print("Error parseando JSON:", json.get_error_message())
		show_error("Error en datos recibidos")
		return null
	return json.get_data()

func process_ranking_data(data):
	# Ordenar por puntuación descendente
	data.sort_custom(func(a, b): return a["puntuacion_total"] > b["puntuacion_total"])
	
	# Mostrar los primeros TOP_PLAYERS_TO_SHOW jugadores
	for i in range(min(TOP_PLAYERS_TO_SHOW, data.size())):
		var player = data[i]
		player_labels[i].text = "   %d- %s: %d pts" % [i + 1, player["nombre_usuario"], player["puntuacion_total"]]
	
	# Limpiar labels restantes si hay menos jugadores que TOP_PLAYERS_TO_SHOW
	for i in range(data.size(), TOP_PLAYERS_TO_SHOW):
		player_labels[i].text = "   %d- ---" % (i + 1)

func process_score_data(data):
	if data.has("puntuacion_total"):
		puntajejugador.text = "Tu puntaje: %d pts" % data["puntuacion_total"]
		
		# Opcional: Mostrar también el nombre del jugador
		if data.has("nombre_usuario"):
			puntajejugador.text = "%s: %d pts" % [data["nombre_usuario"], data["puntuacion_total"]]
	else:
		print("Datos de puntaje incompletos:", data)
		puntajejugador.text = "Puntaje no disponible"

func show_error(message):
	# Mostrar mensaje de error en los labels
	for i in range(TOP_PLAYERS_TO_SHOW):
		player_labels[i].text = "   %d- Error" % (i + 1)
	puntajejugador.text = message
func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")
	pass # Replace with function body.
