@tool
extends GDA_Stroke

const AnnotateModeHelper := preload("res://addons/GodotAnnotate/src/annotate_modes/helpers/annotate_mode_helper.gd")

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

	get:
		return closed


func _set_stroke_size(size: float) -> void:
	%Border.width = size

func _set_stroke_color(color: Color) -> void:
	%Border.default_color = color
	%Fill.color = color

func _stroke_created(first_point: Vector2) -> void:
	global_position = first_point - Vector2.ONE * stroke_size / 2
	size = Vector2.ONE * stroke_size
	
	%Border.global_position = Vector2.ZERO
	%Fill.global_position = Vector2.ZERO
	
	_annotate_point_impl(first_point, 0)
	_annotate_point_impl(first_point, 1)

func _stroke_resized():
	# clear previous hitbox.

	for child in %CollisionArea.get_children():
		child.queue_free()

	if len(%Border.points) < 2:
		return

	# Generate border hitbox.
	
	var border_capsules := AnnotateModeHelper.gen_line2d_hitbox(%Border)
	
	for capsule in border_capsules:
		%CollisionArea.add_child(capsule)
	
	
	if not fill:
		return
		
	# generate fill hitbox.
	
	var fill_polygons := Geometry2D.decompose_polygon_in_convex(%Fill.polygon)
	
	for polygon in fill_polygons:
		var collision_shape := CollisionShape2D.new()
		var polygon_shape := ConvexPolygonShape2D.new()
		polygon_shape.set_point_cloud(polygon)
		
		collision_shape.shape = polygon_shape
		
		%CollisionArea.add_child(collision_shape)
		collision_shape.global_position = Vector2.ZERO

func _stroke_finished() -> bool:

	# Remove extra preview points.
	%Border.remove_point(%Border.get_point_count() - 1)

	var polygon: PackedVector2Array = %Fill.polygon
	polygon.remove_at(len(polygon) - 1)
	%Fill.polygon = polygon

	return len(%Border.points) > 1

func annotate_point(new_point: Vector2):
	_annotate_point_impl(new_point, %Border.get_point_count() - 1)

func set_cursor_pos(new_pos: Vector2):
	print(%Fill.polygon)
	%Border.set_point_position(%Border.get_point_count() -1, new_pos)
	var polygon: PackedVector2Array = %Fill.polygon
	polygon[len(polygon) - 1] = new_pos
	%Fill.polygon = polygon

func _annotate_point_impl(new_point: Vector2, index: int):
	%Border.add_point(new_point, index)
	var new_polygon: PackedVector2Array = %Fill.polygon
	new_polygon.insert(index, new_point)
	%Fill.polygon = new_polygon

	var new_boundary := AnnotateModeHelper.expand_boundary_sized_point(get_global_rect(), new_point, stroke_size)

	global_position = new_boundary.position
	size = new_boundary.size

	%Border.global_position = Vector2.ZERO
	%Fill.global_position = Vector2.ZERO

