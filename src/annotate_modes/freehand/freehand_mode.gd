@tool
extends GDA_AnnotateMode
###
### AnnotateMode implementation for the Freehand mode.
###

const FreehandStroke := preload("res://addons/GodotAnnotate/src/annotate_modes/freehand/freehand_stroke.gd")

func get_icon_path() -> String:
	return "res://addons/GodotAnnotate/src/annotate_modes/freehand/freehand_icon.svg"

func get_mode_name() -> String:
	return "Freehand"

func draw_cursor(canvas: CanvasItem, pos: Vector2, brush_diameter: float, brush_color: Color) -> void:
	canvas.draw_circle(pos, brush_diameter, brush_color)

func on_begin_stroke(pos: Vector2, size: float, color: Color, canvas: AnnotateCanvas) -> Node2D:
	var stroke = FreehandStroke.new()
	stroke.stroke_init(size, color)
	stroke.add_point(canvas.get_local_mouse_position())
	return stroke

func on_end_stroke(pos: Vector2, stroke: Node2D, canvas: AnnotateCanvas) -> void:
	var freehand_stroke = stroke as FreehandStroke
	freehand_stroke.try_annotate_point(canvas.get_local_mouse_position(), 0.25, true)

func on_annotate_process(delta: float, stroke: Node2D, canvas: AnnotateCanvas) -> void:
	var freehand_stroke = stroke as FreehandStroke
	freehand_stroke.try_annotate_point(canvas.get_local_mouse_position(), 0.25, false)
	
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

