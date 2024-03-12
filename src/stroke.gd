@tool
class_name GDA_Stroke
extends Control
##
## Control node acting as the parent node to a godot annotate stroke.
##

## Size of the stroke lines (if relevant)
@export
var stroke_size: float

## Color of the entire stroke.
@export
var stroke_color: Color


func _ready() -> void:
	# TODO: resized should be connected to an underlying resize method, which the stroke will implement,
	# and thus handle resizing of it self.
	
	# resized.connect(resize_boundary)

	pass

## Virtual init method for GDA_Stroke implementations.
func stroke_int(radius: float, color: Color) -> void:
	pass

## Check if the given stroke collides with a circle with a given center point and diameter.
func collides_with_circle(center: Vector2, diameter: float) -> bool:
	# first check if erase cursor is inside the strokes boundary box,
	# before using the strokes implementation defined collides_with_circle function,
	# in order to reduce overhead.
	
	var boundary := get_rect()

	var nearest_x := max(boundary.position.x, min(center.x, boundary.end.x))
	var nearest_y := max(boundary.position.y, min(center.y, boundary.end.y))
	# check if erase circle overlaps with stroke boundary
	var nearest_boundary_point := Vector2(nearest_x, nearest_y)

	if nearest_boundary_point.distance_squared_to(center) > (diameter / 2) ** 2:
		return false
	else:
		return _collides_with_circle_impl(center, diameter)

## Abstract method which determines if the stroke collides
## with the circle at the given center point and with the given diameter.
func _collides_with_circle_impl(center: Vector2, diameter: float) -> bool:
	return false
