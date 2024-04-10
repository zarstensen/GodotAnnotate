@tool
extends GDA_Stroke

const AnnotateModeHelper := preload("res://addons/GodotAnnotate/src/annotate_modes/helpers/annotate_mode_helper.gd")

@export
var fill: bool:
	set(v):
		fill = v

		if not is_node_ready():
			await ready

		if not fill:
			%Border.closed = closed
		else:
			%Border.closed = true

		%Fill.visible = fill

	get:
		return fill

@export
var closed: bool:
	set(v):
		closed = v

		if not is_node_ready():
			await ready

		if not fill:
			%Border.closed = closed

	get:
		return closed


func _set_stroke_size(size: float) -> void:
	%Border.width = size

func _set_stroke_color(color: Color) -> void:
	%Border.default_color = color
	%Fill.color = color

func _stroke_created(first_point: Vector2) -> void:
	annotate_point(first_point)

func annotate_point(new_point: Vector2):
	%Border.add_point(new_point)
	var new_polygon: PackedVector2Array = %Fill.polygon
	new_polygon.append(new_point)
	%Fill.polygon = new_polygon

	var new_boundary := AnnotateModeHelper.expand_boundary_sized_point(get_global_rect(), new_point, stroke_size)

	global_position = new_boundary.position
	size = new_boundary.size

	%Border.global_position = Vector2.ZERO
	%Fill.global_position = Vector2.ZERO

func set_last_point_pos(new_pos: Vector2):
	pass
