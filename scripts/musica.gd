extends Node

@onready var player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var temas = {
	"game_selector": [
		preload("res://assets/musicafondo/game_selector/cattoys.wav"),
		preload("res://assets/musicafondo/game_selector/FredsShack.wav"),
		preload("res://assets/musicafondo/game_selector/freshbrew.wav"),
	],
	"nivel_1":[
		preload("res://assets/musicafondo/game1/casualfieldday.wav"),
		preload("res://assets/musicafondo/game1/aquarium.wav"),
		
	],
	"nivel_2":[
		preload("res://assets/musicafondo/game2/Papas Attic Main.wav"),
		preload("res://assets/musicafondo/game2/Outfits Main.wav"),
		
	],
	"nivel_3":[
		preload("res://assets/musicafondo/game3/Casual Vol3 Nightly Routine Intensity 1.wav"),
		preload("res://assets/musicafondo/game3/Casual Observatory Main.wav"),
		
	],
	"nivel_4":[
		preload("res://assets/musicafondo/game4/Casual Vol3 Flower Party Intensity 1.wav"),
		preload("res://assets/musicafondo/game4/Casual Vol3 My Horse Intensity 1.wav"),
		
	],
	"nivel_5":[
		preload("res://assets/musicafondo/game5/Casual Dance Class Intensity 1.wav"),
		preload("res://assets/musicafondo/game5/Casual Workshop Intensity 1.wav"),
		
	],
	"inicio_v1":[
		preload("res://assets/musicafondo/game4/Casual Vol3 My Horse Intensity 1.wav"),
		
	],
}
func _ready() -> void:
	player.bus = "music"  # Asigna el player al bus "Música"
	# Opcional: Sincroniza el volumen inicial con el bus
	player.volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music"))
	pass
var tema_actual = ""
var volumen_objetivo := 0.0
var velocidad_fade := 2.0

func _process(delta: float) -> void:
	var volumen_actual = player.volume_db
	if abs(volumen_actual - volumen_objetivo) > 0.1:
		var direccion = sign(volumen_objetivo - volumen_actual)
		player.volume_db += direccion * velocidad_fade * delta
	else:
		player.volume_db = volumen_objetivo	
	

func reproducir(nombre: String):
	#si el tema ya esta sonando
	if tema_actual==nombre:
		return
	if temas.has(nombre):
		 
		#await fade_out()
		
		var nuevo_tema = temas[nombre]
		
		if nuevo_tema is Array:
			nuevo_tema = nuevo_tema.pick_random()
		
		player.stream = nuevo_tema
		player.play()
		tema_actual = nombre
		
		await fade_in()
		
	else:
		print("No se encontró el tema: ", nombre)
		
func fade_out() -> void:
	#cambiar los valores de volumen objetivo cambia 
	#la rapidez con la que el sonido "entra" y "sale"
	#tener cuidado
	volumen_objetivo = -5 
	await espera_volumen()
	player.stop()
func fade_in() -> void:
	player.volume_db = -5  
	volumen_objetivo = 0
	await espera_volumen()
func espera_volumen():
	while abs(player.volume_db - volumen_objetivo) > 0.5:
		await get_tree().process_frame
