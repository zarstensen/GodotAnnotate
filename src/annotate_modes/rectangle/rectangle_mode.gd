@tool
extends "res://addons/GodotAnnotate/src/annotate_modes/helpers/rectangle_like/rectangle_like_mode.gd"
###
### Abstract AnnotateMode implementation for the rectangle like mode.
### This mode and the stroke is the simplest possible implementation of the rectangle like mode, since the shape we want is actually a rectangle.
### 

const RectangleStrokeScene := preload("res://addons/GodotAnnotate/src/annotate_modes/rectangle/rectangle_stroke.tscn")

func get_icon_path() -> String:
    return "res://addons/GodotAnnotate/src/annotate_modes/rectangle/rectangle_icon.svg"

func get_mode_name() -> String:
    return "Rectangle"

func get_stroke_variables() -> Dictionary:
    return {
        "Fill": true
    }

func on_begin_stroke(pos: Vector2, size: float, color: Color, variables: Dictionary, canvas: AnnotateCanvas) -> GDA_Stroke:
    
    var stroke: RectangleLikeStroke = RectangleStrokeScene.instantiate()
    
    stroke.stroke_init(size, color, pos)
    stroke.fill = variables["Fill"]

    return stroke

func draw_cursor(pos: Vector2, rect_size: float, brush_color: Color, canvas: CanvasItem) -> void:
    canvas.draw_rect(Rect2(pos - Vector2.ONE * rect_size / 2, Vector2.ONE * rect_size), brush_color, true)
