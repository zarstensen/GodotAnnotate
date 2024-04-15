@tool
extends GDA_AnnotateMode
###
### Abstract AnnotateMode implementation for a stroke which can be drawn and controlled by a rectangle shape.
### Draws a rectangle which has one corner at the first click, and another corner in the final mouse position.
### on_begin_stroke and draw_cursor is left unimplemented, as this abstract class is not responsible for creating the rectangle stroke.
###


const AnnotateModeHelper := preload("res://addons/GodotAnnotate/src/annotate_modes/helpers/annotate_mode_helper.gd")
const RectangleLikeStroke := preload("res://addons/GodotAnnotate/src/annotate_modes/helpers/rectangle_like/rectangle_like_stroke.gd")

func on_end_stroke(pos: Vector2, stroke: CanvasItem, canvas: AnnotateCanvas) -> void:
    var rect_stroke = stroke as RectangleLikeStroke
    rect_stroke.set_end_point(pos)

func on_annotate_process(delta: float, stroke: CanvasItem, canvas: AnnotateCanvas) -> void:
    on_end_stroke(canvas.get_local_mouse_position(), stroke, canvas)

func should_begin_stroke(event: InputEvent) -> bool:
    return AnnotateModeHelper.mouse_drag_should_begin_stroke(event)

func should_end_stroke(event: InputEvent) -> bool:
    return AnnotateModeHelper.mouse_drag_should_end_stroke(event)
