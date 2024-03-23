@tool
extends GDA_AnnotateMode
###
### Abstract  AnnotateMode implementation for the Rectangle mode.
### Draws a rectangle which has one corner at the first click, and another corner in the final mouse position.
### on_begin_stroke is left unimplemented, as this abstract class is not responsible for creating the rectangle stroke.
###


const ClickToDrag := preload("res://addons/GodotAnnotate/src/annotate_modes/click_to_drag_mode.gd")
const RectangleStrokeScene := preload("res://addons/GodotAnnotate/src/annotate_modes/rectangle/rectangle_stroke.tscn")
const RectangleStroke := preload("res://addons/GodotAnnotate/src/annotate_modes/rectangle/rectangle_stroke.gd")

func draw_cursor(pos: Vector2, rect_size: float, brush_color: Color, canvas: CanvasItem) -> void:
    canvas.draw_rect(Rect2(pos - Vector2.ONE * rect_size / 2, Vector2.ONE * rect_size), brush_color, true)

func on_end_stroke(pos: Vector2, stroke: CanvasItem, canvas: AnnotateCanvas) -> void:
    var rect_stroke = stroke as RectangleStroke
    rect_stroke.set_end_point(canvas.get_local_mouse_position())

func on_annotate_process(delta: float, stroke: CanvasItem, canvas: AnnotateCanvas) -> void:
    on_end_stroke(canvas.get_local_mouse_position(), stroke, canvas)

func should_begin_stroke(event: InputEvent) -> bool:
    return ClickToDrag.should_begin_stroke(event)

func should_end_stroke(event: InputEvent) -> bool:
    return ClickToDrag.should_end_stroke(event)
