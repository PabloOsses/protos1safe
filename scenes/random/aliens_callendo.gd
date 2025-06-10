extends Control

@onready var alien_verde = $verde
@onready var alien_rojo = $rojo
@onready var alien_amarillo = $yellow
# Called when the node enters the scene tree for the first time.
var velocidad_caida_verde := Vector2(0, 100)
var velocidad_rotacion_verde := 1.0

var velocidad_caida_rojo := Vector2(0, 150)
var velocidad_rotacion_rojo := 1.5

var velocidad_caida_amarillo := Vector2(0, 80)
var velocidad_rotacion_amarillo := 0.8
func _ready() -> void:
	
	_resetear_posicion(alien_verde)
	_resetear_posicion(alien_rojo)
	_resetear_posicion(alien_amarillo)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _resetear_posicion(alien: AnimatedSprite2D):
	var viewport_size = get_viewport_rect().size
	alien.position.x = randf_range(50, viewport_size.x - 50)
	alien.position.y = -50  
	alien.rotation = 0  

func _process(delta: float) -> void:
	# mover y rotar verde
	alien_verde.position += velocidad_caida_verde * delta
	alien_verde.rotation += velocidad_rotacion_verde * delta
	
	# mover y rotar rojo
	alien_rojo.position += velocidad_caida_rojo * delta
	alien_rojo.rotation += velocidad_rotacion_rojo * delta
	
	# mover y rotar amarillo
	alien_amarillo.position += velocidad_caida_amarillo * delta
	alien_amarillo.rotation += velocidad_rotacion_amarillo * delta
	
	# resetear posicion si salen de la pantalla
	_verificar_limites_pantalla()

func _verificar_limites_pantalla():
	var viewport_size = get_viewport_rect().size
	
	if alien_verde.position.y > viewport_size.y + 50:
		_resetear_posicion(alien_verde)
	
	if alien_rojo.position.y > viewport_size.y + 50:
		_resetear_posicion(alien_rojo)
	
	if alien_amarillo.position.y > viewport_size.y + 50:
		_resetear_posicion(alien_amarillo)
