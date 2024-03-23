# This file contains should_begin_stroke, and should_end_stroke implementations,
# for annotate modes which require a left click drag motion to draw their stroke.

static func should_begin_stroke(event: InputEvent) -> bool:
    if not event is InputEventMouseButton:
        return false

    var mouse_event := event as InputEventMouseButton

    # TODO: should this be customizable?
    return mouse_event.button_index == MOUSE_BUTTON_LEFT && mouse_event.pressed

static func should_end_stroke(event: InputEvent) -> bool:
    if not event is InputEventMouseButton:
        return false

    var mouse_event := event as InputEventMouseButton

    return mouse_event.button_index == MOUSE_BUTTON_LEFT && not mouse_event.pressed
