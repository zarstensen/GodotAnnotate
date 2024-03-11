@tool
extends GDA_AnnotateMode
###
### AnnotateMode implementation for the Freehand mode.
### Draws a stroke which follows a dragging mouse.
###

const RectangleStroke := preload("res://addons/GodotAnnotate/src/annotate_modes/rectangle/rectangle_stroke.gd")

func get_icon_path() -> String:
	return "res://addons/GodotAnnotate/src/annotate_modes/rectangle/rectangle_icon.svg"

func get_mode_name() -> String:
	return "Rectangle"

func draw_cursor(pos: Vector2, rect_size: float, brush_color: Color, canvas: CanvasItem) -> void:
	canvas.draw_rect(Rect2(pos - Vector2.ONE * rect_size / 2, Vector2.ONE * rect_size), brush_color, true)

# func on_begin_stroke(pos: Vector2, size: float, color: Color, canvas: AnnotateCanvas) -> Node2D:
# 	var stroke = FreehandStroke.new()
# 	stroke.stroke_init(size, color)
# 	stroke.try_annotate_point(canvas.get_local_mouse_position(), min_point_distance, true)
# 	return stroke

# func on_end_stroke(pos: Vector2, stroke: Node2D, canvas: AnnotateCanvas) -> void:
# 	var freehand_stroke = stroke as FreehandStroke
# 	freehand_stroke.try_annotate_point(canvas.get_local_mouse_position(), min_point_distance, true)

# func on_annotate_process(delta: float, stroke: Node2D, canvas: AnnotateCanvas) -> void:
# 	var freehand_stroke = stroke as FreehandStroke
# 	freehand_stroke.try_annotate_point(canvas.get_local_mouse_position(), min_point_distance, false)

# func should_begin_stroke(event: InputEvent) -> bool:
# 	if not event is InputEventMouseButton:
# 		return false
		
# 	var mouse_event := event as InputEventMouseButton
		
# 	# TODO: should this be customizable?
# 	return mouse_event.button_index == MOUSE_BUTTON_LEFT && mouse_event.pressed

# func should_end_stroke(event: InputEvent) -> bool:
# 	if not event is InputEventMouseButton:
# 		return false
		
# 	var mouse_event := event as InputEventMouseButton
		
# 	return mouse_event.button_index == MOUSE_BUTTON_LEFT && not mouse_event.pressed

