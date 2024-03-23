@tool
extends GDA_AnnotateMode
###
### AnnotateMode implementation for the Freehand mode.
### Draws a stroke which follows a dragging mouse.
###

const ClickToDrag := preload("res://addons/GodotAnnotate/src/annotate_modes/helpers/click_to_drag_mode.gd")
const FreehandStrokeScene := preload("res://addons/GodotAnnotate/src/annotate_modes/freehand/freehand_stroke.tscn")
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
	canvas.draw_circle(pos, brush_diameter / 2, brush_color)

func on_begin_stroke(pos: Vector2, size: float, color: Color, canvas: AnnotateCanvas) -> GDA_Stroke:
	var stroke: FreehandStroke = FreehandStrokeScene.instantiate()
	stroke.stroke_init(size, color, canvas.get_global_mouse_position())
	return stroke

func on_end_stroke(pos: Vector2, stroke: GDA_Stroke, canvas: AnnotateCanvas) -> void:
	var freehand_stroke = stroke as FreehandStroke
	freehand_stroke.try_annotate_point(stroke.get_global_mouse_position(), min_point_distance, true)

func on_annotate_process(delta: float, stroke: GDA_Stroke, canvas: AnnotateCanvas) -> void:
	var freehand_stroke = stroke as FreehandStroke
	freehand_stroke.try_annotate_point(stroke.get_global_mouse_position(), min_point_distance, false)

func should_begin_stroke(event: InputEvent) -> bool:
	return ClickToDrag.should_begin_stroke(event)

func should_end_stroke(event: InputEvent) -> bool:
	return ClickToDrag.should_end_stroke(event)

