#extends Control
#
#var drawing := false
#var current_line : Line2D
#var current_polygon : Polygon2D
#var closure_threshold := 50.0
#var detected_objects := []
#
#func _input(event):
	#if event is InputEventScreenTouch or event is InputEventMouseButton:
		#if event.pressed:
			#start_drawing(event.position)
		#else:
			#stop_drawing()
	#
	#if (event is InputEventMouseMotion or event is InputEventScreenDrag) and drawing:
		#continue_drawing(event.position)
#
#func start_drawing(position: Vector2):
	#drawing = true
	#current_line = Line2D.new()
	#current_line.width = 5.0
	#current_line.default_color = Color.RED
	#add_child(current_line)
	#current_line.add_point(position)
	#
	## Limpiar objetos detectados anteriores
	#detected_objects = []
#
#func continue_drawing(position: Vector2):
	#if current_line:
		#current_line.add_point(position)
#
#func stop_drawing():
	#if current_line and current_line.points.size() > 10:
		#var is_closed = is_shape_closed(current_line.points)
		#print("¿Área cerrada? ", is_closed)
		#
		#if is_closed:
			#current_line.default_color = Color.GREEN
			#create_polygon_from_points(current_line.points)
			#detect_objects_inside_area()
			#
	#drawing = false
#
#func is_shape_closed(points: PackedVector2Array) -> bool:
	#if points.size() < 3: return false
	#return points[0].distance_to(points[-1]) < closure_threshold
#
#func create_polygon_from_points(points: PackedVector2Array):
	#if current_polygon:
		#remove_child(current_polygon)
		#current_polygon.queue_free()
	#
	#current_polygon = Polygon2D.new()
	#current_polygon.color = Color(0, 1, 0, 0.3)  # Verde semitransparente
	#current_polygon.polygon = points
	#add_child(current_polygon)
#
#func detect_objects_inside_area():
	#if not current_polygon or current_polygon.polygon.size() < 3:
		#return
	#
	## Convertir el polígono a forma de colisión
	#var polygon_points = current_polygon.polygon
	#var collision_polygon = CollisionPolygon2D.new()
	#collision_polygon.polygon = polygon_points
	#
	## Crear área temporal para detección
	#var area = Area2D.new()
	#area.add_child(collision_polygon)
	#add_child(area)
	#
	## Obtener todos los objetos que se solapan con el área
	#var overlapping_bodies = area.get_overlapping_bodies()
	#var overlapping_areas = area.get_overlapping_areas()
	#
	## Combinar y filtrar resultados
	#detected_objects = []
	#detected_objects.append_array(overlapping_bodies)
	#detected_objects.append_array(overlapping_areas)
	#
	## Eliminar el área temporal
	#remove_child(area)
	#area.queue_free()
	#
	## Mostrar resultados
	#print("Objetos detectados dentro del área: ", detected_objects.size())
	#for obj in detected_objects:
		#print(" - ", obj.name)
		## Resaltar objetos detectados (opcional)
		#if obj.has_method("highlight"):
			#obj.highlight(true)
	#
	## $FeedbackLabel.text = "Objetos detectados: %d" % detected_objects.size()
#
#func _on_boton_verificar_pressed():
	#print("Verificando forma...")
	#if current_line:
		#stop_drawing()
		
extends Control

var drawing := false
var current_line : Line2D
var current_polygon : Polygon2D
var closure_threshold := 50.0  # Máxima distancia para considerar "cerrado"
var detected_labels := []
var test3

func _ready() -> void:
	test3 = $game_test3
	pass
func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			start_drawing(event.position)
		else:
			stop_drawing()
	
	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and drawing:
		continue_drawing(event.position)

func start_drawing(position: Vector2):
	drawing = true
	clear_previous_drawing()
	
	current_line = Line2D.new()
	current_line.width = 5.0
	current_line.default_color = Color.RED
	add_child(current_line)
	current_line.add_point(position)
	
	detected_labels = []

func continue_drawing(position: Vector2):
	if current_line:
		current_line.add_point(position)

func stop_drawing():
	if current_line and current_line.points.size() > 10:
		var is_closed = is_shape_closed(current_line.points)
		print("¿Área cerrada? ", is_closed)
		
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
	
	# Restaurar color de labels previamente detectados
	for label in detected_labels:
		if is_instance_valid(label) and label is Label:
			highlight_label(label, false)
	
	detected_labels = []

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

func detect_labels_inside_area():
	if not current_polygon or current_polygon.polygon.size() < 3:
		return
	
	# Obtener todos los labels en la escena
	var all_labels = get_tree().get_nodes_in_group("detectable_labels")
	if all_labels.is_empty():
		all_labels = find_all_labels_in_scene()
	
	detected_labels = []
	
	for label in all_labels:
		if label is Label:
			var rect = label.get_global_rect()
			var label_center = rect.position + (rect.size / 2)
			
			if is_point_in_polygon(label_center):
				detected_labels.append(label)
	
	# Mostrar resultados
	var valores_label=[]
	print("Labels detectados dentro del área: ", detected_labels.size())
	for label in detected_labels:
		print(" - ", label.name, ": ", label.text)
		valores_label.append(int(label.text))
		highlight_label(label, true)
	print(valores_label)
	valor_objetivo(valores_label)
	eliminar_labels_dentro_area()
	
	for label in detected_labels:
		if is_instance_valid(label):
			var parent = label.get_parent()
			if parent and parent.name.begins_with("Numero_"):
				test3.eliminar_y_reemplazar_numero(parent)
	
		detected_labels.clear()
	
func eliminar_labels_dentro_area():
	if detected_labels.is_empty():
		
		return
	
	# Crear un tween para animaciones grupales
	var tween = create_tween()
	var deletion_delay = 0.0
	
	for label in detected_labels:
		if is_instance_valid(label):
		# Animación de desvanecimiento y escala
			tween.parallel().tween_property(label, "modulate:a", 0.0, 0.3).set_delay(deletion_delay)
			tween.parallel().tween_property(label, "scale", Vector2(0.1, 0.1), 0.3).set_delay(deletion_delay)
		
		# Eliminar el nodo padre si es un contenedor de número
			var parent = label.get_parent()
			if parent.name.begins_with("Numero_"):
				tween.tween_callback(parent.queue_free).set_delay(deletion_delay + 0.3)
			else:
				tween.tween_callback(label.queue_free).set_delay(deletion_delay + 0.3)
		
			deletion_delay += 0.05  # Pequeño escalonamiento para efecto en cascada
	
# Limpiar la lista después de eliminar
	tween.tween_callback(func(): detected_labels.clear())
	pass
	
func valor_objetivo(valores_label):
	var suma_total=0
	for num in valores_label:
		suma_total=suma_total+num
	print("TOTAL SUMA: " + str(suma_total))
	return
	
func find_all_labels_in_scene() -> Array:
	var labels = []
	var root = get_tree().root
	find_labels_recursive(root, labels)
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
		label.add_theme_font_size_override("font_size", 40)  # Resaltar tamaño
	else:
		label.remove_theme_color_override("font_color")
		label.remove_theme_font_size_override("font_size")

func _on_boton_verificar_pressed():
	print("Verificando forma...")
	if current_line:
		stop_drawing()
