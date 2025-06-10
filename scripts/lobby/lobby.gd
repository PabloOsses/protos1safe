extends Control


# Called when the node enters the scene tree for the first time.
@onready var actividades=$Juegos
@onready var ranking=$rankingGlobales
@onready var logros=$Logros
@onready var configuracion=$configuracion
@onready var cerrar_sesion=$cerrar_sesion
@onready var pantalla_carga=$pantallaCarga

var is_actividades_waving := false
var wave_tween: Tween

# Variables para guardar los estados originales
var original_scale_actividades: Vector2
var original_scale_ranking: Vector2
var original_scale_logros: Vector2
var original_scale_configuracion: Vector2
var original_scale_cerrar_sesion: Vector2

# Tweens para cada botón
var tween_actividades: Tween
var tween_ranking: Tween
var tween_logros: Tween
var tween_configuracion: Tween
var tween_cerrar_sesion: Tween

@onready var cerrar_juego=$cerrar_juego_pantalla

func _ready() -> void:
	pantalla_carga.aparecer()
	cerrar_juego.visible=false
	for i in [ $Juegos, $rankingGlobales, $Logros, $configuracion, $cerrar_sesion]:
		i.modulate.a = 0.0
	if Globales.carga_datos==false:
		print("LOBBY IMPRESION")
		$Label.text=Globales.dificultad +"  "+str(Globales.is_online)
		
		print("LOBBY LOGROS")
		print("lobby: logro 1: "+str(Globales.logro_1))
		print("lobby: logro 2: "+str(Globales.logro_2))
		print("lobby: logro 3: "+str(Globales.logro_3))
		print("lobby: logro 4: "+str(Globales.logro_4))
		print("lobby: logro 5: "+str(Globales.logro_5))
		
		#EN CASO DE NECESITAR MAS TIEMPO PARA CARGAR DATOS
		
		await get_tree().create_timer(7).timeout
		#await Globales.cargar_configuracion_usuario()
		pantalla_carga.desaparecer()
		
		await Globales.cargar_configuracion_usuario()
		setup_buttons()
		animate_menu_entrance()
		#await get_tree().create_timer(5.0).timeout # Espera que terminen las animaciones de entrada
		start_wave_animation()
	elif Globales.carga_datos==true:
		print("LOBBY IMPRESION")
		$Label.text=Globales.dificultad +"  "+str(Globales.is_online)
		pantalla_carga.desaparecer()
		print("LOBBY LOGROS")
		print("lobby: logro 1: "+str(Globales.logro_1))
		print("lobby: logro 2: "+str(Globales.logro_2))
		print("lobby: logro 3: "+str(Globales.logro_3))
		print("lobby: logro 4: "+str(Globales.logro_4))
		print("lobby: logro 5: "+str(Globales.logro_5))
		pantalla_carga.desaparecer()
		setup_buttons()
		animate_menu_entrance()
		#await get_tree().create_timer(5.0).timeout # Espera que terminen las animaciones de entrada
		start_wave_animation()
func _process(delta: float) -> void:
	$Label.text=Globales.dificultad +"  "+str(Globales.is_online)	
func setup_buttons():
	# Guardar escalas originales y configurar estado inicial
	if actividades:
		original_scale_actividades = actividades.scale
		actividades.scale = Vector2(0.8, 0.8)
		actividades.modulate.a = 0
		
	if ranking:
		original_scale_ranking = ranking.scale
		ranking.scale = Vector2(0.8, 0.8)
		ranking.modulate.a = 0
		
	if logros:
		original_scale_logros = logros.scale
		logros.scale = Vector2(0.8, 0.8)
		logros.modulate.a = 0
		
	if configuracion:
		original_scale_configuracion = configuracion.scale
		configuracion.scale = Vector2(0.8, 0.8)
		configuracion.modulate.a = 0
		
	if cerrar_sesion:
		original_scale_cerrar_sesion = cerrar_sesion.scale
		cerrar_sesion.scale = Vector2(0.8, 0.8)
		cerrar_sesion.modulate.a = 0
func animate_menu_entrance():
	# Animación de entrada con delays escalonados
	animate_button_appearance(actividades, original_scale_actividades, 0.0)
	animate_button_appearance(ranking, original_scale_ranking, 0.2)
	animate_button_appearance(logros, original_scale_logros, 0.4)
	animate_button_appearance(configuracion, original_scale_configuracion, 0.6)
	animate_button_appearance(cerrar_sesion, original_scale_cerrar_sesion, 0.8)
func animate_button_appearance(button: Control, original_scale: Vector2, delay: float) -> void:
	if not button:
		return
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	# Efecto "pop"
	tween.tween_property(button, "scale", original_scale * 1.1, 0.3).set_delay(delay)
	tween.tween_property(button, "scale", original_scale, 0.2).set_delay(delay + 0.3)
	
	# Fade in
	tween.tween_property(button, "modulate:a", 1.0, 0.4).set_delay(delay)
	
	# Movimiento desde abajo
	var original_position = button.position
	button.position.y += 50
	tween.tween_property(button, "position", original_position, 0.5).set_delay(delay).set_trans(Tween.TRANS_QUAD)
func start_wave_animation():
	if not actividades or is_actividades_waving:
		return
	
	is_actividades_waving = true
	
	# Configuramos el tween para el movimiento de vaivén
	wave_tween = create_tween().set_loops()
	wave_tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	
	# Movimiento de vaivén (rotación y posición vertical)
	wave_tween.tween_property(actividades, "rotation_degrees", 2.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	wave_tween.parallel().tween_property(actividades, "position:y", actividades.position.y + 5, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	wave_tween.tween_property(actividades, "rotation_degrees", -2.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	wave_tween.parallel().tween_property(actividades, "position:y", actividades.position.y - 5, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	wave_tween.tween_property(actividades, "rotation_degrees", 0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	wave_tween.parallel().tween_property(actividades, "position:y", actividades.position.y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	wave_tween.tween_interval(1.0) # Pequeña pausa entre ciclos

func _on_juegos_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")
	pass # Replace with function body.


func _on_cerrar_sesion_pressed() -> void:
	clear_session()
	get_tree().change_scene_to_file("res://main.tscn")
	pass # Replace with function body.
# Borrar sesión (logout)
func clear_session():
	DirAccess.remove_absolute("user://session.cfg")


func _on_ranking_globales_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/puntajesGlobales/ranking_globales.tscn")
	pass # Replace with function body.


func _on_configuracion_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/configuracionUsuario/configuracion_usuario.tscn")
	pass # Replace with function body.


func _on_logros_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/logros/logros.tscn")
	pass # Replace with function body.


func _on_cerrar_pressed() -> void:
	cerrar_juego.visible=true
	pass # Replace with function body.
