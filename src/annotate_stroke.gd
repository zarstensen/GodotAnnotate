class_name AnnotateStroke
extends Resource
##
## Resource representing a single stroke in a AnnotateCanvas node.
##

## Diameter of the brush used to paint the stroke.
@export
var size: float

@export
var color: Color

## Represents the smallest possible rectangle with no rotation which contains the entire stroke.
@export
var boundary: Rect2

## List of points representing the shape of the brush,
## with the stroke starting at the first element and ending at the last.
# points is not typed for compatility for v0.1.x, should be typed in future versions.
@export
var points = PackedVector2Array()

## Construct a stroke with the given brush information.
## use [method insert_point] to modify stroke.
func _init(_size: float = 1, _color: Color = Color.DODGER_BLUE, _points: PackedVector2Array = PackedVector2Array(), _boundary: Rect2 = Rect2()):
	size = _size
	color = _color
	points = _points
	boundary = _boundary
