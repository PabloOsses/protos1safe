extends Control

@onready var logro1_animat = $Logro1/icono_logro1
@onready var logro2_animat = $Logro2/icono_logro2
@onready var logro3_animat = $Logro3/icono_logro3
@onready var logro4_animat = $Logro4/icono_logro4
@onready var logro5_animat = $Logro5/icono_logro5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globales.logro_1==true:
		logro1_animat.play("activated")
		$Logro1/estado_ui_false.visible=false
		$Logro1/estado_ui_true.visible=true
	elif Globales.logro_1==false:
		logro1_animat.play("default")
	else:
		logro1_animat.play("activated")
		
	if Globales.logro_2==true:
		logro2_animat.play("activated")
		$Logro2/estado_ui_false.visible=false
		$Logro2/estado_ui_true.visible=true
	elif Globales.logro_2==false:
		logro2_animat.play("default")
	else:
		logro2_animat.play("activated")
		
	if Globales.logro_3==true:
		logro3_animat.play("activated")
		$Logro3/estado_ui_false.visible=false
		$Logro3/estado_ui_true.visible=true
	elif Globales.logro_3==false:
		logro3_animat.play("default")
	else:
		logro3_animat.play("activated")
		
		
	if Globales.logro_4==true:
		logro4_animat.play("activated")
		$Logro4/estado_ui_false.visible=false
		$Logro4/estado_ui_true.visible=true
	elif Globales.logro_4==false:
		logro4_animat.play("default")
	else:
		logro4_animat.play("activated")
	
	
	if Globales.logro_5==true:
		logro5_animat.play("activated")
		$Logro5/estado_ui_false.visible=false
		$Logro5/estado_ui_true.visible=true
	elif Globales.logro_5==false:
		logro5_animat.play("default")
	else:
		logro5_animat.play("activated")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")
	pass # Replace with function body.
