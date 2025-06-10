extends Control

@onready var timer_label = $labeltiempo
@onready var message_label = $mensajeoculto
@onready var message_instrucciones=$instrucciones
@onready var countdown_timer = $Timer

@onready var pantalla_size = get_viewport().get_visible_rect().size
@onready var label_cantidad =$cantidad
@onready var label_ronda =$ronda

@onready var background_resumen= $pantallaresumen/backgroundResumen
@onready var texto_resumen=$pantallaresumen/textoResumen


@export var time_left =5

var objeto_escenas = [
	preload("res://scenes/pajaro.tscn"),
	preload("res://scenes/frog.tscn")]
var pajaro_escena = preload("res://scenes/pajaro.tscn")
var cantidad_pajaros = 0
var cantidad_predecida= 0

func _ready():
	print(Globales.dificultad)
	message_instrucciones.visible=true
	timer_label.visible=true
	message_label.visible = false
	countdown_timer.wait_time = 1
	countdown_timer.one_shot = false
	countdown_timer.start()
	update_timer_label()
	generar_objetos_aleatorios()
	label_ronda.text= "Ronda: " +str(RondasManager.game1_ronda_actual) + "/3"
	Musica.reproducir("nivel_1")
	background_resumen.visible = false
	texto_resumen.visible = false
	if Globales.dificultad == "facil":
		time_left=8
		timer_label.text = "Tiempo restante: %d" % time_left
	elif Globales.dificultad == "medio":
		time_left=5
		timer_label.text = "Tiempo restante: %d" % time_left
	elif Globales.dificultad == "dificil":
		time_left=5
		timer_label.text = "Tiempo restante: %d" % time_left
	else:
		time_left=5
		timer_label.text = "Tiempo restante: %d" % time_left
	#background_resumen.visible = true
	#texto_resumen.visible = true
	#background_resumen.modulate.a = 0.0
	#texto_resumen.modulate.a = 0.0
	
func _process(delta: float) -> void:
	label_cantidad.text = str(cantidad_predecida)
	#en caso de que el usuario coloque un valor negativo
	if cantidad_predecida<0:
		cantidad_predecida=0
		label_cantidad.text =str(0)
	pass

func update_timer_label():
	timer_label.text = "Tiempo restante: %d" % time_left


func _on_timer_timeout() -> void:
	time_left -= 1
	update_timer_label()
	
	if time_left <= 0:
		countdown_timer.stop()
		message_instrucciones.visible=false
		timer_label.visible=false
		if cantidad_pajaros==cantidad_predecida:
			on_respuesta_correcta()
		else:
			on_respuesta_incorrecta()
			
		#await get_tree().create_timer(3.0).timeout	
		
func on_respuesta_correcta():
	message_label.text = "Correcto"
	message_label.visible = true
	$mensajeoculto/positive.play()
	await get_tree().create_timer(3.0).timeout
	RondasManager.game1_puntaje_total += 1
	finalizar_ronda()
	
func on_respuesta_incorrecta():
	message_label.text = "Incorrecto"
	message_label.visible = true
	$mensajeoculto/negative.play()
	await get_tree().create_timer(3.0).timeout
	finalizar_ronda()
	
func finalizar_ronda():
	if RondasManager.game1_ronda_actual < RondasManager.game1_rondas_totales:
		RondasManager.game1_ronda_actual+=1
		get_tree().reload_current_scene()
	else:
		
		#background_resumen.modulate.a = 0.0
		#texto_resumen.modulate.a = 0.0
		for nodo in get_tree().get_nodes_in_group("elementos_juego"):
			nodo.visible = false
		background_resumen.top_level=true
		texto_resumen.top_level=true
		
		
		background_resumen.visible = true
		texto_resumen.visible = true
		calculo_puntaje_final()
		
		Globales.f_logro_1()
		Globales.f_logro_2(0)
		texto_resumen.text="Puntaje: " + str(RondasManager.game1_puntaje_total)
		
		background_resumen.modulate.a = 0.0
		texto_resumen.modulate.a = 0.0
		var tween := get_tree().create_tween()
		tween.tween_property(background_resumen, "modulate:a", 1.0, 1.5)
		tween.set_parallel()
		tween.tween_property(texto_resumen, "modulate:a", 1.0, 1.5)
		#background_resumen.visible = true
		#texto_resumen.visible = true
		await get_tree().create_timer(5.0).timeout
		RondasManager.reiniciar_game1()
		get_tree().change_scene_to_file("res://scenes/gameselector.tscn")


	
func calculo_puntaje_final():
	print("CALCULO PUNTAJE: " + str(Globales.dificultad))
	print("CALCULO PUNTAJE: " + str(RondasManager.game1_puntaje_total))
	if Globales.dificultad == "facil":
		RondasManager.game1_puntaje_total=RondasManager.game1_puntaje_total*1
		Globales.acumular_puntuacion(Globales.usuario_email,1,RondasManager.game1_puntaje_total)
	elif Globales.dificultad == "medio":
		RondasManager.game1_puntaje_total=RondasManager.game1_puntaje_total*1.5
		Globales.acumular_puntuacion(Globales.usuario_email,2,RondasManager.game1_puntaje_total)
	elif Globales.dificultad == "dificil":
		Globales.f_logro_3()
		RondasManager.game1_puntaje_total=RondasManager.game1_puntaje_total*2
		Globales.acumular_puntuacion(Globales.usuario_email,3,RondasManager.game1_puntaje_total)
	else:
		RondasManager.game1_puntaje_total=RondasManager.game1_puntaje_total*1
	
func generar_objetos_aleatorios():
	var rng = RandomNumberGenerator.new()
	var cantidad = rng.randi_range(3, 6)
	if Globales.dificultad=='dificil':
		cantidad = rng.randi_range(5, 9)
	var areas_ocupadas: Array[Rect2] = []
	for i in range(cantidad):
		var escena = objeto_escenas.pick_random()
		var objeto = escena.instantiate()
		
		var intentos = 0
		var max_intentos = 20
		var colocado = false
		while intentos < max_intentos and not colocado:
			var posicion = Vector2(randf_range((pantalla_size.x*10)/100, pantalla_size.x-((pantalla_size.x*35)/100)),randf_range((pantalla_size.y*35)/100, pantalla_size.y-((pantalla_size.y*25)/100)))
			
			#temaño del srpite
			var collision_shape = objeto.get_node("Area2D/CollisionShape2D")
			var shape = collision_shape.shape
			var tamaño_sprite = Vector2(64, 64)  # Valor por defecto por si falla
			if shape is RectangleShape2D:
				tamaño_sprite = shape.extents * 2  # extents es la mitad del ancho y alto
			var area = Rect2(posicion - tamaño_sprite / 2, tamaño_sprite)
			
			var se_solapa = false
			
			for otra_area in areas_ocupadas:
				if area.intersects(otra_area):
					se_solapa = true
					break
			if not se_solapa:
				objeto.position = posicion
				add_child(objeto)
				areas_ocupadas.append(area)
				colocado = true
				if escena == pajaro_escena:
					cantidad_pajaros += 1
			intentos += 1	
	pass


func _on_plus_pressed() -> void:
	$minus/audioboton.play()
	cantidad_predecida+=1
	


func _on_minus_pressed() -> void:
	$minus/audioboton.play()
	cantidad_predecida-=1
	


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")
	
