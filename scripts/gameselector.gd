extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Musica.reproducir("game_selector")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_firstgame_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_1.tscn")
	pass # Replace with function body.


func _on_secondgame_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_2.tscn")
	pass # Replace with function body.


func _on_thirdgam_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_3.tscn")
	pass # Replace with function body.


func _on_fourgame_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_4.tscn")
	pass # Replace with function body.


func _on_fifthgame_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_5.tscn")
	pass # Replace with function body.
