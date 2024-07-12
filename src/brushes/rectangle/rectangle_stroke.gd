@tool
extends "res://addons/GodotAnnotate/src/brushes/helpers/rectangle_like/rectangle_like_stroke.gd"
# RectangleLikeStroke implementation, is very sparse since RectangleLikeStroke already does most of the heavy lifting.

func _stroke_resized() -> void:
    %RectShape.position = size / 2
    %RectShape.shape.size = size