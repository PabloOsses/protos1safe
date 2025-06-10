extends Control

# Configuración
# posibles numeros obj
const NUMERO_OBJETIVOS = [1, 2, 3, 4, 5, 6, 7]  # posibles numeros obj
const NUMERO_OBJETOS = 10
# esto es para numeros del 1 al 8
const RANGO_NUMEROS = 8  # esto es para numeros del 1 al 7
const MARGEN = 100
const DISTANCIA_MINIMA = 150
const GRUPO_DETECCION = "detectable_labels"
const MAX_INTENTOS_POSICION = 50  # intentos para encontrar posicion valida

# variables
var posiciones_ocupadas = []
var num_objetivo: int
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	generar_numeros_aleatorios()
	generar_numero_objetivo()

func generar_numero_objetivo():
	num_objetivo = NUMERO_OBJETIVOS[rng.randi() % NUMERO_OBJETIVOS.size()]
	print("Nuevo objetivo generado: ", num_objetivo)
	return num_objetivo

func generar_numeros_aleatorios():
	# limpiar números existentes
	for child in get_children():
		if child.name.begins_with("Numero_"):
			child.queue_free()
	
	posiciones_ocupadas.clear()
	var spawn_rect = calcular_area_spawn()
	
	# generar nuevos números
	for i in range(NUMERO_OBJETOS):
		var posicion_valida = encontrar_posicion_valida(spawn_rect)
		if posicion_valida:
			crear_numero_aleatorio(i, posicion_valida)
		else:
			push_warning("No se pudo encontrar posición válida para el número ", i)

func crear_numero_aleatorio(indice: int, posicion: Vector2):
	var numero_node = Node2D.new()
	numero_node.name = "Numero_%d" % indice
	numero_node.position = posicion
	
	# configurar Label
	var label = Label.new()
	label.text = str(rng.randi() % RANGO_NUMEROS)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(80, 80)
	label.add_theme_font_size_override("font_size", 40)
	label.add_to_group(GRUPO_DETECCION)
	
	# configurar fondo
	var background = ColorRect.new()
	background.color = Color(0.2, 0.2, 0.8, 0.7)
	background.size = Vector2(100, 100)
	
	# construir nodo
	numero_node.add_child(background)
	numero_node.add_child(label)
	add_child(numero_node)
	
	# animación
	animar_aparicion(numero_node)
	posiciones_ocupadas.append(posicion)

func encontrar_posicion_valida(spawn_rect: Rect2) -> Vector2:
	var intentos = 0
	while intentos < MAX_INTENTOS_POSICION:
		var nueva_pos = Vector2(
			rng.randf_range(spawn_rect.position.x, spawn_rect.end.x),
			rng.randf_range(spawn_rect.position.y + (spawn_rect.size.y * 0.15), 
			spawn_rect.end.y - (spawn_rect.size.y * 0.15)
		))
		
		#  distancia con otros números
		var posicion_valida = true
		for pos in posiciones_ocupadas:
			if nueva_pos.distance_to(pos) < DISTANCIA_MINIMA:
				posicion_valida = false
				break
		
		if posicion_valida:
			return nueva_pos
		
		intentos += 1
	
	return Vector2.ZERO  # SI NO SE ENCUENTRA RETORNA INVALIDO

func calcular_area_spawn() -> Rect2:
	var viewport_size = get_viewport_rect().size
	return Rect2(
		Vector2(MARGEN, MARGEN),
		viewport_size - Vector2(MARGEN * 2, MARGEN * 2)
	)

func animar_aparicion(nodo: Node2D):
	nodo.scale = Vector2(0.1, 0.1)
	nodo.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(nodo, "scale", Vector2(1, 1), 0.5)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(nodo, "modulate", Color(1, 1, 1, 1), 0.3)\
		.set_trans(Tween.TRANS_SINE)

func eliminar_y_reemplazar_numero(numero_node: Node2D):
	if not is_instance_valid(numero_node):
		return
	
	# eliminar de posiciones ocupadas
	var index = posiciones_ocupadas.find(numero_node.position)
	if index != -1:
		posiciones_ocupadas.remove_at(index)
	
	# animación de eliminacion
	var tween = create_tween()
	tween.tween_property(numero_node, "scale", Vector2(0.1, 0.1), 0.3)
	tween.tween_property(numero_node, "modulate:a", 0.0, 0.3)
	tween.tween_callback(numero_node.queue_free)
	
	# reemplazar después de eliminar
	tween.tween_callback(reemplazar_numeros_faltantes)

func reemplazar_numeros_faltantes():
	# encontrar índices faltantes
	var indices_faltantes = []
	for i in range(NUMERO_OBJETOS):
		if not has_node("Numero_%d" % i):
			indices_faltantes.append(i)
	
	if indices_faltantes.is_empty():
		return
	
	# generar nuevos números en posiciones válidas
	var spawn_rect = calcular_area_spawn()
	for indice in indices_faltantes:
		var posicion_valida = encontrar_posicion_valida(spawn_rect)
		if posicion_valida:
			crear_numero_aleatorio(indice, posicion_valida)
