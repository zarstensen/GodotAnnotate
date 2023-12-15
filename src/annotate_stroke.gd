class_name AnnotateStroke
extends Resource
## Resource representing a single stroke in a AnnotateCanvas node.

## Percentage of brush radius must be between a new point inserted with [method insert_point],
## for it to be added to the [member points] array.
const MIN_POINT_DISTANCE = 0.25

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
@export
var points: Array[Vector2] = []

## Construct a stroke with the given brush information.
## use [method insert_point] to modify stroke.
func _init(_size: float = 1, _color: Color = Color.DODGER_BLUE):
	size = _size
	color = _color

## Attempts to insert a point at the end of the stroke.
## [param force] Insert point into stroke, even if the [constant MIN_POINT_DISTANCE] is not met.
func insert_point(point: Vector2, force: bool = false):
	var size_vec = Vector2(size, size)
	
	if points.size() <= 0:
		boundary = Rect2(point - size_vec, size_vec)
	elif not force and points[points.size() - 1].distance_to(point) < MIN_POINT_DISTANCE * size:
		# ignore points which are too close to each other, to reduce memory usage.
		return

	for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		boundary = boundary.expand(point + size_vec * dir / 2)

	points.append(point)
