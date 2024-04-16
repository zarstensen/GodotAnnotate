@tool
extends Node2D

@export
var stroke_size: float:
	set(v):
		if not is_node_ready():
			await ready
		
		stroke_size = v
		%EraserShape.shape.radius = stroke_size / 2
	get:
		return stroke_size

@export
var circle_width: float = 3

@onready
var eraser_area: Area2D = $EraserArea

var shape: CircleShape2D:
	get:
		return $EraserArea/EraserShape.shape as CircleShape2D

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO,
				stroke_size / 2 - circle_width / 2,
				0, TAU, 32, Color.INDIAN_RED, circle_width, true)
