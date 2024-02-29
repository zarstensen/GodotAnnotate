##
## Resource representing a single stroke in a AnnotateCanvas node.
## As interfaces are not a thing yet in godot, this should be seen more as a temporary solution for documenting how strokes should be setup.
##

@export
var size: float

@export
var color: Color

## Represents the smallest possible rectangle with no rotation which contains the entire stroke.
@export
var boundary: Rect2

func collides_with_circle(pos: Vector2, rad: float) -> bool:
	return false
