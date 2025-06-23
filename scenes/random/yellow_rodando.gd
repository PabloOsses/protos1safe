extends AnimatedSprite2D

# configuracion de movimiento
@export var velocidad_base := 200.0
@export var limite_superior_y := 150.0
@export var limite_inferior_y := 1000.0
@export var fuerza_rebote := 400.0
@export var gravedad := 800.0
@export var amortiguacion := 0.6
@export var tiempo_espera_reaparicion := 3.0

var velocidad := Vector2.ZERO
var direccion := 1
var viewport_size : Vector2
var esta_esperando := false
var timer_espera : Timer

func _ready():
	viewport_size = get_viewport_rect().size
	position = Vector2(-100, limite_inferior_y - 200)
	velocidad = Vector2(velocidad_base * direccion, -fuerza_rebote)
	play("rodar")
	
	# configurar timer reaparicion
	timer_espera = Timer.new()
	add_child(timer_espera)
	timer_espera.timeout.connect(_reaparecer)
	
	# Ajuste para móviles verticales
	if viewport_size.y > viewport_size.x * 1.5:
		velocidad_base *= 1.8
		limite_superior_y = viewport_size.y * 0.2
		limite_inferior_y = viewport_size.y * 0.9

func _physics_process(delta):
	if esta_esperando:
		return
		
	# mov horizontal
	position.x += velocidad.x * delta
	
	# mov vertical 
	velocidad.y += gravedad * delta
	position.y += velocidad.y * delta
	
	# rebortes verticales
	if position.y <= limite_superior_y:
		position.y = limite_superior_y
		velocidad.y = abs(velocidad.y) * amortiguacion
		
		
	if position.y >= limite_inferior_y:
		position.y = limite_inferior_y
		velocidad.y = -abs(velocidad.y) * amortiguacion
		
	
	# rotacion del sprite
	rotation += velocidad.x * delta * 0.015 * direccion
	
	# limite derecho
	if position.x > viewport_size.x + 100 and !esta_esperando:
		_iniciar_espera()

func _iniciar_espera():
	esta_esperando = true
	visible = false  # ocultar alien
	print("se llego al borde")
	
	
	
	# timer para reaparicion
	timer_espera.start(tiempo_espera_reaparicion)

func _reaparecer():
	# restablecer posicion a la izquierda con altura aleatoria
	position = Vector2(
		-100,
		randf_range(limite_inferior_y * 0.6, limite_inferior_y * 0.9)
	)
	
	# Restablecer velocidad y estado
	velocidad = Vector2(velocidad_base * direccion, -fuerza_rebote)
	esta_esperando = false
	visible = true
	rotation = 0
	#print("YELLOW REAPARECE", position)
	
	# Opcional: emitir señal para sonido/vfx de aparición
	#emit_signal("reaparecio")
