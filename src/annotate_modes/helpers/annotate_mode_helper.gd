# This file contains should_begin_stroke, and should_end_stroke implementations,
# for annotate modes which require a left click drag motion to draw their stroke.

static func mouse_drag_should_begin_stroke(event: InputEvent) -> bool:
    if not event is InputEventMouseButton:
        return false

    var mouse_event := event as InputEventMouseButton

    # TODO: should this be customizable?
    return mouse_event.button_index == MOUSE_BUTTON_LEFT && mouse_event.pressed

static func mouse_drag_should_end_stroke(event: InputEvent) -> bool:
    if not event is InputEventMouseButton:
        return false

    var mouse_event := event as InputEventMouseButton

    return mouse_event.button_index == MOUSE_BUTTON_LEFT && not mouse_event.pressed


static func expand_boundary_sized_point(boundary: Rect2, point: Vector2, size: float) -> Rect2:
    var point_size_vec = Vector2.ONE * size

    for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
        boundary = boundary.expand(point + point_size_vec * dir / 2)

    return boundary

