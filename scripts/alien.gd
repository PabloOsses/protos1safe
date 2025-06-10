extends Node2D


var time := 0.0
@export var rot_amplitude := 5.0 # grados de rotación
@export var rot_speed := 2.0 # velocidad del vaivén
@export var float_amplitude := 5.0 # altura del movimiento vertical
@export var float_speed := 1.5 # velocidad del flotar

@onready var alien_sprite := $spritesmov

var base_position := Vector2.ZERO
func _ready():
	base_position = alien_sprite.position
	
func _process(delta: float) -> void:
	time += delta
	alien_sprite.rotation_degrees = sin(time * rot_speed) * rot_amplitude
	alien_sprite.position.y = base_position.y + sin(time * float_speed) * float_amplitude
	
