@tool
extends GDA_Stroke
##
## Freehand stroke returned by the FreehandMode annotate mode.
##

## Percentage of point position to increment point position by, if overlapping with another point.
const OVERLAP_INCR_PERC = 0.0001
## Minimum increment of point, if point overlaps with another point.
const MIN_FLOAT_TRES_VAL = 0.001

## Construct a stroke line with the given stroke size and color.
## Its capping and joint mode are all set to round.
func stroke_init(radius: float, color: Color):
	%StrokeLine.width = radius
	$StrokeLine.default_color = color

## Attempts to insert the given point at the end of the stroke line.
## If the point is less than [param perc_min_point_dist], it will not be added,
## unless [param force] is set to true.
func try_annotate_point(point: Vector2, perc_min_point_dist: float, force: bool):
	var size_vec = Vector2.ONE * %StrokeLine.width

	var points = %StrokeLine.points

	if points.size() <= 0:
		position = point - size_vec / 2
		size = size_vec
	elif points[points.size() - 1].distance_to(point) < perc_min_point_dist * %StrokeLine.width:
		
		if force:
			# if two points overlap exactly, then their end caps are not drawn.
			# therefore we offset the point by a very small value to make sure this does not happen.
			# also, for some reason, tres files does not allow tools to store floats with more than
			# 3 decimals precission, so we cannot increment by less than 0.001, since this will not
			# be stored in the AnnotateStroke resource saved to disk.
			
			var increment := point * OVERLAP_INCR_PERC
			
			increment.x = min(increment.x, MIN_FLOAT_TRES_VAL)
			increment.y = min(increment.y, MIN_FLOAT_TRES_VAL)
			
			point += increment
		else:
			# ignore points which are too close to each other, to reduce memory usage.
			return

	# 

	# var stroke_global_pos: Vector2 = %StrokeLine.global_position

	for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var new_boundary := get_rect().expand(point + size_vec * dir / 2)
		position = new_boundary.position
		size = new_boundary.size
	
	%StrokeLine.global_position = Vector2.ZERO

	%StrokeLine.add_point(point)

	return point

func _collides_with_circle_impl(center: Vector2, diameter: float) -> bool:
	# check if erase circle overlaps with any points in stroke line
	for stroke_points in %StrokeLine.points:
		if stroke_points.distance_squared_to(center) < (%StrokeLine.width / 2 + diameter / 2) ** 2:
			return true

	return false
