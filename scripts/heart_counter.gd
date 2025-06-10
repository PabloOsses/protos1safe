extends Node2D

@onready var counter_label: Label = $Label
var counter: int = 5

func _ready():
	update_display()

func increase(amount: int = 1):
	counter += amount
	update_display()

func decrease(amount: int = 1):
	counter = max(0, counter - amount) # no baja de 0
	update_display()

func set_value(new_value: int):
	counter = new_value
	update_display()

func reset():
	counter = 5
	update_display()

func update_display():
	counter_label.text = str(counter)
	
	# cambiar color si llega a 0
	#tambien determina color cuando NO es 0
	if counter == 0:
		counter_label.modulate = Color.RED
	else:
		counter_label.modulate = Color.BLACK
