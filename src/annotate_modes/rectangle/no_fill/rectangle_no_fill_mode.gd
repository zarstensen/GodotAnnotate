@tool
extends "res://addons/GodotAnnotate/src/annotate_modes/rectangle/rectangle_mode.gd"
###
### Implementation RectangleMode which creates a RectangleStroke with fill set to false.
###

func get_icon_path() -> String:
    return "res://addons/GodotAnnotate/src/annotate_modes/rectangle/no_fill/rectangle_no_fill_icon.svg"

func get_mode_name() -> String:
    return "Rectangle"

func on_begin_stroke(pos: Vector2, size: float, color: Color, canvas: AnnotateCanvas) -> GDA_Stroke:
    var stroke: RectangleStroke = RectangleStrokeScene.instantiate()
    stroke.stroke_init(size, color, pos)
    stroke.fill = false
    return stroke
