@tool
extends "res://addons/GodotAnnotate/src/annotate_modes/helpers/rectangle_like/rectangle_like_mode.gd"
###
### Abstract AnnotateMode implementation for the rectangle like mode.
### This mode implementation is for a capsule, which will be fitted inside a rectangle.
### 

const CapsuleStrokeScene := preload("res://addons/GodotAnnotate/src/annotate_modes/capsule/capsule_stroke.tscn")

func draw_cursor(pos: Vector2, size: float, brush_color: Color, canvas: CanvasItem) -> void:
    canvas.draw_circle(pos, size / 2, brush_color)
