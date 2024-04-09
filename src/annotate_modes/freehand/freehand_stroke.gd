@tool
extends GDA_Stroke
##
## Freehand stroke returned by the FreehandMode annotate mode.
##

const AnnotateModeHelper := preload("res://addons/GodotAnnotate/src/annotate_modes/helpers/annotate_mode_helper.gd")

## Percentage of point position to increment point position by, if overlapping with another point.
const OVERLAP_INCR_PERC = 0.0001
## Minimum increment of point, if point overlaps with another point.
const MIN_FLOAT_TRES_VAL = 0.001

@export
var min_distance_hitbox: float = 0.25

## Attempts to insert the given point at the end of the stroke line.
## If the point is less than [param perc_min_point_dist], it will not be added,
## unless [param force] is set to true.
func try_annotate_point(point: Vector2, perc_min_point_dist: float, force: bool):
	var points = %StrokeLine.points

	if points[points.size() - 1].distance_to(point) < perc_min_point_dist * %StrokeLine.width:
		
		if force:
			# if two points overlap exactly, then their end caps are not drawn.
			# therefore we offset the point by a very small value to make sure this does not happen.
			# also, for some reason, tres files does not allow tools to store floats with more than
			# 3 decimals precission, so we cannot increment by less than 0.001, since this will not
			# be stored in the AnnotateStroke resource saved to disk.
			# TODO: check if the 3 decimals issue is still a thing, when the stroke is now saved as a packed scene.
			
			var increment := point * OVERLAP_INCR_PERC
			
			increment.x = min(increment.x, MIN_FLOAT_TRES_VAL)
			increment.y = min(increment.y, MIN_FLOAT_TRES_VAL)
			
			point += increment
		else:
			# ignore points which are too close to each other, to reduce memory usage.
			return
	
	var new_boundary := AnnotateModeHelper.expand_boundary_sized_point(get_global_rect(), point, stroke_size)

	global_position = new_boundary.position
	size = new_boundary.size

	# since global_position has been modified,
	# we need to re place the line origin back to world origin,
	# in order to not offset the already drawn points.
	%StrokeLine.global_position = Vector2.ZERO
	
	%StrokeLine.add_point(point)

	return point

## Regenerates all the CollisionShape2D nodes required for representing the strokes hitbox.
func gen_hitbox() -> void:

	# clear previous hitbox.

	for child in %CollisionArea.get_children():
		child.queue_free()

	# Hitbox is made up by sections of capsules, which approximates the shape of the freehand stroke.

	var prev_point_i: int = 0

	for point_i in range(len(%StrokeLine.points)):

		var point: Vector2 = %StrokeLine.points[point_i]
		var prev_point: Vector2 = %StrokeLine.points[prev_point_i]

		var distance_sq := prev_point.distance_squared_to(point)

		# Only generate new capsule segment, if distance between the two points is large enough, or this is the last point.

		if (point_i == len(%StrokeLine.points) - 1 && prev_point_i != point_i) || distance_sq >= (min_distance_hitbox * stroke_size) ** 2:
			var distance := sqrt(distance_sq)

			var collider := CollisionShape2D.new()

			collider.shape = CapsuleShape2D.new()

			# Place capsule so the capsule caps center match up with the point centers,
			# and the rotation matches the rotation between the two points.

			collider.shape.radius = stroke_size / 2
			collider.shape.height = distance + stroke_size

			collider.global_position = (prev_point + point) / 2 + %StrokeLine.position
			collider.rotation = prev_point.angle_to_point(point) + PI / 2

			prev_point_i = point_i

			%CollisionArea.add_child(collider)

func _stroke_resized() -> void:
	gen_hitbox()

func _stroke_created(first_point: Vector2) -> void:
	var size_vec = Vector2.ONE * stroke_size

	global_position = first_point - size_vec / 2
	size = size_vec

	%StrokeLine.global_position = Vector2.ZERO

	%StrokeLine.add_point(first_point)

func _set_stroke_size(size: float) -> void:
	%StrokeLine.width = size

func _set_stroke_color(color: Color) -> void:
	%StrokeLine.default_color = color
