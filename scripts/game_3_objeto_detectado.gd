extends Area2D

#func _ready():
	#var collision_shape = CollisionShape2D.new()
	#collision_shape.shape = CircleShape2D.new()
	#collision_shape.shape.radius = 20
	#add_child(collision_shape)
	#
	#var sprite = Sprite2D.new()
	#sprite.texture = load("res://icon.png")
	#add_child(sprite)
#
#func highlight(enable: bool):
	#if has_node("Sprite2D"):
		#get_node("Sprite2D").modulate = Color.RED if enable else Color.WHITE
