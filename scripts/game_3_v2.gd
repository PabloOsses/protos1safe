extends Control

# Variables de dibujo
var drawing := false
var current_line : Line2D
var current_polygon : Polygon2D
var closure_threshold := 500.0

# Variables de detección
var detected_labels := []
var test3 : Node
#
@onready var background_resumen= $pantallaresumen/backgroundResumen
@onready var texto_resumen=$pantallaresumen/textoResumen
@onready var health_bar=$HealthBar
@onready var heart_counter = $HeartCounter
#------

var label_instruccion : Label

# TO DO: alrededor linea 165
func _ready():
	background_resumen.visible = false
	texto_resumen.visible = false
	health_bar.min_value=0.0
	health_bar.max_value=100
	health_bar.value=0
	Musica.reproducir("nivel_3")
	# Configurar referencia al script de números
	await get_tree().process_frame  # Esperar que la escena esté lista
	test3 = get_node_or_null("game_test3")
	
	update_label_objetivo()
	#print("game_3: "+str(test3.num_objetivo))
	#label_instruccion=$LabelCalculo
	#label_instruccion.text="Agrupa numeros para que sumen: " +str(test3.num_objetivo)
	
	if not test3:
		push_warning("No se encontró game_test3 - La regeneración de números no funcionará")

func _process(delta: float) -> void:
	if health_bar.value !=100 and heart_counter.counter>0:
		#print("no aplica R")
		pass
	else:
		fin_del_juego()
		
func fin_del_juego():
	background_resumen.top_level=true
	texto_resumen.top_level=true
		
		
	background_resumen.visible = true
	texto_resumen.visible = true
	texto_resumen.text="Puntaje: " + str(RondasManager.game3_puntaje_total)
	
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
	
func update_label_objetivo():
	print("game_3: "+str(test3.num_objetivo))
	label_instruccion=$LabelCalculo
	label_instruccion.text="Agrupa numeros para que sumen: " +str(test3.num_objetivo)
	pass

func _input(event):
	# Manejo de input para dibujar
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			start_drawing(event.position)
		else:
			stop_drawing()
	
	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and drawing:
		continue_drawing(event.position)

# Funciones de dibujo
func start_drawing(position: Vector2):
	drawing = true
	clear_previous_drawing()
	
	current_line = Line2D.new()
	current_line.width = 5.0
	current_line.default_color = Color.RED
	add_child(current_line)
	current_line.add_point(position)

func continue_drawing(position: Vector2):
	if current_line:
		current_line.add_point(position)

func stop_drawing():
	if current_line and current_line.points.size() > 10:
		var is_closed = is_shape_closed(current_line.points)
		if is_closed:
			current_line.default_color = Color.GREEN
			create_polygon_from_points(current_line.points)
			detect_labels_inside_area()
	drawing = false

func clear_previous_drawing():
	if current_polygon:
		remove_child(current_polygon)
		current_polygon.queue_free()
		current_polygon = null
	
	if current_line:
		remove_child(current_line)
		current_line.queue_free()
		current_line = null
	
	# Resetear labels detectados
	for label in detected_labels:
		if is_instance_valid(label):
			highlight_label(label, false)
	detected_labels.clear()

func is_shape_closed(points: PackedVector2Array) -> bool:
	if points.size() < 3: return false
	return points[0].distance_to(points[-1]) < closure_threshold

func create_polygon_from_points(points: PackedVector2Array):
	if current_polygon:
		remove_child(current_polygon)
		current_polygon.queue_free()
	
	current_polygon = Polygon2D.new()
	current_polygon.color = Color(0, 1, 0, 0.3)  # Verde semitransparente
	current_polygon.polygon = points
	add_child(current_polygon)

# Funciones de detección y manejo de labels
func detect_labels_inside_area():
	if not current_polygon or current_polygon.polygon.size() < 3:
		return
	
	var all_labels = get_tree().get_nodes_in_group("detectable_labels")
	if all_labels.is_empty():
		all_labels = find_all_labels_in_scene()
	
	detected_labels = []
	var valores_label = []
	
	# Detectar labels dentro del área
	for label in all_labels:
		if label is Label:
			var rect = label.get_global_rect()
			var label_center = rect.position + (rect.size / 2)
			
			if is_point_in_polygon(label_center):
				detected_labels.append(label)
				valores_label.append(int(label.text))
				highlight_label(label, true)
	
	# Procesar resultados
	if not detected_labels.is_empty():
		process_detected_labels(valores_label)

func process_detected_labels(valores: Array):
	print("Numeros detectados: ", valores)
	es_valor_objetivo(valores)
	await get_tree().process_frame
	eliminar_labels_detectados()

func eliminar_labels_detectados():
	var tween = create_tween()
	
	for i in range(detected_labels.size()):
		var label = detected_labels[i]
		if is_instance_valid(label):
			var parent = label.get_parent()
			
			# Animación de eliminación
			tween.parallel().tween_property(label, "modulate:a", 0.0, 0.2).set_delay(i * 0.1)
			tween.parallel().tween_property(label, "scale", Vector2(0.1, 0.1), 0.2).set_delay(i * 0.1)
			
			# Eliminar y reemplazar si es un número
			if parent and parent.name.begins_with("Numero_") and test3:
				tween.tween_callback(test3.eliminar_y_reemplazar_numero.bind(parent)).set_delay(i * 0.1 + 0.2)
			else:
				tween.tween_callback(label.queue_free).set_delay(i * 0.1 + 0.2)
	
	tween.tween_callback(func(): detected_labels.clear())

# Funciones auxiliares
func es_valor_objetivo(valores: Array):
	var total = 0
	for num in valores:
		total += num
	print("Suma total: ", total)
	
	# Guardar el objetivo actual antes de generar uno nuevo
	var objetivo_actual = test3.num_objetivo
	
	if total == objetivo_actual:  # Usar el valor guardado
		respuesta_correcta()
	else:
		respuesta_incorrecta()
	
	# Generar nuevo objetivo después de la validación
	test3.generar_numero_objetivo()
	update_label_objetivo()

func respuesta_correcta():
	RondasManager.game3_puntaje_total += 1
	print("CORRECTO")
	$positivo.play()
	health_bar.value=health_bar.value+20
	pass
	
func respuesta_incorrecta():
	print("motssarrelia")
	heart_counter.decrease()
	$negativo.play()
	print("INCORRECTO")
	pass

func find_all_labels_in_scene() -> Array:
	var labels = []
	find_labels_recursive(get_tree().root, labels)
	return labels

func find_labels_recursive(node: Node, result: Array):
	if node is Label:
		result.append(node)
	for child in node.get_children():
		find_labels_recursive(child, result)

func is_point_in_polygon(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, current_polygon.polygon)

func highlight_label(label: Label, enable: bool):
	if enable:
		label.add_theme_color_override("font_color", Color.RED)
		label.add_theme_font_size_override("font_size", 40)
	else:
		label.remove_theme_color_override("font_color")
		label.remove_theme_font_size_override("font_size")

func _on_boton_verificar_pressed():
	if current_line:
		stop_drawing()


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")
	
	pass # Replace with function body.
