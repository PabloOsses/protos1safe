extends Control

@onready var titulolabel=$Titulo
@onready var tween = create_tween()
#_---------
@onready var actividades=$Inicio
var is_actividades_waving := false
var wave_tween: Tween

#---------
@onready var credenciales:Button=$Credenciales
@onready var cerrar_juego=$cerrar_juego_pantalla

var original_position: Vector2

func _ready() -> void:
	cerrar_juego.visible=false
	original_position = titulolabel.position
	Musica.reproducir("inicio_v1")
	# posiciones iniciales aleatorias en la parte superior de la pantalla
	tween.set_loops()  # Para que se repita infinitamente
	tween.tween_property(titulolabel, "scale", Vector2(1.1, 1.1), 2).set_trans(Tween.TRANS_SINE)
	#start_float_animation()
	tween.tween_property(titulolabel, "scale", Vector2(1.0, 1.0), 2).set_trans(Tween.TRANS_SINE)
	if Globales.is_online==false:
		credenciales.disabled=true
	start_wave_animation()

func _on_inicio_pressed() -> void:
	Globales.modo_offline=true
	
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")


func _on_credenciales_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/inicio_sesion/vista_inicio_credenciales.tscn")
	pass # Replace with function body.


func _on_cerrar_pressed() -> void:
	cerrar_juego.visible=true
	pass # Replace with function body.
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
