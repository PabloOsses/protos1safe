extends Control
#NOTA: no recuerdo por que pero este dio problemas
#lo que funcionaria en pc no funcionaba en android
#medidas adicionales tuvieron que tomarse
#-----------------
# nodos de la interfaz
@onready var clock_label = $DigitalClock
@onready var clock_buttons = [$Clock1, $Clock2, $Clock3]
@onready var healthbar = $HealthBar
@onready var background_resumen= $pantallaresumen/backgroundResumen
@onready var texto_resumen=$pantallaresumen/textoResumen
@onready var heart_counter = $HeartCounter
# variables del juego
var clock_images = []
var correct_clock_index: int = -1
var digital_time: String = ""
var max_health: int = 100
var current_health: int = 0
var is_android: bool = false

var incremento_barra=20


var detener_juego_5

func _ready():
	print("JUEGO 5")
	detener_juego_5=false
	background_resumen.visible = false
	texto_resumen.visible = false
	
	# configuracion inicial multiplataforma
	is_android = OS.get_name() == "Android"
	print("Sistema operativo detectado:", OS.get_name())
	#---------------
	if Globales.dificultad == "facil":
		print("facil")
		
	elif Globales.dificultad == "medio":
		print("facil")
		heart_counter.set_value(3)
	elif Globales.dificultad == "dificil":
		print("facil")
		heart_counter.set_value(3)
		incremento_barra=15
	else:
		print("facil")
	#---------------
	Musica.reproducir("nivel_5")
	verify_nodes()
	
	# Inicialización del juego
	current_health = 0
	update_healthbar()
	load_clock_images()
	
	if clock_images.size() < 3:
		push_error("Necesitas al menos 3 imágenes de relojes")
		return
	
	start_new_round()
func _process(delta: float) -> void:
	if healthbar.value != 100 and heart_counter.counter > 0:
		#print("El juego continua")
		pass
	else:
		if detener_juego_5!=true:
			Globales.f_logro_2(4)
			calculo_puntaje_final()
			fin_del_juego()
		detener_juego_5=true
func verify_nodes():
	# verificacion de nodos
	if not clock_label:
		push_error("Falta asignar el nodo DigitalClock")
		clock_label = Label.new()  
		add_child(clock_label)
		
	for i in range(clock_buttons.size()):
		if not clock_buttons[i]:
			push_error("Falta asignar el botón Clock" + str(i+1))
	
	if not healthbar:
		push_error("Falta asignar el nodo HealthBar")

func start_new_round():
	# reinicio de ronda
	var selected_clocks = select_random_clocks(3)
	
	for i in range(3):
		if i < clock_buttons.size() and is_instance_valid(clock_buttons[i]):
			setup_clock_button(clock_buttons[i], selected_clocks[i])
		else:
			push_error("Índice de botón inválido: ", i)
	
	correct_clock_index = randi_range(0, 2)
	digital_time = selected_clocks[correct_clock_index]["time"]
	clock_label.text = digital_time
	print("Nueva ronda - Hora correcta: ", digital_time)

func setup_clock_button(button: TextureButton, clock_data: Dictionary):
	# configuracion multiplataforma 
	if not button or not is_instance_valid(button):
		push_error("Intento de configurar un botón nulo")
		return
	
	# esto es especifico para android
	if is_android:
		button.texture_normal = null
		await get_tree().process_frame
	
	# carga de texturas
	var texture = _load_texture_for_platform(clock_data["path"])
	if not texture:
		push_error("No se pudo cargar la textura: " + clock_data["path"])
		return
	
	# configuracion visual
	button.texture_normal = texture
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	# tamaño responsivo
	var button_size = _get_platform_button_size()
	button.custom_minimum_size = button_size
	button.size = button_size
	
	# Configuracion de interaccion
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.focus_mode = Control.FOCUS_NONE if is_android else Control.FOCUS_ALL
	button.disabled = false
	
	
	# se llama a las señales
	button.set_meta("time", clock_data["time"])
	_safe_connect_button(button)
	
	# Estado visual
	button.modulate = Color.WHITE
	
	# Redibujado para Android
	if is_android:
		button.queue_redraw()

func _load_texture_for_platform(path: String) -> Texture2D:
	# Carga optimizada para ambas plataformas
	#print("AYUDA")
	if not ResourceLoader.exists(path):
		push_error("Archivo no encontrado: " + path)
		return _load_fallback_texture()
	
	var texture = load(path)
	if not texture or not texture is Texture2D:
		push_error("Textura inválida: " + path)
		return _load_fallback_texture()
	
	return texture

func _load_fallback_texture() -> Texture2D:
	# sistema de respaldo (en caso de fallo)
	var fallback_path = "res://assets/clock_img/0115.png"
	if ResourceLoader.exists(fallback_path):
		return load(fallback_path)
	return null

func _get_platform_button_size() -> Vector2:
	# dependiendo de la plataforma, el tamaño de los objetos
	if is_android:
		var screen_size = DisplayServer.screen_get_size()
		var min_dimension = min(screen_size.x, screen_size.y)
		return Vector2(min_dimension * 0.2, min_dimension * 0.2)
	else:
		return Vector2(100, 100)  # Tamaño fijo para PC

func _safe_connect_button(button: TextureButton):
	# coneccion de señales
	if button.pressed.is_connected(_on_clock_pressed):
		button.pressed.disconnect(_on_clock_pressed)
	
	var result = button.pressed.connect(_on_clock_pressed.bind(button))
	if result != OK:
		push_error("Error conectando señal: ", result)

func _on_clock_pressed(button: TextureButton):
	# Manejo de interacción multiplataforma
	if not button or not button.has_meta("time"):
		push_error("Botón inválido o sin metadata")
		return
	
	var time = button.get_meta("time")
	print("Interacción detectada - Hora: ", time)
	
	if time == digital_time:
		# respuesta correcta
		respuesta_correcta()
		
		button.modulate = Color.GREEN
		current_health = current_health + incremento_barra
		update_healthbar()
		
		# feedback visual 
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(button, "scale", Vector2(1, 1), 0.1)
		
		await get_tree().create_timer(0.5).timeout
		start_new_round()
	else:
		# respuesta incorrecta
		respuesta_incorrecta()
		button.modulate = Color.RED
		var tween = create_tween()
		tween.tween_property(button, "rotation", deg_to_rad(5), 0.1)
		tween.tween_property(button, "rotation", deg_to_rad(-5), 0.1)
		tween.tween_property(button, "rotation", 0, 0.1)
		
		await get_tree().create_timer(0.5).timeout
		button.modulate = Color.WHITE
		
	
func respuesta_correcta():
	RondasManager.game5_puntaje_total+=1
	$positivo.play()
	pass		
func respuesta_incorrecta():
	$negativo.play()
	heart_counter.decrease()
	pass	
func update_healthbar():
	if healthbar:
		healthbar.value = current_health
		# animacion para la barra de salud
		var tween = create_tween()
		tween.tween_property(healthbar, "value", current_health, 0.3)
func calculo_puntaje_final():
	Globales.f_logro_1()
	print("CALCULO PUNTAJE: " + str(Globales.dificultad))
	print("CALCULO PUNTAJE: " + str(RondasManager.game5_puntaje_total))
	if Globales.dificultad == "facil":
		if heart_counter.counter ==5:
			Globales.juegos_sin_perder_vidas+=1
		RondasManager.game5_puntaje_total=RondasManager.game5_puntaje_total*1
		Globales.acumular_puntuacion(Globales.usuario_email,13,RondasManager.game5_puntaje_total)
	elif Globales.dificultad == "medio":
		if heart_counter.counter ==3:
			Globales.juegos_sin_perder_vidas+=1
		RondasManager.game5_puntaje_total=RondasManager.game5_puntaje_total*1.5
		Globales.acumular_puntuacion(Globales.usuario_email,14,RondasManager.game5_puntaje_total)
	elif Globales.dificultad == "dificil":
		if heart_counter.counter ==3:
			Globales.juegos_sin_perder_vidas+=1
		Globales.f_logro_3()
		RondasManager.game5_puntaje_total=RondasManager.game5_puntaje_total*2
		Globales.acumular_puntuacion(Globales.usuario_email,15,RondasManager.game5_puntaje_total)
	else:
		RondasManager.game5_puntaje_total=RondasManager.game5_puntaje_total*1
func fin_del_juego():
	background_resumen.top_level=true
	texto_resumen.top_level=true
		
		
	background_resumen.visible = true
	texto_resumen.visible = true
	texto_resumen.text="Puntaje: " + str(RondasManager.game5_puntaje_total)
	background_resumen.modulate.a = 0.0
	texto_resumen.modulate.a = 0.0
	var tween := get_tree().create_tween()
	tween.tween_property(background_resumen, "modulate:a", 1.0, 1.5)
	tween.set_parallel()
	tween.tween_property(texto_resumen, "modulate:a", 1.0, 1.5)
	#background_resumen.visible = true
	#texto_resumen.visible = true
	await get_tree().create_timer(5.0).timeout
	RondasManager.reiniciar_game5()
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")
	
	RondasManager.reiniciar_game5()
func load_clock_images():
	
	clock_images.clear()
	#agregar mas horas es editar este array
	var image_names = ["0115", "0300", "0330","0545","0600","0715","1200"]
	for name in image_names:
		var file_name = "%s.png" % name
		var image_path = "res://assets/clock_img/%s" % file_name
		
		if ResourceLoader.exists(image_path):
			clock_images.append({
				"path": image_path,
				"time": format_time_string(name)
			})
		else:
			push_error("Imagen no encontrada: " + image_path)

func select_random_clocks(count: int) -> Array:
	var available = clock_images.duplicate()
	var selected = []
	
	for i in range(min(count, available.size())):
		var random_index = randi() % available.size()
		selected.append(available[random_index])
		available.remove_at(random_index)
	
	return selected

func format_time_string(time_str: String) -> String:
	return time_str.insert(2, ":") if time_str.length() == 4 else "00:00"

func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")
