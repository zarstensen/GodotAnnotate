@tool
class_name AnnotateCanvas
extends Node2D
## Node allowing user to paint and view [AnnotateStroke]s on a [AnnotateLayer] in the 2D editor.

## How large the brush size will be when [member stroke_size] = 100.
@export_range(0, 9999, 1.0, "or_greater")
var max_stroke_size: float = 50

## Current size of the brush used to paint strokes.
## Represents a percentage of [member max_stroke_size], which is used for constructing [AnnotateStroke]s.
@export_range(0, 100, 0.1)
var stroke_size: float = 50

@export
var stroke_color: Color = Color(141 / 255.0, 165 / 255.0, 243 / 255.0)

## Do not remove [AnnotateCanvas] node from scene when running outside editor.
## User will not be able to paint on the canvas, even if this is set to [code] true [/code]
@export
var show_when_running := false

## Current [AnnotateLayer] resource which is painted on when user annotates.
@export
var layer_resource: AnnotateLayer = AnnotateLayer.new()

## Stroke currently being painted by the user.
var _active_stroke: AnnotateStroke
## [code] true [/code] if user is currently trying to erase strokes.
var _erasing := false


func _ready():
	if not Engine.is_editor_hint() and not show_when_running:
		queue_free()

func _on_begin_stroke():
	_active_stroke = AnnotateStroke.new(stroke_size / 100 * max_stroke_size, stroke_color)
	layer_resource.strokes.append(_active_stroke)
	# instantly insert a point, to avoid the user having to drag the cursor,
	# in order to insert a point.
	_active_stroke.insert_point(get_global_mouse_position())

func _on_end_stroke():
	# force insert final point, as the stroke should end where the user stopped the stroke,
	# even if the final point is within AnnotateStroke.MIN_POINT_DISTANCE.
	_active_stroke.insert_point(get_global_mouse_position(), true)	
	_active_stroke = null
	
func _on_begin_erase():
	_erasing = true

func _on_end_erase():
	_erasing = false

func _process(delta):
	if _active_stroke:
		_active_stroke.insert_point(get_global_mouse_position())
		
	if _erasing:
		var erase_stroke_indexes: Array[int] = []
		
		for i in range(layer_resource.strokes.size()):
			var stroke := layer_resource.strokes[i]
			
			var nearest_x := max(stroke.boundary.position.x, min(get_global_mouse_position().x, stroke.boundary.end.x))
			var nearest_y := max(stroke.boundary.position.y, min(get_global_mouse_position().y, stroke.boundary.end.y))
			# check if erase circle overlaps with stroke boundary
			var nearest_boundary_point := Vector2(nearest_x, nearest_y)
			
			if nearest_boundary_point.distance_squared_to(get_global_mouse_position()) > (stroke_size / 100 * max_stroke_size / 2) ** 2:
				continue
				
			# check if erase circle overlaps with any points in stroke line,
			# only if above is true to reduce number of distance checks.
			for stroke_points in stroke.points:
				if stroke_points.distance_squared_to(get_global_mouse_position()) < (stroke.size / 2 + stroke_size / 100 * max_stroke_size / 2) ** 2:
					erase_stroke_indexes.append(i)
					break
		
		for erase_count in range(erase_stroke_indexes.size()):
			# subtract the target index by the amount of strokes deleted,
			# since these strokes no longer exist in the array.
			layer_resource.strokes.remove_at(erase_stroke_indexes[erase_count] - erase_count)

	queue_redraw()

func _draw():
	if _erasing:
		draw_arc(get_global_mouse_position(), stroke_size / 100 * max_stroke_size / 2, 0, TAU, 32, Color.INDIAN_RED, 3, true)
	elif GodotAnnotate.selected_layer == self:
		draw_circle(get_global_mouse_position(), stroke_size / 100 * max_stroke_size / 2, stroke_color)
	
	for stroke in layer_resource.strokes:
		
		if stroke.points.size() < 2:
			continue
		
		draw_polyline(stroke.points, stroke.color, stroke.size, true)
		
		# draw round stroke ends
		
		draw_circle(stroke.points[0], stroke.size / 2, stroke.color)
		draw_circle(stroke.points[stroke.points.size() - 1], stroke.size / 2, stroke.color)
