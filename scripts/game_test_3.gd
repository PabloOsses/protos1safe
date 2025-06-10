#extends Control
#
## Configuración
#const NUMERO_OBJETOS := 10
#const RANGO_NUMEROS := 8  # 0-7
#const MARGEN := 100  # Margen mínimo de los bordes
#const DISTANCIA_MINIMA := 120  # Distancia mínima entre números
#const GRUPO_DETECCION := "detectable_labels"
#
#func _ready():
	#generar_numeros_aleatorios()
#
#func generar_numeros_aleatorios():
	## Limpiar números existentes
	#for child in get_children():
		#if child.name.begins_with("Numero_"):
			#child.queue_free()
	#
	## Obtener área disponible
	#var viewport_size = get_viewport_rect().size
	#var spawn_rect = Rect2(
		#Vector2(MARGEN, MARGEN),
		#viewport_size - Vector2(MARGEN * 2, MARGEN * 2)
	#)
	#
	#var posiciones_usadas = []
	#
	#for i in range(NUMERO_OBJETOS):
		## Crear contenedor
		#var numero_node = Node2D.new()
		#numero_node.name = "Numero_%d" % i
		#
		## Crear Label
		#var label = Label.new()
		#label.text = str(randi() % RANGO_NUMEROS)
		#label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		#label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		#label.size = Vector2(80, 80)
		#label.add_theme_font_size_override("font_size", 40)
		#label.add_to_group(GRUPO_DETECCION)  # Añadir al grupo de detección
		#
		## Crear fondo (opcional)
		#var background = ColorRect.new()
		#background.color = Color(0.2, 0.2, 0.8, 0.7)
		#background.size = Vector2(100, 100)
		#
		## Configurar jerarquía
		#numero_node.add_child(background)
		#numero_node.add_child(label)
		#
		## Posicionamiento sin superposición
		#var posicion_valida = false
		#var intentos = 0
		#var max_intentos = 20
		#var nueva_pos = Vector2.ZERO
		#
		#while not posicion_valida and intentos < max_intentos:
			#nueva_pos = Vector2(
				#randf_range(spawn_rect.position.x, spawn_rect.end.x),
				#randf_range(spawn_rect.position.y, spawn_rect.end.y)
			#)
			#
			#posicion_valida = true
			#for pos in posiciones_usadas:
				#if nueva_pos.distance_to(pos) < DISTANCIA_MINIMA:
					#posicion_valida = false
					#break
			#
			#intentos += 1
		#
		#if posicion_valida:
			#numero_node.position = nueva_pos
			#posiciones_usadas.append(nueva_pos)
			#add_child(numero_node)
			#
			## Animación de aparición
			#animar_aparicion(numero_node)
		#else:
			#numero_node.queue_free()
			#print("No se encontró posición válida para el número ", i)
#
#func animar_aparicion(nodo: Node2D):
	#nodo.scale = Vector2(0.1, 0.1)
	#nodo.modulate = Color(1, 1, 1, 0)
	#
	#var tween = create_tween().set_parallel(true)
	#tween.tween_property(nodo, "scale", Vector2(1, 1), 0.5)\
		#.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	#tween.tween_property(nodo, "modulate", Color(1, 1, 1, 1), 0.3)\
		#.set_trans(Tween.TRANS_SINE)
#
## Función para regenerar números (conectar a botón si es necesario)
#func _on_boton_regenerar_pressed():
	#generar_numeros_aleatorios()
extends Control

# Configuración
const NUMERO_OBJETOS := 10
const RANGO_NUMEROS := 8  # 0-7
const MARGEN := 100  # Margen mínimo de los bordes
const DISTANCIA_MINIMA := 120  # Distancia mínima entre números
const GRUPO_DETECCION := "detectable_labels"

func _ready():
	generar_numeros_aleatorios()

func generar_numeros_aleatorios():
	# Solo generar nuevos números si no hay ninguno
	if get_child_count() == 0:
		generar_numeros_completos()
	else:
		# Solo reemplazar los que faltan
		reemplazar_numeros_faltantes()

func generar_numeros_completos():
	# Limpiar números existentes (solo en primera generación)
	for child in get_children():
		if child.name.begins_with("Numero_"):
			child.queue_free()
	
	# Obtener área disponible
	var viewport_size = get_viewport_rect().size
	var spawn_rect = Rect2(
		Vector2(MARGEN, MARGEN),
		viewport_size - Vector2(MARGEN * 2, MARGEN * 2)
	)
	
	var posiciones_usadas = []
	
	for i in range(NUMERO_OBJETOS):
		crear_numero_aleatorio(i, spawn_rect, posiciones_usadas)

func reemplazar_numeros_faltantes():
	var numeros_actuales = obtener_numeros_existentes()
	var indices_faltantes = []
	
	# Encontrar qué índices faltan
	for i in range(NUMERO_OBJETOS):
		if not numeros_actuales.has("Numero_%d" % i):
			indices_faltantes.append(i)
	
	if indices_faltantes.is_empty():
		return
	
	# Obtener área disponible
	var viewport_size = get_viewport_rect().size
	var spawn_rect = Rect2(
		Vector2(MARGEN, MARGEN),
		viewport_size - Vector2(MARGEN * 2, MARGEN * 2)
	)
	
	var posiciones_usadas = obtener_posiciones_existentes()
	
	for i in indices_faltantes:
		crear_numero_aleatorio(i, spawn_rect, posiciones_usadas)

func crear_numero_aleatorio(indice: int, spawn_rect: Rect2, posiciones_usadas: Array):
	# Crear contenedor
	var numero_node = Node2D.new()
	numero_node.name = "Numero_%d" % indice
	
	# Crear Label
	var label = Label.new()
	label.text = str(randi() % RANGO_NUMEROS)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(80, 80)
	label.add_theme_font_size_override("font_size", 40)
	label.add_to_group(GRUPO_DETECCION)
	
	# Crear fondo (opcional)
	var background = ColorRect.new()
	background.color = Color(0.2, 0.2, 0.8, 0.7)
	background.size = Vector2(100, 100)
	
	# Configurar jerarquía
	numero_node.add_child(background)
	numero_node.add_child(label)
	
	# Posicionamiento sin superposición
	var posicion_valida = false
	var intentos = 0
	var max_intentos = 20
	var nueva_pos = Vector2.ZERO
	
	while not posicion_valida and intentos < max_intentos:
		nueva_pos = Vector2(
			randf_range(spawn_rect.position.x, spawn_rect.end.x),
			randf_range(spawn_rect.position.y, spawn_rect.end.y)
		)
		
		posicion_valida = true
		for pos in posiciones_usadas:
			if nueva_pos.distance_to(pos) < DISTANCIA_MINIMA:
				posicion_valida = false
				break
		
		intentos += 1
	
	if posicion_valida:
		numero_node.position = nueva_pos
		posiciones_usadas.append(nueva_pos)
		add_child(numero_node)
		
		# Animación de aparición
		animar_aparicion(numero_node)
	else:
		numero_node.queue_free()
		print("No se encontró posición válida para el número ", indice)

func obtener_numeros_existentes() -> Dictionary:
	var numeros = {}
	for child in get_children():
		if child.name.begins_with("Numero_"):
			numeros[child.name] = true
	return numeros

func obtener_posiciones_existentes() -> Array:
	var posiciones = []
	for child in get_children():
		if child.name.begins_with("Numero_"):
			posiciones.append(child.position)
	return posiciones

func animar_aparicion(nodo: Node2D):
	nodo.scale = Vector2(0.1, 0.1)
	nodo.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(nodo, "scale", Vector2(1, 1), 0.5)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(nodo, "modulate", Color(1, 1, 1, 1), 0.3)\
		.set_trans(Tween.TRANS_SINE)

func eliminar_y_reemplazar_numero(numero_node: Node2D):
	var indice = numero_node.name.split("_")[1].to_int()
	
	# Animación de eliminación
	var tween = create_tween()
	tween.tween_property(numero_node, "scale", Vector2(0.1, 0.1), 0.3)
	tween.tween_property(numero_node, "modulate:a", 0.0, 0.3)
	tween.tween_callback(numero_node.queue_free)
	
	# Reemplazar después de la animación
	tween.tween_callback(reemplazar_numeros_faltantes)

func _on_boton_regenerar_pressed():
	reemplazar_numeros_faltantes()
