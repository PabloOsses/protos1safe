extends Node2D
#NOTA: por alguna razon si el nodo es Control, todo esto no funciona
#NOTA2: por lo anterior, tener cuidado en la interfaz visual (testear)
# configuracion 
var original_texture: Texture2D
var show_complete_time = 4.0  # tiempo que se muestra la imagen completa
var grid_size = Vector2(2, 2)  # tamaño del grid del rompecabezas (columnas y filas)
var piece_spacing = 5  # Espacio entre piezas
var shuffle_strength = 200  # Cuánto se mezclan las piezas

# variables de control
var is_showing_complete = true
var screen_center: Vector2
var piece_size: Vector2
var puzzle_pieces = []
var selected_piece: Sprite2D = null
var piece_offset: Vector2 = Vector2.ZERO
var puzzle_solved = false

# nombres de nodos que deben preservarse
# RECORDAR: si se agrega un nodo, agregarlo a la lista
# porque si no sera eliminado
const PRESERVE_NODES = ["Background", "volver","positivo","pantallaresumen","instrucciones"]
@onready var background_resumen= $pantallaresumen/backgroundResumen
@onready var texto_resumen=$pantallaresumen/textoResumen
#----------
#esto es para controlar el puntaje, parte en 10 
#despues de eso desiende
var current_score := 10.0
var min_score := 4.0
var total_duration := 60.0      # 1 minuto total
var plateau_duration := 15.0    # 15 segundos al inicio con puntaje 10
var effective_duration := total_duration - plateau_duration
var score_timer := 0.0
var is_score_timer_active := false
#---------


var nueva_base=10
func _ready():
	Musica.reproducir("nivel_4")
	
	background_resumen.visible = false
	texto_resumen.visible = false
	#---------------------------
	if Globales.dificultad == "facil":
		print("facil")
		nueva_base=10.0
	elif Globales.dificultad == "medio":
		print("medio")
		nueva_base=8.0
	elif Globales.dificultad == "dificil":
		print("dificil")
		nueva_base=8.0
	else:
		print("facil")
	#---------------------------
	# lista de imagenes disponibles 
	# en caso de agregar mas imagenes SOLO ANOTAR NOMBRE ya que la ruta se ve despues
	var background_names = [
		"sunny","shop","sunset" # ← Reemplaza con los nombres reales
	]

	# seleccionar uno de los nombres de forma aleatoria
	var random_name = background_names[randi() % background_names.size()]
	var background_path = "res://assets/backgrounds/%s.png" % random_name
	
	# ahora se carga la imagen
	original_texture = load(background_path)
	
	# obtener el centro de la pantalla
	screen_center = get_viewport_rect().size / 2
	
	var background = get_node_or_null("Background")
	if background:
		background.z_index = -1  # fondo detrás de todo

	show_complete_image()
	# temporizador para cambiar a las piezas
	var timer = get_tree().create_timer(show_complete_time)
	timer.timeout.connect(create_puzzle_pieces)

func _process(delta: float) -> void:
	
		
	score_timer += delta
	print(score_timer)
# cronómetro de puntaje
	if score_timer <= plateau_duration:
		current_score = nueva_base
	else:
		var progress = min((score_timer - plateau_duration) / effective_duration, 1.0)
		current_score = lerp(nueva_base, 4.0, progress)
	#print("aqui: "+str(current_score))
	
	pass
	
	
	
func show_complete_image():
	# RECORDAR OTRA VES, AGREGAR NODOS NUEVOS A LA LISTA
	for child in get_children():
		if child.name not in PRESERVE_NODES:
			child.queue_free()
	
	# se creaa sprite con la imagen completa centrada
	var full_image = Sprite2D.new()
	full_image.texture = original_texture
	full_image.position = screen_center
	full_image.centered = true
	
	# excalado de la imagen
	var max_size = get_viewport_rect().size * 0.8 
	var scale_factor = min(
		max_size.x / original_texture.get_width(),
		max_size.y / original_texture.get_height()
	)
	full_image.scale = Vector2(scale_factor, scale_factor)
	full_image.name = "FullImage"
	
	
	add_child(full_image)
	# esto es para que la imagen este sobre el fondo pero bajo el boton
	full_image.z_index = 1  
	move_child(full_image, get_child_count() - 2)  # posicion en el arbol

	is_showing_complete = true

func create_puzzle_pieces():
	# eliminar la imagen completa primero
	var full_image_node = get_node_or_null("FullImage")
	if full_image_node:
		full_image_node.queue_free()
	
	# limpiar cualquier otra pieza existente
	for child in get_children():
		if child.name not in PRESERVE_NODES:
			child.queue_free()
	
	is_showing_complete = false
	puzzle_solved = false
	
	# factor de escala, por algun motivo queda mejor en 0.9
	var max_size = get_viewport_rect().size * 0.9
	var scale_factor = min(
		max_size.x / original_texture.get_width(),
		max_size.y / original_texture.get_height()
	)
	
	# se calcula tamaño de piezas considerando el escalado
	var scaled_texture_size = original_texture.get_size() * scale_factor
	piece_size = scaled_texture_size / grid_size
	
	# se crean piezas alrededor del centro
	var start_pos = screen_center - (piece_size * grid_size / 2)
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			#  AtlasTexture para cada pieza
			var atlas = AtlasTexture.new()
			atlas.atlas = original_texture
			atlas.region = Rect2(
				x * piece_size.x / scale_factor,  # se ajusta region al tamaño original
				y * piece_size.y / scale_factor,
				piece_size.x / scale_factor,
				piece_size.y / scale_factor
			)
			
			# crear sprite para la pieza
			var piece = Sprite2D.new()
			piece.texture = atlas
			piece.centered = true
			piece.position = start_pos + Vector2(
				x * (piece_size.x + piece_spacing),
				y * (piece_size.y + piece_spacing)
			)
			piece.scale = Vector2(scale_factor, scale_factor)  # Aplicar mismo escalado
			piece.name = "Piece_%d_%d" % [x, y]
			
			# esto es para que sea "arrastrable"
			# NOTA: el drag funciona mejor en celular
			setup_draggable_piece(piece)
			
			add_child(piece)
			puzzle_pieces.append(piece)
	
	# para mezclar las piezas alrededor del centro
	shuffle_pieces()
func setup_draggable_piece(piece: Sprite2D):
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	collision.shape = RectangleShape2D.new()
	collision.shape.size = piece_size / piece.scale if piece.scale != Vector2.ZERO else piece_size
	area.add_child(collision)
	
	# se concectan señales de input
	area.input_event.connect(_on_piece_input_event.bind(piece))
	area.mouse_entered.connect(_on_piece_mouse_entered.bind(piece))
	area.mouse_exited.connect(_on_piece_mouse_exited.bind(piece))
	
	piece.add_child(area)

func shuffle_pieces():
	for piece in puzzle_pieces:
		# mover piezas aleatoriamente alrededor del centro
		var random_offset = Vector2(
			randf_range(-shuffle_strength, shuffle_strength),
			randf_range(-shuffle_strength, shuffle_strength)
		)
		piece.position = screen_center + random_offset

func _on_piece_input_event(viewport, event, shape_idx, piece):
	#eventos de inicio (touch o click)
	if (event is InputEventScreenTouch and event.pressed) or \
		(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		
			selected_piece = piece
			# Usar position para eventos táctiles, global_position para ratón
			var event_pos = event.position if event is InputEventScreenTouch else event.global_position
			piece_offset = piece.global_position - event_pos
			piece.z_index = 1  # Traer al frente
	
	#  eventos de fin (touch o click)
	elif (event is InputEventScreenTouch and not event.pressed) or \
		(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed):
		
		if selected_piece:
			selected_piece.z_index = 0
			selected_piece = null
			if check_solution() and not puzzle_solved:
				puzzle_solved = true
				#show_puzzle_complete_effect()
				print("¡Felicidades! Has completado el rompecabezas correctamente.")
				$positivo.play()
				fin_del_juego()
	
	#  movimiento (drag celular o mouse)
	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and selected_piece:
		#  position para eventos táctiles, global_position para ratón
		var event_pos = event.position if event is InputEventScreenDrag else event.global_position
		selected_piece.global_position = event_pos + piece_offset

func fin_del_juego():
	background_resumen.top_level=true
	texto_resumen.top_level=true
	#----------logro 2
	Globales.f_logro_2(3)
	#---------lOGRO 4
	if score_timer < 20 and Globales.logro_4==false:
		print("------LOGRO 4 !")
		Globales.f_logro_4()
		
	#----------------
	Globales.f_logro_1()
	print("CALCULO PUNTAJE: " + str(Globales.dificultad))
	print("CALCULO PUNTAJE: " + str(RondasManager.game5_puntaje_total))
	
	if Globales.dificultad == "facil":
		
		current_score=int(current_score)*1
		Globales.acumular_puntuacion(Globales.usuario_email,10,current_score)
	elif Globales.dificultad == "medio":
		current_score=int(current_score)*1.5
		Globales.acumular_puntuacion(Globales.usuario_email,11,current_score)
	elif Globales.dificultad == "dificil":
		Globales.f_logro_3()
		current_score=int(current_score)*2
		Globales.acumular_puntuacion(Globales.usuario_email,12,current_score)
	else:
		current_score=int(current_score)*1
	#----------------	
	background_resumen.visible = true
	texto_resumen.visible = true
	texto_resumen.text="Puntaje: "+ str(int(current_score))
	background_resumen.modulate.a = 0.0
	texto_resumen.modulate.a = 0.0
	var tween := get_tree().create_tween()
	tween.tween_property(background_resumen, "modulate:a", 1.0, 1.5)
	tween.set_parallel()
	tween.tween_property(texto_resumen, "modulate:a", 1.0, 1.5)
	#background_resumen.visible = true
	#texto_resumen.visible = true
	await get_tree().create_timer(5.0).timeout
	RondasManager.reiniciar_game3()
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")
	
func show_puzzle_complete_effect():
	# no implementado, redundante
	# ...pero tal ves en sprint 3
	for piece in puzzle_pieces:
		var tween = create_tween()
		tween.tween_property(piece, "modulate", Color(0.9, 1.0, 0.9), 0.2)
		tween.tween_property(piece, "modulate", Color(1, 1, 1), 0.3)

func _on_piece_mouse_entered(piece):
	# se resalta pieza al pasar el mouse
	piece.modulate = Color(1.2, 1.2, 1.2)

func _on_piece_mouse_exited(piece):
	# se quita el resaltado
	piece.modulate = Color(1, 1, 1)

func check_solution():
	# verifica que todas las piezas existan
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if not get_node_or_null("Piece_%d_%d" % [x, y]):
				return false
	
	# verifica las relaciones entre piezas
	var reference_piece = get_node("Piece_0_0")
	var correct_spacing_x = piece_size.x + piece_spacing
	var correct_spacing_y = piece_size.y + piece_spacing
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var current_piece = get_node("Piece_%d_%d" % [x, y])
			
			# verifica pieza a la izquierda (si existe)
			if x > 0:
				var left_piece = get_node("Piece_%d_%d" % [x-1, y])
				if abs((current_piece.position.x - left_piece.position.x) - correct_spacing_x) > 20:
					return false
			
			# verifica pieza arriba (si existe)
			if y > 0:
				var top_piece = get_node("Piece_%d_%d" % [x, y-1])
				if abs((current_piece.position.y - top_piece.position.y) - correct_spacing_y) > 20:
					return false
	
	return true


func _on_volver_pressed() -> void:
	
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")
	
