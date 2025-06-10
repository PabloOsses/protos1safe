extends Control

# variables de dibujo
var drawing := false
var current_line : Line2D
var current_polygon : Polygon2D
var closure_threshold := 500.0

# variables de estado
var detected_labels := []
var test3 : Node
var procesando_seleccion := false
var incremento_barra=20
var detener_juego_3


@onready var background_resumen = $pantallaresumen/backgroundResumen
@onready var texto_resumen = $pantallaresumen/textoResumen
@onready var health_bar = $HealthBar
@onready var heart_counter = $HeartCounter
@onready var label_instruccion = $LabelCalculo

func _ready():
	print("JUEGO 3")
	detener_juego_3=false
	Musica.reproducir("nivel_3")
	background_resumen.visible = false
	texto_resumen.visible = false
	health_bar.min_value = 0.0
	health_bar.max_value = 100
	health_bar.value = 0
	#--------------
	if Globales.dificultad == "facil":
		print("facil")
		
	elif Globales.dificultad == "medio":
		print("medio")
		heart_counter.set_value(3)
	elif Globales.dificultad == "dificil":
		print("dificil")
		heart_counter.set_value(3)
		incremento_barra=15
	else:
		print("facil")
	#--------------
	test3 = get_node_or_null("game_test3")
	if not test3:
		push_error("No se encontró game_test3")
		return
	
	actualizar_ui_objetivo()

func actualizar_ui_objetivo():
	label_instruccion.text = "Agrupa números para que sumen: " + str(test3.num_objetivo)

func _process(delta):
	if health_bar.value == 100 or heart_counter.counter <= 0:
		if detener_juego_3!=true:
			calculo_puntaje_final()
			fin_del_juego()
			Globales.f_logro_2(2)
		detener_juego_3=true
func _input(event):
	if procesando_seleccion:
		return
		
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			start_drawing(event.position)
		elif drawing:
			stop_drawing()
	
	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and drawing:
		continue_drawing(event.position)

# funciones de dibujo
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
	if not drawing or not current_line or current_line.points.size() < 10:
		drawing = false
		return
	
	procesando_seleccion = true
	
	if is_shape_closed(current_line.points):
		current_line.default_color = Color.GREEN
		create_polygon_from_points(current_line.points)
		await detect_labels_inside_area()
	
	drawing = false
	procesando_seleccion = false

func clear_previous_drawing():
	if current_polygon:
		remove_child(current_polygon)
		current_polygon.queue_free()
		current_polygon = null
	
	if current_line:
		remove_child(current_line)
		current_line.queue_free()
		current_line = null
	
	for label in detected_labels:
		if is_instance_valid(label):
			highlight_label(label, false)
	detected_labels.clear()

func is_shape_closed(points: PackedVector2Array) -> bool:
	return points.size() >= 3 && points[0].distance_to(points[-1]) < closure_threshold

func create_polygon_from_points(points: PackedVector2Array):
	if current_polygon:
		remove_child(current_polygon)
		current_polygon.queue_free()
	
	current_polygon = Polygon2D.new()
	current_polygon.color = Color(0, 1, 0, 0.3)
	current_polygon.polygon = points
	add_child(current_polygon)

# lógica de detección
func detect_labels_inside_area():
	if not current_polygon or current_polygon.polygon.size() < 3:
		return
	
	var all_labels = get_tree().get_nodes_in_group("detectable_labels")
	if all_labels.is_empty():
		return
	
	detected_labels.clear()
	var valores = []
	
	for label in all_labels:
		if label is Label:
			var rect = label.get_global_rect()
			var label_center = rect.position + (rect.size / 2)
			
			if Geometry2D.is_point_in_polygon(label_center, current_polygon.polygon):
				detected_labels.append(label)
				valores.append(int(label.text))
				highlight_label(label, true)
	
	if not detected_labels.is_empty():
		await procesar_seleccion(valores)
	
	# limpieza final
	clear_previous_drawing()

func procesar_seleccion(valores: Array):
	var total = 0
	for num in valores:
		total += num
	
	print("Números detectados: ", valores)
	print("Suma total: ", total)
	print("Objetivo actual: ", test3.num_objetivo)
	
	if total == test3.num_objetivo:
		respuesta_correcta()
	else:
		respuesta_incorrecta()
	
	# eliminar numeros seleccionados
	await eliminar_labels_detectados()
	
	# generar nuevo objetivo despues de eliminar los números
	test3.generar_numero_objetivo()
	actualizar_ui_objetivo()

func eliminar_labels_detectados():
	if detected_labels.is_empty():
		return
	
	var tween = create_tween()
	var labels_a_eliminar = detected_labels.duplicate()
	
	for i in range(labels_a_eliminar.size()):
		var label = labels_a_eliminar[i]
		if not is_instance_valid(label):
			continue
			
		var parent = label.get_parent()
		tween.parallel().tween_property(label, "modulate:a", 0.0, 0.2).set_delay(i * 0.1)
		tween.parallel().tween_property(label, "scale", Vector2(0.1, 0.1), 0.2).set_delay(i * 0.1)
		
		if parent and parent.name.begins_with("Numero_") and test3:
			tween.tween_callback(test3.eliminar_y_reemplazar_numero.bind(parent)).set_delay(i * 0.1 + 0.2)
	
	await tween.finished
	detected_labels.clear()

# funciones de respuesta
func respuesta_correcta():
	RondasManager.game3_puntaje_total += 1
	health_bar.value += incremento_barra
	$positivo.play()
	print("CORRECTO")

func respuesta_incorrecta():
	heart_counter.decrease()
	$negativo.play()
	print("INCORRECTO")

func highlight_label(label: Label, enable: bool):
	if enable:
		label.add_theme_color_override("font_color", Color.RED)
	else:
		label.remove_theme_color_override("font_color")
func calculo_puntaje_final():
	Globales.f_logro_1()
	print("CALCULO PUNTAJE: " + str(Globales.dificultad))
	print("CALCULO PUNTAJE: " + str(RondasManager.game3_puntaje_total))
	if Globales.dificultad == "facil":
		if heart_counter.counter ==5:
			Globales.juegos_sin_perder_vidas+=1
		RondasManager.game3_puntaje_total=RondasManager.game3_puntaje_total*1
		Globales.acumular_puntuacion(Globales.usuario_email,7,RondasManager.game3_puntaje_total)
	elif Globales.dificultad == "medio":
		if heart_counter.counter ==3:
			Globales.juegos_sin_perder_vidas+=1
		RondasManager.game3_puntaje_total=RondasManager.game3_puntaje_total*1.5
		Globales.acumular_puntuacion(Globales.usuario_email,8,RondasManager.game3_puntaje_total)
	elif Globales.dificultad == "dificil":
		if heart_counter.counter ==3:
			Globales.juegos_sin_perder_vidas+=1
		Globales.f_logro_3()
		RondasManager.game3_puntaje_total=RondasManager.game3_puntaje_total*2
		Globales.acumular_puntuacion(Globales.usuario_email,9,RondasManager.game3_puntaje_total)
	else:
		RondasManager.game3_puntaje_total=RondasManager.game3_puntaje_total*1
func fin_del_juego():
	background_resumen.top_level = true
	texto_resumen.top_level = true
	background_resumen.visible = true
	texto_resumen.visible = true
	texto_resumen.text = "Puntaje: " + str(RondasManager.game3_puntaje_total)
	
	var tween = get_tree().create_tween()
	tween.tween_property(background_resumen, "modulate:a", 1.0, 1.5)
	tween.parallel().tween_property(texto_resumen, "modulate:a", 1.0, 1.5)
	
	await get_tree().create_timer(3.0).timeout
	RondasManager.reiniciar_game3()
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")
	pass # Replace with function body.
