extends Control


@onready var ronda_label=$ronda
@onready var health_bar=$HealthBar
@onready var background_resumen= $pantallaresumen/backgroundResumen
@onready var texto_resumen=$pantallaresumen/textoResumen
@onready var heart_counter = $HeartCounter



var preguntas = []
var preguntas_todas= []
var pregunta_actual = {}

var incremento_barra=20

func _ready():
	#print(heart_counter.counter)
	background_resumen.visible = false
	texto_resumen.visible = false
	health_bar.min_value=0.0
	health_bar.max_value=100
	health_bar.value=0
	if Globales.dificultad == "facil":
		print("facil")
		
	elif Globales.dificultad == "medio":
		print("medio")
		heart_counter.set_value(3)
	elif Globales.dificultad == "dificil":
		print("dificil")
		heart_counter.set_value(3)
		incremento_barra=15
	else:
		print("facil")
	ronda_label.text="Responde las preguntas"+ "\n" +"para vencer al"+"\n"+"visitante del espacio"
	Musica.reproducir("nivel_2")
	cargar_preguntas()
	for i in range(4):
		var boton = get_node("Boton%d" % i)
		boton.pressed.connect(_on_boton_presionado.bind(i))
	
	mostrar_pregunta()
	
func _process(delta: float) -> void:
	
	pass
	
func cargar_preguntas():
	var file = FileAccess.open("res://preguntasgame2/preguntas_vocabulario.json", FileAccess.READ)
	if file:
		var contenido = file.get_as_text()
		preguntas_todas = JSON.parse_string(contenido)
		
		# para que sea aleatorio
		preguntas_todas.shuffle()
		
		#escogidas sean 10 de las aleatorias
		preguntas=preguntas_todas
	
	else:
		push_error("No se pudo abrir el archivo de preguntas")



func mostrar_pregunta():
	
	if health_bar.value != 100 and heart_counter.counter > 0:
		pregunta_actual = preguntas.pop_front()
		if pregunta_actual == null:
			fin_del_juego()
		else:
			print(len(pregunta_actual["definicion"]))
			if len(pregunta_actual["definicion"]) > 34 and len(pregunta_actual["definicion"]) < 50:
				$DefinicionLabel.text = pregunta_actual["definicion"].substr(0,len(pregunta_actual["definicion"])-15)+"\n"+pregunta_actual["definicion"].substr(len(pregunta_actual["definicion"])-15,len(pregunta_actual["definicion"]))
			elif len(pregunta_actual["definicion"]) >=50 : 
				$DefinicionLabel.text = pregunta_actual["definicion"].substr(0,len(pregunta_actual["definicion"])-30)+"\n"+pregunta_actual["definicion"].substr(len(pregunta_actual["definicion"])-30,len(pregunta_actual["definicion"]))
			else:
				$DefinicionLabel.text = pregunta_actual["definicion"]
			
			
			for i in range(4):
				var boton = get_node("Boton%d" % i)
				boton.modulate.a = 0  # Hacerlos transparentes
				var tween = create_tween()
				tween.tween_property(boton, "modulate:a", 1.0, 0.5).set_delay(i * 0.1)
				boton.text = pregunta_actual["alternativas"][i]
				tween.tween_callback(boton.set.bind("disabled", false))  # Habilitar el botón al final
	else:
		calculo_puntaje_final()
		Globales.f_logro_2(1)
		fin_del_juego()
func calculo_puntaje_final():
	Globales.f_logro_1()
	print("CALCULO PUNTAJE: " + str(Globales.dificultad))
	print("CALCULO PUNTAJE: " + str(RondasManager.game2_puntaje_total))
	if Globales.dificultad == "facil":
		RondasManager.game2_puntaje_total=RondasManager.game2_puntaje_total*1
		Globales.acumular_puntuacion(Globales.usuario_email,4,RondasManager.game2_puntaje_total)
		if heart_counter.counter ==5:
			Globales.juegos_sin_perder_vidas+=1
			
	elif Globales.dificultad == "medio":
		RondasManager.game2_puntaje_total=RondasManager.game2_puntaje_total*1.5
		Globales.acumular_puntuacion(Globales.usuario_email,5,RondasManager.game2_puntaje_total)
		if heart_counter.counter ==3:
			Globales.juegos_sin_perder_vidas+=1
	elif Globales.dificultad == "dificil":
		RondasManager.game2_puntaje_total=RondasManager.game2_puntaje_total*2
		Globales.acumular_puntuacion(Globales.usuario_email,6,RondasManager.game2_puntaje_total)
		Globales.f_logro_3()
		if heart_counter.counter ==3:
			Globales.juegos_sin_perder_vidas+=1
	else:
		RondasManager.game2_puntaje_total=RondasManager.game2_puntaje_total*1

func fin_del_juego():
	$DefinicionLabel.text = "¡Fin del juego!"
	for i in range(4):
		get_node("Boton%d" % i).hide()
	
	background_resumen.top_level=true
	texto_resumen.top_level=true
		
		
	background_resumen.visible = true
	texto_resumen.visible = true
	texto_resumen.text="Puntaje: " + str(RondasManager.game2_puntaje_total)
	
	background_resumen.modulate.a = 0.0
	texto_resumen.modulate.a = 0.0
	var tween := get_tree().create_tween()
	tween.tween_property(background_resumen, "modulate:a", 1.0, 1.5)
	tween.set_parallel()
	tween.tween_property(texto_resumen, "modulate:a", 1.0, 1.5)
	#background_resumen.visible = true
	#texto_resumen.visible = true
	await get_tree().create_timer(5.0).timeout
	RondasManager.reiniciar_game2()
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")	
		
		
		
func _on_boton_presionado(indice: int):
	var texto_elegido = pregunta_actual["alternativas"][indice]
	if texto_elegido == pregunta_actual["respuesta_correcta"]:
		respuesta_correcta()
	else:
		respuesta_incorrecta()
		
	mostrar_pregunta()
	
func respuesta_correcta():
	RondasManager.game2_puntaje_total += 1
	print("CORRECTO")
	$positivo.play()
	health_bar.value=health_bar.value+incremento_barra
	pass
	
func respuesta_incorrecta():
	$negativo.play()
	heart_counter.decrease()
	print("INCORRECTO")
	pass


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameselector.tscn")
	
