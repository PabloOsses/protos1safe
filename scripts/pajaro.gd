extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Reproducimos la animación actual (asegúrate de que esté en modo "play on load")
	sprite.play()
	
	# Obtenemos el número total de frames de la animación actual
	var total_frames = sprite.sprite_frames.get_frame_count(sprite.animation)
	
	# Asignamos un frame inicial aleatorio
	sprite.frame = randi() % total_frames
