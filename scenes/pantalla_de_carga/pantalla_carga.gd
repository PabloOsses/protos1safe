extends Control

@onready var pantalla=$pantalla_falsa
@onready var mensaje_carga=$cargando
var tween: Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("--Pantalla de carga")
	#$".".visible=true
	animar_latido()
	##cambiar en pantalla de carga y lobby
	#await get_tree().create_timer(5.0).timeout
	#print("--Pantalla vanish")
	#$".".visible=false
	
func aparecer():
	$".".visible=true
func desaparecer():	
	$".".visible=false
func animar_latido():
	if tween:
		tween.kill()  # Detiene animaciones previas
	
	tween = create_tween()
	tween.set_loops()  # Repite infinitamente
	tween.set_trans(Tween.TRANS_SINE)  # Movimiento suave
	tween.set_ease(Tween.EASE_IN_OUT)  # Aceleracion/desaceleracion
	
	# Escala al 110% en 0.3 segundos, luego vuelve al 100%
	tween.tween_property(mensaje_carga, "scale", Vector2(1.1, 1.1), 0.3)
	tween.tween_property(mensaje_carga, "scale", Vector2(1.0, 1.0), 0.3)
