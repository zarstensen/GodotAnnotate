@tool
extends GDA_AnnotateMode
###
### AnnotateMode implementation for the Freehand mode.
### Draws a stroke which follows a dragging mouse.
###

const FreehandStroke := preload("res://addons/GodotAnnotate/src/annotate_modes/freehand/freehand_stroke.gd")

## Percentage of brush radius must be between a new point inserted with [method insert_point],
## for it to be added to the [member points] array.
@export_range(0, 2, 0.05)
var min_point_distance = 0.25

func get_icon_path() -> String:
	return "res://addons/GodotAnnotate/src/annotate_modes/freehand/freehand_icon.svg"

func get_mode_name() -> String:
	return "Freehand"

func draw_cursor(pos: Vector2, brush_diameter: float, brush_color: Color, canvas: CanvasItem) -> void:
	canvas.draw_circle(pos, brush_diameter, brush_color)

func on_begin_stroke(pos: Vector2, size: float, color: Color, canvas: AnnotateCanvas) -> Node2D:
	var stroke = FreehandStroke.new()
	stroke.stroke_init(size, color)
	stroke.try_annotate_point(canvas.get_local_mouse_position(), min_point_distance, true)
	return stroke

func on_end_stroke(pos: Vector2, stroke: Node2D, canvas: AnnotateCanvas) -> void:
	var freehand_stroke = stroke as FreehandStroke
	freehand_stroke.try_annotate_point(canvas.get_local_mouse_position(), min_point_distance, true)

func on_annotate_process(delta: float, stroke: Node2D, canvas: AnnotateCanvas) -> void:
	var freehand_stroke = stroke as FreehandStroke
	freehand_stroke.try_annotate_point(canvas.get_local_mouse_position(), min_point_distance, false)

func should_begin_stroke(event: InputEvent) -> bool:
	if not event is InputEventMouseButton:
		return false
		
	var mouse_event := event as InputEventMouseButton
		
	# TODO: should this be customizable?
	return mouse_event.button_index == MOUSE_BUTTON_LEFT && mouse_event.pressed

func should_end_stroke(event: InputEvent) -> bool:
	if not event is InputEventMouseButton:
		return false
		
	var mouse_event := event as InputEventMouseButton
		
	return mouse_event.button_index == MOUSE_BUTTON_LEFT && not mouse_event.pressed

