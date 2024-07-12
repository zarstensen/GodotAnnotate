@tool
extends "res://addons/GodotAnnotate/src/brushes/helpers/rectangle_like/rectangle_like_stroke.gd"

func _stroke_resized() -> void:

    # resize capsule collision shape to be as large as possible, whilst still being inside the stroke bounding box.
    # also must be aligned with x or y axis.

    if size.x > size.y:
        %CapsuleShape.rotation = PI / 2
    else:
        %CapsuleShape.rotation = 0

    %CapsuleShape.position = size / 2
    %CapsuleShape.shape.height = max(size.x, size.y)
    %CapsuleShape.shape.radius = min(size.x, size.y) / 2
