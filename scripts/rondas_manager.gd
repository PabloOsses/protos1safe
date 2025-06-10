extends Node

#esto tambien maneja la dificultad
# Called when the node enters the scene tree for the first time.
var game1_rondas_totales := 3
var game1_ronda_actual := 1
var game1_puntaje_total := 0

var game2_rondas_totales := 5
var game2_ronda_actual := 1
var game2_puntaje_total := 0

var game3_rondas_totales := 5
var game3_ronda_actual := 1
var game3_puntaje_total := 0

var game5_rondas_totales := 5
var game5_ronda_actual := 1
var game5_puntaje_total := 0

func reiniciar_game1():
	game1_ronda_actual = 1
	game1_puntaje_total = 0

func reiniciar_game2():
	game2_ronda_actual = 1
	game2_puntaje_total = 0

func reiniciar_game3():
	game3_ronda_actual = 1
	game3_puntaje_total = 0
func reiniciar_game5():
	game3_ronda_actual = 1
	game3_puntaje_total = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
