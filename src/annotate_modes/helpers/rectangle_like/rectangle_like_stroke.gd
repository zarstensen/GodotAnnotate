@tool
extends GDA_Stroke
##
## Stroke implemtation for a shape inside a rectangle, which can either be filled or hollow.
## stroke_size controls the border width if hollow.
##
## This stroke is implemented as a ColorRect2D,
## which should have a shader applied that renders it as the desired shape.
##

@export
var fill: bool:
    set(v):
        fill = v

        if not is_node_ready():
            await ready

        %StrokeRect.material.set_shader_parameter("fill", v as float)

    get:
        return fill

var _start_rect: Rect2

# Sets the last corner of the rectangle to the given position.
func set_end_point(new_pos: Vector2):
    # A rectangle cannot have a negative size,
    # so we cannot simply calculate the size by using the distance between the new_pos and the starting point,
    # as this would not work if any of new_pos's coordinates are less than the starting point coordinates.
    # instead we store a starting rectangle with sidelength stroke_size on stroke creation.
    # after this we merge this starting rectangle with a new rectangle of equal size and positioned at the new position.
    # the resulting merged rectangle is now our new rectangle.

    var new_rect = _start_rect.merge(Rect2(new_pos - Vector2.ONE * stroke_size / 2, Vector2.ONE * stroke_size))

    # rounding prevents jittering during annotation.
    position = round(new_rect.position)
    size = round(new_rect.size)

func _stroke_created(first_point: Vector2) -> void:
    # rounding prevents jittering.
    position = round(first_point - Vector2.ONE * stroke_size / 2)
    self.size = round(Vector2.ONE * stroke_size)
    
    # see set_end_point for why we store this.
    _start_rect = get_rect()
    
    # fill might not have had access to %StrokeRect yet,
    # so reset it here, so the shader fill parameter can also be updated.
    self.fill = fill

func _set_stroke_size(size: float) -> void:
    # border size is controlled in a shader.
    %StrokeRect.material.set_shader_parameter("border_width", stroke_size)

func _set_stroke_color(color: Color) -> void:
    %StrokeRect.color = stroke_color
