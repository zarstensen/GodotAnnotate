@tool
extends "res://addons/GodotAnnotate/src/annotate_modes/capsule/capsule_mode.gd"
###
### RectangleLikeMode implementation which creates an CapsuleStroke with fill set to false.
###

func get_icon_path() -> String:
    return "res://addons/GodotAnnotate/src/annotate_modes/capsule/no_fill/capsule_no_fill_icon.svg"

func get_mode_name() -> String:
    return "Capsule"


func on_begin_stroke(pos: Vector2, size: float, color: Color, canvas: AnnotateCanvas) -> GDA_Stroke:
    var stroke: RectangleLikeStroke = CapsuleStrokeScene.instantiate()
    stroke.stroke_init(size, color, pos)
    stroke.fill = false
    return stroke
