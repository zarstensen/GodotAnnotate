@tool
extends GDA_AnnotateBrush
##
## Annotate Brush implementation for the polygon stroke.
## The stroke is annotated by clicking multiple times on the canvas, and is finished by right-clicking or hitting the enter key.
##

const PolygonStroke = preload ("res://addons/GodotAnnotate/src/brushes/polygon/polygon_stroke.gd")
const PolygonStrokeScene = preload ("res://addons/GodotAnnotate/src/brushes/polygon/polygon_stroke.tscn")

func get_icon_path() -> String:
	return "res://addons/GodotAnnotate/src/brushes/polygon/polygon_icon.svg"

func get_brush_name() -> String:
	return "Polygon"

func get_stroke_variables() -> Dictionary:
	return {
		"Fill": false,
		"Closed": false
	}

func draw_cursor(pos: Vector2, brush_diameter: float, brush_color: Color, canvas: CanvasItem) -> void:
	canvas.draw_circle(pos, brush_diameter / 2, brush_color)

func should_begin_stroke(event: InputEvent) -> bool:
	var mouse_button_event := event as InputEventMouseButton

	if mouse_button_event != null and mouse_button_event.button_index == MOUSE_BUTTON_LEFT and mouse_button_event.pressed:
		return true

	return false

func should_end_stroke(event: InputEvent) -> bool:
	var mouse_button_event := event as InputEventMouseButton

	if mouse_button_event != null and mouse_button_event.button_index == MOUSE_BUTTON_RIGHT and mouse_button_event.pressed:
		return true

	var key_button_event := event as InputEventKey

	if key_button_event != null and key_button_event.key_label == KEY_ENTER and key_button_event.pressed:
		return true

	return false

func on_annotate_input(event: InputEvent, stroke: GDA_Stroke, canvas: AnnotateCanvas) -> bool:
	var mouse_button_event := event as InputEventMouseButton

	if mouse_button_event == null or mouse_button_event.button_index != MOUSE_BUTTON_LEFT or not mouse_button_event.pressed:
		return false

	var poly_stroke := stroke as PolygonStroke

	poly_stroke.annotate_point(canvas.get_global_mouse_position())

	return true

func on_annotate_process(_delta: float, stroke: GDA_Stroke, canvas: AnnotateCanvas):
	var poly_stroke := stroke as PolygonStroke

	if poly_stroke == null:
		return

	poly_stroke.set_cursor_pos(canvas.get_global_mouse_position())

func on_begin_stroke(pos: Vector2, size: float, color: Color, variables: Dictionary, canvas: AnnotateCanvas) -> GDA_Stroke:
	
	var stroke: PolygonStroke = PolygonStrokeScene.instantiate()
	
	stroke.stroke_init(size, color, canvas.get_global_mouse_position())
	stroke.fill = variables["Fill"]
	stroke.closed = variables["Closed"]

	return stroke
