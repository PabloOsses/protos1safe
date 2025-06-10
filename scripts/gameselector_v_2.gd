extends Control

# variables para los efectos, tipo tween
var tween_first_game: Tween
var tween_second_game: Tween
var tween_third_game: Tween
var tween_fourth_game: Tween
var tween_fifth_game: Tween


var original_scale_first: Vector2
var original_scale_second: Vector2
var original_scale_third: Vector2
var original_scale_fourth: Vector2
var original_scale_fifth: Vector2

func _ready() -> void:
	Musica.reproducir("game_selector")
	
	# referencias a los botones
	var first_game_button = $first_game 
	var second_game_button = $second_game 
	var third_game_button = $third_game
	var fourth_game_button = $fourth_game
	var fifth_game_button = $fifth_game
	
	# configuracion estado inicial para animación
	if first_game_button:
		original_scale_first = first_game_button.scale
		first_game_button.scale = Vector2(0.8, 0.8)
		first_game_button.modulate.a = 0
		
	if second_game_button:
		original_scale_second = second_game_button.scale
		second_game_button.scale = Vector2(0.8, 0.8)
		second_game_button.modulate.a = 0
		
	if third_game_button:
		original_scale_third = third_game_button.scale
		third_game_button.scale = Vector2(0.8, 0.8)
		third_game_button.modulate.a = 0
		
	if fourth_game_button:
		original_scale_fourth = fourth_game_button.scale
		fourth_game_button.scale = Vector2(0.8, 0.8)
		fourth_game_button.modulate.a = 0
		
	if fifth_game_button:
		original_scale_fifth = fifth_game_button.scale
		fifth_game_button.scale = Vector2(0.8, 0.8)
		fifth_game_button.modulate.a = 0
	
	# delay de animacion entre botones
	animate_button_appearance(first_game_button, 0.0)
	animate_button_appearance(second_game_button, 0.2)
	animate_button_appearance(third_game_button, 0.4)
	animate_button_appearance(fourth_game_button, 0.6)
	animate_button_appearance(fifth_game_button, 0.8)
	
# aparecion de botones
func animate_button_appearance(button: Control, delay: float) -> void:
	if not button:
		return
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	#  "pop"
	tween.tween_property(button, "scale", original_scale_first * 1.1, 0.3).set_delay(delay)
	tween.tween_property(button, "scale", original_scale_first, 0.2).set_delay(delay + 0.3)
	
	# "fade in"
	tween.tween_property(button, "modulate:a", 1.0, 0.4).set_delay(delay)
	
	# 
	var original_position = button.position
	button.position.y += 50
	tween.tween_property(button, "position", original_position, 0.5).set_delay(delay).set_trans(Tween.TRANS_QUAD)

# primer boton
func _on_first_game_pressed() -> void:
	var button = $first_game
	if button:
		# cancelar en caso de que exista
		if tween_first_game:
			tween_first_game.kill()
		
		tween_first_game = create_tween()
		tween_first_game.set_parallel(true)
		
		# presion
		tween_first_game.tween_property(button, "scale", original_scale_first * 0.9, 0.1)
		tween_first_game.tween_property(button, "modulate", Color(0.9, 0.9, 1.0), 0.1)
		
		# rebote 
		tween_first_game.tween_property(button, "scale", original_scale_first, 0.1).set_delay(0.1)
		tween_first_game.tween_property(button, "modulate", Color.WHITE, 0.1).set_delay(0.1)
		
		await tween_first_game.finished
	
	get_tree().change_scene_to_file("res://scenes/game_1.tscn")

# segundo boton
func _on_second_game_pressed() -> void:
	var button = $second_game
	if button:
		# cancelar en caso de que exista
		if tween_second_game:
			tween_second_game.kill()
		
		tween_second_game = create_tween()
		tween_second_game.set_parallel(true)
		
		# presion
		tween_second_game.tween_property(button, "scale", original_scale_second * 0.85, 0.1)
		tween_second_game.tween_property(button, "modulate", Color(1.0, 0.9, 0.9), 0.1)
		
		# rebote 
		tween_second_game.tween_property(button, "scale", original_scale_second * 1.05, 0.1).set_delay(0.1)
		tween_second_game.tween_property(button, "modulate", Color.WHITE, 0.1).set_delay(0.1)
		tween_second_game.tween_property(button, "scale", original_scale_second, 0.1).set_delay(0.2)
		
		await tween_second_game.finished
	
	get_tree().change_scene_to_file("res://scenes/game_2.tscn")

# tercer boton
func _on_third_game_pressed() -> void:
	var button =$third_game
	if button:
		# cancelar en caso de que exista
		if tween_third_game:
			tween_third_game.kill()
		
		tween_third_game = create_tween()
		tween_third_game.set_parallel(true)
		
		# presion
		tween_third_game.tween_property(button, "scale", original_scale_second * 0.85, 0.1)
		tween_third_game.tween_property(button, "modulate", Color(1.0, 0.9, 0.9), 0.1)
		
		# rebote 
		tween_third_game.tween_property(button, "scale", original_scale_second * 1.05, 0.1).set_delay(0.1)
		tween_third_game.tween_property(button, "modulate", Color.WHITE, 0.1).set_delay(0.1)
		tween_third_game.tween_property(button, "scale", original_scale_second, 0.1).set_delay(0.2)
		
		await tween_third_game.finished
	
	get_tree().change_scene_to_file("res://scenes/game_3.tscn")
	

# cuarto boton
func _on_fourth_game_pressed() -> void:
	var button =$fourth_game
	if button:
		# cancelar en caso de que exista
		if tween_fourth_game:
			tween_fourth_game.kill()
		
		tween_fourth_game = create_tween()
		tween_fourth_game.set_parallel(true)
		
		# presion
		tween_fourth_game.tween_property(button, "scale", original_scale_second * 0.85, 0.1)
		tween_fourth_game.tween_property(button, "modulate", Color(1.0, 0.9, 0.9), 0.1)
		
		# rebote 
		tween_fourth_game.tween_property(button, "scale", original_scale_second * 1.05, 0.1).set_delay(0.1)
		tween_fourth_game.tween_property(button, "modulate", Color.WHITE, 0.1).set_delay(0.1)
		tween_fourth_game.tween_property(button, "scale", original_scale_second, 0.1).set_delay(0.2)
		
		await tween_fourth_game.finished
	
	get_tree().change_scene_to_file("res://scenes/game_4.tscn")
	
	

# quinto boton
func _on_fifth_game_pressed() -> void:
	var button =$fifth_game
	if button:
		# cancelar en caso de que exista
		if tween_fifth_game:
			tween_fifth_game.kill()
		
		tween_fifth_game = create_tween()
		tween_fifth_game.set_parallel(true)
		
		# presion
		tween_fifth_game.tween_property(button, "scale", original_scale_second * 0.85, 0.1)
		tween_fifth_game.tween_property(button, "modulate", Color(1.0, 0.9, 0.9), 0.1)
		
		# rebote 
		tween_fifth_game.tween_property(button, "scale", original_scale_second * 1.05, 0.1).set_delay(0.1)
		tween_fifth_game.tween_property(button, "modulate", Color.WHITE, 0.1).set_delay(0.1)
		tween_fifth_game.tween_property(button, "scale", original_scale_second, 0.1).set_delay(0.2)
		
		await tween_fifth_game.finished
	
	get_tree().change_scene_to_file("res://scenes/game_5.tscn")
	
	


func _on_volver_pressed() -> void:
	if Globales.modo_offline:
		get_tree().change_scene_to_file("res://scenes/inicio/vista_inicio_v_1.tscn")
	elif  Globales.is_online:
		get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/inicio/vista_inicio_v_1.tscn")
	
