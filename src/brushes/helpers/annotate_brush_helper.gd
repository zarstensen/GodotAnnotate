# This file contains should_begin_stroke, and should_end_stroke implementations,
# for annotate brushes which require a left click drag motion to draw their stroke.

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

## Relocate the passed lines origin, without effecting the globall position of the line points.
## new_origin is in local space
static func move_line2d_origin(line: Line2D, new_origin: Vector2):
	var prev_origin = line.global_position
	line.position = new_origin

	for i in range(len(line.points)):
		line.points[i] += prev_origin - line.global_position

## Regenerates all the CollisionShape2D nodes required for representing the strokes hitbox.
static func gen_line2d_hitbox(line: Line2D, min_capsule_distance: float = 0.0) -> Array[CollisionShape2D]:

	# Hitbox is made up by sections of capsules, which approximates the shape of the Line2D stroke.

	var capsules: Array[CollisionShape2D] = [ ]

	var prev_point_i: int = 0

	var point_count := len(line.points)
	var point_iter_count := point_count
	
	if point_count < 2:
		return []
	
	if line.closed:
		point_iter_count += 1

	for point_i in range(point_iter_count):

		var point: Vector2 = line.points[point_i % point_count]
		var prev_point: Vector2 = line.points[prev_point_i]

		var distance_sq := prev_point.distance_squared_to(point)

		# Only generate new capsule segment, if distance between the two points is large enough, or this is the last point.

		if (point_i == point_iter_count - 1 && prev_point_i != point_i) || distance_sq >= (min_capsule_distance * line.width) ** 2:
			var distance := sqrt(distance_sq)

			var collider := CollisionShape2D.new()

			collider.shape = CapsuleShape2D.new()

			# Place capsule so the capsule caps center match up with the point centers,
			# and the rotation matches the rotation between the two points.

			collider.shape.radius = line.width / 2
			collider.shape.height = distance + line.width

			collider.global_position = (prev_point + point) / 2 + line.position
			collider.rotation = prev_point.angle_to_point(point) + PI / 2

			prev_point_i = point_i
			
			capsules.append(collider)

	return capsules
