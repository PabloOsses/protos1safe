extends Control

# Nodos de la interfaz
@onready var clock_label = $DigitalClock
@onready var clock_buttons = [$Clock1, $Clock2, $Clock3]
@onready var healthbar = $HealthBar
@onready var background_resumen= $pantallaresumen/backgroundResumen
@onready var texto_resumen=$pantallaresumen/textoResumen

# Variables del juego
var clock_images = []
var correct_clock_index: int = -1
var digital_time: String = ""
var max_health: int = 100
var current_health: int = 0

func _ready():
	Musica.reproducir("nivel_5")
	background_resumen.visible = false
	texto_resumen.visible = false
	# Verificación inicial
	verify_nodes()
	
	# Inicialización del juego
	current_health = 0
	update_healthbar()
	load_clock_images()
	
	if clock_images.size() < 3:
		push_error("Necesitas al menos 3 imágenes de relojes en res://assets/clock_img/")
		return
	
	start_new_round()

func verify_nodes():
	# Verifica que todos los nodos estén correctamente asignados
	if not clock_label:
		push_error("Falta asignar el nodo DigitalClock")
	for i in range(clock_buttons.size()):
		if not clock_buttons[i]:
			push_error("Falta asignar el botón Clock" + str(i+1))
	if not healthbar:
		push_error("Falta asignar el nodo HealthBar")

func start_new_round():
	# Reinicia la ronda con nuevos relojes
	var selected_clocks = select_random_clocks(3)
	
	for i in range(3):
		setup_clock_button(clock_buttons[i], selected_clocks[i])
	
	correct_clock_index = randi_range(0, 2)
	digital_time = selected_clocks[correct_clock_index]["time"]
	clock_label.text = digital_time
	print("Nueva ronda - Hora correcta: ", digital_time)

func setup_clock_button(button: TextureButton, clock_data: Dictionary):
	# Configuración completa del botón
	if not button:
		push_error("Intento de configurar un botón nulo")
		return
	
	var texture = load(clock_data["path"])
	if not texture:
		push_error("No se pudo cargar la textura: " + clock_data["path"])
		return
	
	button.texture_normal = texture
	button.custom_minimum_size = Vector2(200, 200)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	# Configuración de interacción
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.focus_mode = Control.FOCUS_NONE
	button.disabled = false
	
	# Metadata y señales
	button.set_meta("time", clock_data["time"])
	
	# Desconectar y reconectar la señal para evitar duplicados
	if button.pressed.is_connected(_on_clock_pressed):
		button.pressed.disconnect(_on_clock_pressed)
	button.pressed.connect(_on_clock_pressed.bind(button))
	
	# Estado visual inicial
	button.modulate = Color.WHITE

func _on_clock_pressed(button: TextureButton):
	# Verificación de seguridad
	if not button.has_meta("time"):
		push_error("El botón no tiene metadata 'time'")
		return
	
	var time = button.get_meta("time")
	print("Botón pulsado - Hora: ", time)
	
	if time == digital_time:
		# Respuesta correcta
		button.modulate = Color.GREEN
		current_health = min(current_health + 20, max_health)
		update_healthbar()
		
		# Efecto y nueva ronda
		await get_tree().create_timer(0.5).timeout
		start_new_round()
		print("¡Correcto! Salud actual: ", current_health)
	else:
		# Respuesta incorrecta
		button.modulate = Color.RED
		await get_tree().create_timer(0.5).timeout
		button.modulate = Color.WHITE
		print("Incorrecto. La hora correcta era: ", digital_time)

func update_healthbar():
	if healthbar:
		healthbar.value = current_health
		print("Barra de salud actualizada: ", current_health)

# Funciones de utilidad
func load_clock_images():
	var dir = DirAccess.open("res://assets/clock_img/")
	if not dir:
		push_error("No se pudo abrir la carpeta res://assets/clock_img/")
		return
	
	clock_images.clear()
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".png"):
			var time_str = file_name.get_basename()
			clock_images.append({
				"path": "res://assets/clock_img/" + file_name,
				"time": format_time_string(time_str)
			})
		file_name = dir.get_next()

func select_random_clocks(count: int) -> Array:
	var available = clock_images.duplicate()
	var selected = []
	
	for i in range(min(count, available.size())):
		var random_index = randi() % available.size()
		selected.append(available[random_index])
		available.remove_at(random_index)
	
	return selected

func format_time_string(time_str: String) -> String:
	if time_str.length() != 4:
		return "00:00"
	return time_str.insert(2, ":")


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")
	pass # Replace with function body.
