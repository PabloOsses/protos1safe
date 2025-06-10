extends Control

# Configuración
const NUMERO_OBJETOS := 10
const RANGO_NUMEROS := 8  # Números del 0 al 7
const MARGEN := 100  # Margen mínimo de los bordes
const DISTANCIA_MINIMA := 150  # Distancia mínima entre números
const GRUPO_DETECCION := "detectable_labels"

# Variables de estado
var posiciones_ocupadas := []  # Para mantener registro de posiciones usadas


#-------------
var num_objetivo: int



func _ready():
	
	generar_numeros_aleatorios()
	generar_numero_objetivo()
	
func generar_numero_objetivo():
	#await get_tree().create_timer(0.1).timeout  # Pequeño retardo
	randomize()
	num_objetivo= randi_range(1, 7)
	print("--------------------------------")
	print("test3_flag: "+str(num_objetivo))
	pass
# Función principal de generación
func generar_numeros_aleatorios():
	if get_child_count() == 0:
		generar_numeros_completos()
	else:
		reemplazar_numeros_faltantes()

# Generación inicial completa
func generar_numeros_completos():
	# Limpiar cualquier número existente
	for child in get_children():
		if child.name.begins_with("Numero_"):
			child.queue_free()
	
	posiciones_ocupadas.clear()
	
	var spawn_rect = calcular_area_spawn()
	
	for i in range(NUMERO_OBJETOS):
		crear_numero_aleatorio(i, spawn_rect)

# Reemplaza solo los números faltantes
func reemplazar_numeros_faltantes():
	var indices_faltantes = calcular_indices_faltantes()
	if indices_faltantes.is_empty():
		return
	
	var spawn_rect = calcular_area_spawn()
	
	for indice in indices_faltantes:
		crear_numero_aleatorio(indice, spawn_rect)

# Crea un número individual
func crear_numero_aleatorio(indice: int, spawn_rect: Rect2):
	var numero_node = Node2D.new()
	numero_node.name = "Numero_%d" % indice
	
	# Configurar el Label
	var label = Label.new()
	configurar_label(label)
	
	# Configurar fondo
	var background = ColorRect.new()
	configurar_fondo(background)
	
	# Construir jerarquía
	numero_node.add_child(background)
	numero_node.add_child(label)
	
	# Posicionamiento
	var posicion = encontrar_posicion_valida(spawn_rect)
	if posicion:
		numero_node.position = posicion
		posiciones_ocupadas.append(posicion)
		add_child(numero_node)
		animar_aparicion(numero_node)
	else:
		numero_node.queue_free()
		push_warning("No se encontró posición válida para el número %d" % indice)

# Configuración del Label
func configurar_label(label: Label):
	label.text = str(randi() % RANGO_NUMEROS)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(80, 80)
	label.add_theme_font_size_override("font_size", 40)
	label.add_to_group(GRUPO_DETECCION)

# Configuración del fondo
func configurar_fondo(background: ColorRect):
	background.color = Color(0.2, 0.2, 0.8, 0.7)
	background.size = Vector2(100, 100)

# Encuentra posición válida para nuevo número
func encontrar_posicion_valida(spawn_rect: Rect2) -> Vector2:
	var intentos = 0
	var max_intentos = 50
	
	while intentos < max_intentos:
		var nueva_pos = Vector2(
			randf_range(spawn_rect.position.x, spawn_rect.end.x),
			randf_range(spawn_rect.position.y+(spawn_rect.end.y*0.15), spawn_rect.end.y-(spawn_rect.end.y*0.15))
		)
		
		var posicion_valida = true
		for pos in posiciones_ocupadas:
			if nueva_pos.distance_to(pos) < DISTANCIA_MINIMA:
				posicion_valida = false
				break
		
		if posicion_valida:
			return nueva_pos
		
		intentos += 1
	
	return Vector2.ZERO

# Calcula área disponible para spawn
func calcular_area_spawn() -> Rect2:
	var viewport_size = get_viewport_rect().size
	return Rect2(
		Vector2(MARGEN, MARGEN),
		viewport_size - Vector2(MARGEN * 2, MARGEN * 2)
	)

# Encuentra qué números faltan
func calcular_indices_faltantes() -> Array:
	var indices_faltantes = []
	var numeros_existentes = obtener_numeros_existentes()
	
	for i in range(NUMERO_OBJETOS):
		if not numeros_existentes.has("Numero_%d" % i):
			indices_faltantes.append(i)
	
	return indices_faltantes

# Obtiene números actuales
func obtener_numeros_existentes() -> Dictionary:
	var numeros = {}
	for child in get_children():
		if child.name.begins_with("Numero_"):
			numeros[child.name] = true
	return numeros

# Animación de aparición
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
	
	# Eliminar la posición del nodo de las ocupadas
	var index = posiciones_ocupadas.find(numero_node.position)
	if index != -1:
		posiciones_ocupadas.remove_at(index)
	
	# Animación de eliminación
	var tween = create_tween()
	tween.tween_property(numero_node, "scale", Vector2(0.1, 0.1), 0.3)
	tween.tween_property(numero_node, "modulate:a", 0.0, 0.3)
	tween.tween_callback(numero_node.queue_free)
	
	# Generar nuevo número en posición aleatoria después de eliminar
	tween.tween_callback(reemplazar_numeros_faltantes)
# Reemplaza un número en posición específica

func reemplazar_numero_en_posicion(posicion: Vector2):
	# Encontrar índice faltante
	var indices_faltantes = calcular_indices_faltantes()
	if indices_faltantes.is_empty():
		return
	
	var indice = indices_faltantes[0]
	var spawn_rect = calcular_area_spawn()
	
	# Crear nuevo número en posición fija
	var numero_node = Node2D.new()
	numero_node.name = "Numero_%d" % indice
	numero_node.position = posicion
	
	# Configurar componentes
	var label = Label.new()
	configurar_label(label)
	
	var background = ColorRect.new()
	configurar_fondo(background)
	
	# Construir y animar
	numero_node.add_child(background)
	numero_node.add_child(label)
	add_child(numero_node)
	animar_aparicion(numero_node)
	
	# Actualizar posiciones ocupadas
	posiciones_ocupadas.append(posicion)

# Regenerar todos los números (para botón)
func _on_boton_regenerar_pressed():
	generar_numeros_completos()
