extends Control

@onready var titulolabel=$Titulo
@onready var tween = create_tween()

@onready var credenciales:Button=$Credenciales

@onready var cerrar_juego=$cerrar_juego_pantalla

var original_position: Vector2

func _ready() -> void:
	cerrar_juego.visible=false
	original_position = titulolabel.position
	Musica.reproducir("inicio_v1")
	# posiciones iniciales aleatorias en la parte superior de la pantalla
	tween.set_loops()  # Para que se repita infinitamente
	tween.tween_property(titulolabel, "scale", Vector2(1.1, 1.1), 0.8).set_trans(Tween.TRANS_SINE)
	#start_float_animation()
	tween.tween_property(titulolabel, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)
	if Globales.is_online==false:
		credenciales.disabled=true
func start_float_animation():
	tween.set_loops()
	tween.tween_property(titulolabel, "position", original_position + Vector2(0, -10), 1.0)
	tween.tween_property(titulolabel, "position", original_position + Vector2(0, 0), 1.0)
	tween.tween_property(titulolabel, "position", original_position + Vector2(0, 10), 1.0)
	tween.tween_property(titulolabel, "position", original_position + Vector2(0, 0), 1.0)
func _on_inicio_pressed() -> void:
	Globales.modo_offline=true
	
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")


func _on_credenciales_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/inicio_sesion/vista_inicio_credenciales.tscn")
	pass # Replace with function body.


func _on_cerrar_pressed() -> void:
	cerrar_juego.visible=true
	pass # Replace with function body.
