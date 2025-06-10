extends Node2D

# Variables configurables
var original_texture: Texture2D
var show_complete_time = 4.0  # Tiempo que se muestra la imagen completa
var grid_size = Vector2(2, 2)  # Tamaño del grid del rompecabezas (2x2)
var piece_spacing = 5  # Espacio entre piezas
var shuffle_strength = 200  # Cuánto se mezclan las piezas

# Variables de control
var is_showing_complete = true
var screen_center: Vector2
var piece_size: Vector2
var puzzle_pieces = []
var selected_piece: Sprite2D = null
var piece_offset: Vector2 = Vector2.ZERO
var puzzle_solved = false

func _ready():
	
	# Cargar la im agen (cambia por tu ruta)
	original_texture = preload("res://assets/backgrounds/sunny.png")
	
	# Obtener el centro de la pantalla
	screen_center = get_viewport_rect().size / 2
	
	# Mostrar la imagen completa centrada
	show_complete_image()
	
	# Temporizador para cambiar a las piezas
	var timer = get_tree().create_timer(show_complete_time)
	timer.timeout.connect(create_puzzle_pieces)

func show_complete_image():
	# Limpiar cualquier elemento existente
	for child in get_children():
		if child.name != "volver":
			child.queue_free()
	
	# Crear sprite con la imagen completa centrada
	var full_image = Sprite2D.new()
	full_image.texture = original_texture
	full_image.position = screen_center
	full_image.centered = true
	
	# Escalar si es necesario (opcional)
	var max_size = get_viewport_rect().size * 0.8  # 80% del tamaño de pantalla
	var scale_factor = min(
		max_size.x / original_texture.get_width(),
		max_size.y / original_texture.get_height()
	)
	full_image.scale = Vector2(scale_factor, scale_factor)
	
	add_child(full_image)
	is_showing_complete = true

func create_puzzle_pieces():
	
	# Limpiar la imagen completa
	for child in get_children():
		if child.name != "volver":  # Asigna un nombre único al fondo
			child.queue_free()
	
	is_showing_complete = false
	puzzle_solved = false
	
	# Calcular tamaño de cada pieza (basado en la imagen original escalada)
	var texture_size = original_texture.get_size() * get_children()[0].scale if get_child_count() > 0 else original_texture.get_size()
	piece_size = texture_size / grid_size
	
	# Crear piezas alrededor del centro
	var start_pos = screen_center - (piece_size * grid_size / 2)
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			# Crear AtlasTexture para cada pieza
			var atlas = AtlasTexture.new()
			atlas.atlas = original_texture
			atlas.region = Rect2(
				x * piece_size.x / get_children()[0].scale.x if get_child_count() > 0 else x * piece_size.x,
				y * piece_size.y / get_children()[0].scale.y if get_child_count() > 0 else y * piece_size.y,
				piece_size.x / get_children()[0].scale.x if get_child_count() > 0 else piece_size.x,
				piece_size.y / get_children()[0].scale.y if get_child_count() > 0 else piece_size.y
			)
			
			# Crear sprite para la pieza
			var piece = Sprite2D.new()
			piece.texture = atlas
			piece.centered = true
			piece.position = start_pos + Vector2(
				x * (piece_size.x + piece_spacing),
				y * (piece_size.y + piece_spacing)
			)
			if get_child_count() > 0:
				piece.scale = get_children()[0].scale  # Misma escala que la imagen completa
			piece.name = "Piece_%d_%d" % [x, y]
			
			# Añadir área clickeable para arrastrar
			setup_draggable_piece(piece)
			
			add_child(piece)
			puzzle_pieces.append(piece)
	
	# Mezclar las piezas alrededor del centro
	shuffle_pieces()

func setup_draggable_piece(piece: Sprite2D):
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	collision.shape = RectangleShape2D.new()
	collision.shape.size = piece_size / piece.scale if piece.scale != Vector2.ZERO else piece_size
	area.add_child(collision)
	
	# Conectar señales de input
	area.input_event.connect(_on_piece_input_event.bind(piece))
	area.mouse_entered.connect(_on_piece_mouse_entered.bind(piece))
	area.mouse_exited.connect(_on_piece_mouse_exited.bind(piece))
	
	piece.add_child(area)

func shuffle_pieces():
	for piece in puzzle_pieces:
		# Mover piezas aleatoriamente alrededor del centro
		var random_offset = Vector2(
			randf_range(-shuffle_strength, shuffle_strength),
			randf_range(-shuffle_strength, shuffle_strength)
		)
		piece.position = screen_center + random_offset

func _on_piece_input_event(viewport, event, shape_idx, piece):
	 # Manejo de eventos de inicio (touch o click)
	if (event is InputEventScreenTouch and event.pressed) or \
		(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		
			selected_piece = piece
			piece_offset = piece.global_position - event.global_position
			piece.z_index = 1  # Traer al frente
	
	# Manejo de eventos de fin (touch o click)
	elif (event is InputEventScreenTouch and not event.pressed) or \
		(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed):
		
		if selected_piece:
			selected_piece.z_index = 0
			selected_piece = null
			if check_solution() and not puzzle_solved:
				puzzle_solved = true
				print("¡Felicidades! Has completado el rompecabezas correctamente.")
	
	# Manejo de movimiento (drag o mouse motion)
	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and selected_piece:
		selected_piece.global_position = event.global_position + piece_offset
	
func show_puzzle_complete_effect():
	# Efecto visual sutil al completar (sin cambiar escalas)
	for piece in puzzle_pieces:
		var tween = create_tween()
		tween.tween_property(piece, "modulate", Color(0.9, 1.0, 0.9), 0.2)
		tween.tween_property(piece, "modulate", Color(1, 1, 1), 0.3)
func _on_piece_mouse_entered(piece):
	# Resaltar pieza al pasar el mouse (opcional)
	piece.modulate = Color(1.2, 1.2, 1.2)

func _on_piece_mouse_exited(piece):
	# Quitar resaltado
	piece.modulate = Color(1, 1, 1)

# Función para verificar si el puzzle está resuelto



# Función para verificar si el puzzle está resuelto (versión mejorada)
func check_solution():
	# Primero verifica que todas las piezas existan
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if not get_node_or_null("Piece_%d_%d" % [x, y]):
				return false
	
	# Ahora verifica las relaciones entre piezas
	var reference_piece = get_node("Piece_0_0")
	var correct_spacing_x = piece_size.x + piece_spacing
	var correct_spacing_y = piece_size.y + piece_spacing
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var current_piece = get_node("Piece_%d_%d" % [x, y])
			
			# Verificar pieza a la izquierda (si existe)
			if x > 0:
				var left_piece = get_node("Piece_%d_%d" % [x-1, y])
				if abs((current_piece.position.x - left_piece.position.x) - correct_spacing_x) > 20:
					return false
			
			# Verificar pieza arriba (si existe)
			if y > 0:
				var top_piece = get_node("Piece_%d_%d" % [x, y-1])
				if abs((current_piece.position.y - top_piece.position.y) - correct_spacing_y) > 20:
					return false
	
	return true
