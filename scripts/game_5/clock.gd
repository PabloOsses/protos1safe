extends Control

signal clock_pressed

# Variables configurables
@export var show_seconds: bool = false
@export var hand_colors: Dictionary = {
	"hour": Color(0.1, 0.1, 0.1),
	"minute": Color(0.0, 0.4, 1.0),
	"second": Color(1.0, 0.0, 0.0)
}
@export var mark_colors: Dictionary = {
	"hour": Color(0.2, 0.2, 0.2),
	"minute": Color(0.4, 0.4, 0.4)
}
@export var clock_face_color: Color = Color(0.9, 0.9, 0.9)
@export var border_color: Color = Color(0, 0, 0)
@export var border_width: float = 3.0

# Variables internas
var current_hour: int = 12
var current_minute: int = 0
var current_second: int = 0

func set_time(hour: int, minute: int, second: int = 0):
	current_hour = hour
	current_minute = minute
	current_second = second
	queue_redraw()

func _draw():
	var center = size / 2
	var radius = min(size.x, size.y) / 2 * 0.9  # 90% del tamaño disponible
	
	# Dibujar el fondo del reloj
	draw_circle(center, radius, clock_face_color)
	draw_arc(center, radius, 0, TAU, 100, border_color, border_width)
	
	# Dibujar marcas de horas
	for i in range(12):
		var angle = deg_to_rad(i * 30 - 90)  # 30° por hora, -90° para empezar en 12
		var inner_point = center + Vector2(cos(angle), sin(angle)) * (radius * 0.85)
		var outer_point = center + Vector2(cos(angle), sin(angle)) * radius
		draw_line(inner_point, outer_point, mark_colors["hour"], 4.0)
	
	# Dibujar marcas de minutos
	for i in range(60):
		if i % 5 != 0:  # Saltar donde ya hay marcas de horas
			var angle = deg_to_rad(i * 6 - 90)
			var inner_point = center + Vector2(cos(angle), sin(angle)) * (radius * 0.93)
			var outer_point = center + Vector2(cos(angle), sin(angle)) * radius
			draw_line(inner_point, outer_point, mark_colors["minute"], 1.0)
	
	# Dibujar manecillas
	# Hora (incluye movimiento progresivo por los minutos)
	draw_hand(center, current_hour * 30 + current_minute * 0.5, radius * 0.5, 8.0, hand_colors["hour"])
	# Minutos
	draw_hand(center, current_minute * 6, radius * 0.7, 5.0, hand_colors["minute"])
	
	# Segundos (opcional)
	if show_seconds:
		draw_hand(center, current_second * 6, radius * 0.85, 2.0, hand_colors["second"])
	
	# Dibujar centro del reloj
	draw_circle(center, 10, border_color)

func draw_hand(center: Vector2, angle_deg: float, length: float, width: float, color: Color):
	var angle = deg_to_rad(angle_deg - 90)  # Convertir y ajustar para que 0° sea arriba
	var end_point = center + Vector2(cos(angle), sin(angle)) * length
	draw_line(center, end_point, color, width)
	# Dibujar punta redondeada
	draw_circle(end_point, width * 0.5, color)

func _on_gui_input(event: InputEvent):
	if event is InputEventScreenTouch and event.pressed:
		clock_pressed.emit(self)
