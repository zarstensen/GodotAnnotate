@tool
extends GDA_Stroke

const AnnotateBrushHelper := preload("res://addons/GodotAnnotate/src/brushes/helpers/annotate_brush_helper.gd")

@export
var fill: bool:
	set(v):
		fill = v

		if not is_node_ready():
			await ready

		if not fill:
			%Border.closed = closed
		else:
			%Border.closed = true

		%Fill.visible = fill

		_gen_hitbox()
		on_stroke_changed()
	get:
		return fill

@export
var closed: bool:
	set(v):
		closed = v

		if not is_node_ready():
			await ready

		if not fill:
			%Border.closed = closed

		_gen_hitbox()
		on_stroke_changed()
	get:
		return closed

@export_group("Advanced")

## Vector2 array representing all points in the original untransformed finished stroke.
## This should be edited with caution, as not all relevant properties are updated when this is modified via. the editor.
@export
var points: PackedVector2Array

## Size of the untransformed finished stroke.
## This should be edited with caution, and should ideally only be modified by the GodotAnnotate plugin.
@export
var finished_size: Vector2

## Insert a point in the polygon stroke at the given position.
func annotate_point(new_point: Vector2):
	# we don't insert the point at the end, since the last point is the preview point.
	_annotate_point_impl(new_point, %Border.get_point_count() - 1)

## Update the global position of the cursor.
## This updates where the preview point of the polygon stroke is placed.
func set_cursor_pos(new_pos: Vector2):
	%Border.set_point_position(%Border.get_point_count() -1, new_pos)
	%Fill.polygon = %Border.points

func _set_stroke_size(size: float) -> void:
	var prev_size = %Border.width
	%Border.width = size

	if _is_stroke_finished:
		# Since scaling is performed at the origin of the first line point, we need to reposition the line so start cap is at most tangent to the strokes rect.
		# We also need to edit the finished size to take into account the new stroke size.
		finished_size += Vector2.ONE * (size - prev_size)
		%Border.position = Vector2.ONE * stroke_size / 2
		%Fill.position = %Border.position
		_stroke_resized()


func _set_stroke_color(color: Color) -> void:
	%Border.default_color = color
	%Fill.color = color

func _stroke_created(first_point: Vector2) -> void:
	global_position = first_point - Vector2.ONE * stroke_size / 2
	size = Vector2.ONE * stroke_size
	
	%Border.global_position = Vector2.ZERO
	%Fill.global_position = Vector2.ZERO
	
	# Two points are created here.
	# The first one is the starting point of the polygon,
	# and the second point is relocated using the set_cursor_pos method,
	# so the user can preview the polygon, before annotating the next point.
	# This point is removed when the stroke is finished.

	_annotate_point_impl(first_point, 0)
	_annotate_point_impl(first_point, 1)

func _stroke_resized():
	# Scale polygon points

	if _is_stroke_finished:
		var scaled_points := points.duplicate()

		var scale_factor := (size - Vector2.ONE * stroke_size) / (finished_size - Vector2.ONE * stroke_size)

		for i in range(len(scaled_points)):
			scaled_points[i] = scaled_points[i] * scale_factor

		%Border.points = scaled_points
		%Fill.polygon = %Border.points

	_gen_hitbox()

func _stroke_finished() -> bool:
	# Remove extra preview points.
	%Border.remove_point(%Border.get_point_count() - 1)
	AnnotateBrushHelper.move_line2d_origin(%Border, Vector2.ONE * stroke_size / 2)

	%Fill.position = Vector2.ONE * stroke_size / 2
	%Fill.polygon = %Border.points


	points = %Border.points
	finished_size = size

	# polygon stroke is not valid if only one vertex was placed.
	return len(%Border.points) > 1

func _annotate_point_impl(new_point: Vector2, index: int):
	%Border.add_point(new_point, index)
	%Fill.polygon = %Border.points

	var new_boundary := AnnotateBrushHelper.expand_boundary_sized_point(get_global_rect(), new_point, stroke_size)

	global_position = new_boundary.position
	size = new_boundary.size

	%Border.global_position = Vector2.ZERO
	%Fill.global_position = Vector2.ZERO

func _gen_hitbox():
	# clear previous hitbox.

	for child in %CollisionArea.get_children():
		%CollisionArea.remove_child(child)
		child.queue_free()

	if len(%Border.points) < 2:
		return

	# Generate border hitbox.
	var border_capsules := AnnotateBrushHelper.gen_line2d_hitbox(%Border)
	
	for capsule in border_capsules:
		%CollisionArea.add_child(capsule)
	
	
	if not fill:
		return
		
	# generate fill hitbox.
	
	var fill_polygons := Geometry2D.decompose_polygon_in_convex(%Fill.polygon)
	
	for polygon in fill_polygons:
		var collision_shape := CollisionShape2D.new()
		%CollisionArea.add_child(collision_shape)

		var polygon_shape := ConvexPolygonShape2D.new()
		polygon_shape.set_point_cloud(polygon)
		
		collision_shape.shape = polygon_shape
		collision_shape.position = %Fill.position