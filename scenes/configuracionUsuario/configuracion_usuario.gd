extends Control

@onready var dificultad_elegida="facil"
@onready var pantalla_carga_config=$pantallaCarga_user_config
@onready var carga_guardar_conif=$carga_guardar_conif
# Called when the node enters the scene tree for the first time.
var boton_seleccionado: Button = null

func _ready() -> void:
	Musica.reproducir("nivel_1")
	print("config_usuario cargando.....")
	#await get_tree().create_timer(2.0).timeout
	
	cargar_configuracion_usuario()
	
	await get_tree().create_timer(2.0).timeout
	print("config_usuario AQUI")
	pantalla_carga_config.queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")
	pass # Replace with function body.


func _on_facil_pressed() -> void:
	actualizar_boton_seleccionado($Dificultad/facil)
	sonido()
	dificultad_elegida="facil"
	pass # Replace with function body.


func _on_medio_pressed() -> void:
	actualizar_boton_seleccionado($Dificultad/medio)
	sonido()
	dificultad_elegida="medio"
	pass # Replace with function body.


func _on_dificil_pressed() -> void:
	actualizar_boton_seleccionado($Dificultad/dificil)
	sonido()
	dificultad_elegida="dificil"
	
	pass # Replace with function body.
func sonido():
	$BouncySelect.play()

func actualizar_boton_seleccionado(nuevo_boton: Button) -> void:
	if boton_seleccionado != null:
		boton_seleccionado.button_pressed = false  # Deselecciona el anterior
	
	nuevo_boton.button_pressed = true  # Selecciona el nuevo
	boton_seleccionado = nuevo_boton  # Actualiza la referencia
	
	
	
func _on_guardar_pressed() -> void:
	
	Globales.dificultad=dificultad_elegida
	var nueva_config = {
		"volumen_musica": $volumeslider.value,
		"volumen_efectos": $volumeslidersfx.value,
		"dificultad": Globales.dificultad
	}
	carga_guardar_conif.aparecer()
	var exito = await Globales.actualizar_configuracion(Globales.usuario_email, nueva_config)
	carga_guardar_conif.desarrollo()
	await get_tree().create_timer(3.0).timeout
	carga_guardar_conif.desaparecer()
	print("CONFIG USUARIO CAMBIOS GUARDADOS")
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")
	pass # Replace with function body.

# En algún script de tu escena (por ejemplo, en el menú de opciones)
func cargar_configuracion_usuario():
	# Obtener el email del usuario (de tu sistema de persistencia)
	var email_usuario = Globales.usuario_email  # Asume que tienes esto almacenado
	
	# Llamar a la función y esperar la respuesta
	var configuracion = await Globales.obtener_configuracion_usuario(Globales.usuario_email)
	
	if configuracion == null:
		print("Error al obtener configuración")
		# Usar valores por defecto
		configuracion = {
			"volumen_musica": 1.0,
			"volumen_efectos": 1.0,
			"dificultad": "facil"
		}
	print("CONFIG ES: ", configuracion)
	$volumeslider.value=configuracion["volumen_musica"]
	$volumeslidersfx.value=configuracion["volumen_efectos"]
	if configuracion["dificultad"]=="facil":
		actualizar_boton_seleccionado($Dificultad/facil)
		print("config facil")
		dificultad_elegida="facil"
	if configuracion["dificultad"]=="medio":
		actualizar_boton_seleccionado($Dificultad/medio)
		print("config medio")
		dificultad_elegida="medio"
	if configuracion["dificultad"]=="dificil":
		actualizar_boton_seleccionado($Dificultad/dificil)
		print("config dificil")
		dificultad_elegida="dificil"
	# Aplicar la configuración en tu juego
	aplicar_configuracion(configuracion)

func aplicar_configuracion(config):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("music"),
		linear_to_db(config.volumen_musica)
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("sfx"),
		linear_to_db(config.volumen_efectos)
	)
	Globales.dificultad = config.dificultad
