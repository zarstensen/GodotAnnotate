class_name AnnotateStrokeLine
extends Line2D
##
## Node responsible for a visual representation of a AnnotateStroke resource.
##

## Percentage of point position to increment point position by, if overlapping with another point.
const OVERLAP_INCR_PERC = 0.0001
## Minimum increment of point, if point overlaps with another point.
const MIN_FLOAT_TRES_VAL = 0.001

## same as [AnnotateStroke.boundary]
var boundary: Rect2 = Rect2()

## Construct a stroke line with the given stroke size and color.
## Its capping and joint mode are all set to round.
func _init(size: float, color: Color):
	width = size
	default_color = color
	# TODO: should probably make this customisable in some way.
	# not sure if this should be custom for each stroke, or just the canvas in general.
	round_precision = 32

	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	joint_mode = Line2D.LINE_JOINT_ROUND

## Construct a stroke line which visually represents the given [AnnotateStroke] resource.
static func from_stroke(stroke: AnnotateStroke) -> AnnotateStrokeLine:
	var stroke_line = AnnotateStrokeLine.new(stroke.size, stroke.color)
	stroke_line.boundary = stroke.boundary
	
	# v0.1.x uses Array[Vector2] instead of PackedVector2Array in the AnnotateStroke resource.
	if stroke.points is Array[Vector2]:
		stroke.points = PackedVector2Array(stroke.points)
	
	stroke_line.points = stroke.points
	
	return stroke_line

## Convert the stroke line back to a [AnnotateStroke] resource,
## which will construct this exact stroke line when passed to [method from_stroke]
func to_stroke() -> AnnotateStroke:
	return AnnotateStroke.new(width, default_color, points, boundary)

## Attempts to insert the given point at the end of the stroke line.
## If the point is less than [param perc_min_point_dist], it will not be added,
## unless [param force] is set to true.
func try_annotate_point(point: Vector2, perc_min_point_dist: float, force: bool):
	var size_vec = Vector2(width, width)
	
	if points.size() <= 0:
		boundary = Rect2(point - size_vec, size_vec)
	elif points[points.size() - 1].distance_to(point) < perc_min_point_dist * width:
		
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

	for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		boundary = boundary.expand(point + size_vec * dir / 2)
	
	add_point(point)
	return point

## Checks if the given stroke line collides with a circle centered at [param brush center]
## which has a diamater of [param brush_width]
func collides_with(brush_center: Vector2, brush_width: float) -> bool:
	var nearest_x := max(boundary.position.x, min(brush_center.x, boundary.end.x))
	var nearest_y := max(boundary.position.y, min(brush_center.y, boundary.end.y))
	# check if erase circle overlaps with stroke boundary
	var nearest_boundary_point := Vector2(nearest_x, nearest_y)
	
	if nearest_boundary_point.distance_squared_to(brush_center) > (brush_width / 2) ** 2:
		return false

	# check if erase circle overlaps with any points in stroke line,
	# only if above is true to reduce number of distance checks.
	for stroke_points in points:
		if stroke_points.distance_squared_to(brush_center) < (width / 2 + brush_width / 2) ** 2:
			return true

	return false
