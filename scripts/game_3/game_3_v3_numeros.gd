extends Control

# Configuración
const NUMERO_OBJETIVOS = [7, 8, 9, 10, 11, 12, 13, 14, 15]  # Objetivos entre 3 y 15
const NUMERO_OBJETOS = 10
const RANGO_NUMEROS = 10  # Números del 1 al 10
const MARGEN = 100
const DISTANCIA_MINIMA = 150
const GRUPO_DETECCION = "detectable_labels"
const MAX_INTENTOS_POSICION = 50
const MAX_INTENTOS_COMBINACION = 20

# Variables
var posiciones_ocupadas = []
var num_objetivo: int
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	generar_numero_objetivo()
	generar_numeros_con_combinacion_valida()

func generar_numero_objetivo():
	num_objetivo = NUMERO_OBJETIVOS[rng.randi() % NUMERO_OBJETIVOS.size()]
	print("Nuevo objetivo generado: ", num_objetivo)
	return num_objetivo

func generar_numeros_con_combinacion_valida():
	# Limpiar números existentes
	for child in get_children():
		if child.name.begins_with("Numero_"):
			child.queue_free()
	
	posiciones_ocupadas.clear()
	var spawn_rect = calcular_area_spawn()
	var numeros_generados = []
	var combinacion_encontrada = false
	var intentos = 0
	
	while not combinacion_encontrada and intentos < MAX_INTENTOS_COMBINACION:
		numeros_generados.clear()
		posiciones_ocupadas.clear()
		
		# Generar al menos una combinación válida primero
		var num1 = rng.randi_range(1, num_objetivo - 1)
		var num2 = num_objetivo - num1
		numeros_generados.append(num1)
		numeros_generados.append(num2)
		
		# Generar el resto de números aleatorios
		for i in range(2, NUMERO_OBJETOS):
			numeros_generados.append(rng.randi_range(1, RANGO_NUMEROS))
		
		# Verificar si hay al menos una combinación válida
		if existe_combinacion_valida(numeros_generados, num_objetivo):
			combinacion_encontrada = true
		intentos += 1
	
	# Si después de varios intentos no se encuentra combinación, forzar una
	if not combinacion_encontrada:
		numeros_generados = []
		var num1 = rng.randi_range(1, num_objetivo - 1)
		var num2 = num_objetivo - num1
		numeros_generados.append(num1)
		numeros_generados.append(num2)
		for i in range(2, NUMERO_OBJETOS):
			numeros_generados.append(rng.randi_range(1, min(RANGO_NUMEROS, num_objetivo * 2)))
	
	# Crear los números en pantalla
	for i in range(numeros_generados.size()):
		var posicion_valida = encontrar_posicion_valida(spawn_rect)
		if posicion_valida:
			crear_numero_con_valor(i, posicion_valida, numeros_generados[i])
func crear_numero_con_valor(indice: int, posicion: Vector2, valor: int):
	var numero_node = Node2D.new()
	numero_node.name = "Numero_%d" % indice
	numero_node.position = posicion
	
	# Configurar Label
	var label = Label.new()
	label.text = str(valor)  # Usamos el valor pasado como parámetro
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(80, 80)
	label.add_theme_font_size_override("font_size", 40)
	label.add_to_group(GRUPO_DETECCION)
	
	# Configurar fondo
	var background = ColorRect.new()
	background.color = Color(0.2, 0.2, 0.8, 0.7)
	background.size = Vector2(100, 100)
	
	# Construir nodo
	numero_node.add_child(background)
	numero_node.add_child(label)
	add_child(numero_node)
	
	# Animación
	animar_aparicion(numero_node)
	posiciones_ocupadas.append(posicion)
func existe_combinacion_valida(numeros: Array, objetivo: int) -> bool:
	# Verifica combinaciones de 2 números
	for i in range(numeros.size()):
		if numeros[i] == objetivo:
			return true
		for j in range(i + 1, numeros.size()):
			if numeros[i] + numeros[j] == objetivo:
				return true
	return false
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
