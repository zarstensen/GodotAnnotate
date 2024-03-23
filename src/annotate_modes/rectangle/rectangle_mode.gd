@tool
extends "res://addons/GodotAnnotate/src/annotate_modes/helpers/rectangle_like/rectangle_like_mode.gd"
###
### Abstract AnnotateMode implementation for the rectangle like mode.
### This mode and the stroke is the simplest possible implementation of the rectangle like mode, since the shape we want is actually a rectangle.
### 

const RectangleStrokeScene := preload("res://addons/GodotAnnotate/src/annotate_modes/rectangle/rectangle_stroke.tscn")

func draw_cursor(pos: Vector2, rect_size: float, brush_color: Color, canvas: CanvasItem) -> void:
    canvas.draw_rect(Rect2(pos - Vector2.ONE * rect_size / 2, Vector2.ONE * rect_size), brush_color, true)
