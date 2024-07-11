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
var min_distance_hitbox: float

@export
var points: PackedVector2Array

@export
var finished_size: Vector2

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
	# we need to move the line origin back to world origin,
	# in order to not offset the already drawn points.
	%StrokeLine.global_position = Vector2.ZERO
	
	%StrokeLine.add_point(point)

	return point

func _stroke_resized() -> void:
	
	# clear previous hitbox.

	for child in %CollisionArea.get_children():
		child.queue_free()
	
	# Scale polygon points
	if _is_stroke_finished:
		var scaled_points := points.duplicate()

		var scale_factor := (size - Vector2.ONE * stroke_size) / (finished_size - Vector2.ONE * stroke_size)

		for i in range(len(scaled_points)):
			scaled_points[i] = scaled_points[i] * scale_factor

		%StrokeLine.points = scaled_points

	var capsules := AnnotateModeHelper.gen_line2d_hitbox(%StrokeLine, min_distance_hitbox)
	
	for capsule in capsules:
		%CollisionArea.add_child(capsule)

func _stroke_created(first_point: Vector2) -> void:
	var size_vec = Vector2.ONE * stroke_size

	global_position = first_point - size_vec / 2
	size = size_vec

	%StrokeLine.global_position = Vector2.ZERO

	%StrokeLine.add_point(first_point)

func _stroke_finished():
	AnnotateModeHelper.move_line2d_origin(%StrokeLine, Vector2.ONE * stroke_size / 2)
	points = %StrokeLine.points
	finished_size = size
	return true

func _set_stroke_size(size: float) -> void:
	var prev_size = %StrokeLine.width
	%StrokeLine.width = size

	if _is_stroke_finished:
		# Since scaling is performed at the origin of the first line point, we need to reposition the line so start cap is at most tangent to the strokes rect.
		# We also need to edit the finished size to take into account the new stroke size.
		finished_size += Vector2.ONE * (size - prev_size)
		%StrokeLine.position = Vector2.ONE * stroke_size / 2
		_stroke_resized()

func _set_stroke_color(color: Color) -> void:
	%StrokeLine.default_color = color
