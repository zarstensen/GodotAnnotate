@tool
class_name AnnotateCanvas
extends Node2D
##
## Node allowing user to paint and view [AnnotateStroke]s on a [AnnotateLayer] in the 2D editor.
##

## Percentage size increase to stroke size caused by shift + scroll.
const SIZE_SCROLL_PERC: float = 0.1

@export_group("Brush")

## How large the brush size will be when [member brush_size] = 100.
@export_range(0, 9999, 1.0, "or_greater")
var max_brush_size: float = 50

## Current size of the brush used to paint strokes.
## Represents a percentage of [member max_brush_size], which is used for constructing [AnnotateStroke]s.
## [br]
## [br]
## Shortcut: shift + scroll 
@export_range(1, 100, 0.1)
var brush_size: float = 50


@export
var brush_color: Color = Color(141 / 255.0, 165 / 255.0, 243 / 255.0)

@export_group("Advanced")

## Do not remove [AnnotateCanvas] node from scene when running outside editor.
## User will not be able to paint on the canvas, even if this is set to [code] true [/code]
@export
var show_when_running := false

## Lock [AnnotateCanvas] node from being drawn on.
@export
var lock_canvas := false

## Percentage of brush radius must be between a new point inserted with [method insert_point],
## for it to be added to the [member points] array.
@export_range(0, 2, 0.05)
var min_point_distance = 0.25

## Current [AnnotateLayer] resource which is painted on when user annotates.
@export
var layer_resource: AnnotateLayer = AnnotateLayer.new()

## Stroke currently being painted by the user.
var _active_stroke: AnnotateStrokeLine
## [code] true [/code] if user is currently trying to erase strokes.
var _erasing := false

## Array of [AnnotateStrokeLine]s, which all visually represents all of the [AnnotateStroke] resources
## in the layer_resource array.
var _stroke_lines: Array[AnnotateStrokeLine] = [ ]

func get_canvas_area() -> Rect2:
	
	if layer_resource.strokes.size() <= 0:
		return Rect2()
	
	var canvas_area := layer_resource.strokes[0].boundary
	
	for stroke in layer_resource.strokes.slice(1):
		canvas_area = canvas_area.merge(stroke.boundary)
		
	return canvas_area

func _ready():
	if not Engine.is_editor_hint() and not show_when_running:
		queue_free()
	
	# restore lines from previously saved state.
	
	for stroke in layer_resource.strokes:
		var line := AnnotateStrokeLine.from_stroke(stroke)
		add_child(line)
		_stroke_lines.append(line)

func _on_begin_stroke():
	_active_stroke = AnnotateStrokeLine.new(brush_size / 100 * max_brush_size, brush_color)
	add_child(_active_stroke)
	_stroke_lines.append(_active_stroke)
	# instantly insert a point, to avoid the user having to drag the cursor,
	# in order to insert a point.
	_active_stroke.try_annotate_point(get_local_mouse_position(), min_point_distance, true)

func _on_end_stroke():
	if !GodotAnnotate.poly_in_progress:
		# force insert final point, as the stroke should end where the user stopped the stroke,
		# even if the final point is within AnnotateStroke.MIN_POINT_DISTANCE.
		_active_stroke.try_annotate_point(get_local_mouse_position(), min_point_distance, true)
		
	layer_resource.strokes.append(_active_stroke.to_stroke())
	_active_stroke = null
	
func _on_begin_erase():
	_erasing = true

func _on_end_erase():
	_erasing = false

func _on_draw_poly_stroke():
	_active_stroke.try_annotate_point(get_local_mouse_position(), min_point_distance, false)

func _on_stroke_resize(direction: float):
	brush_size *= 1 + direction * SIZE_SCROLL_PERC
	brush_size = min(100, max(brush_size, 1))

func _on_capture_canvas(file: String, scale: float):
	add_child(AnnotateCanvasCaptureViewport.new(self, file, scale))

func _process(delta):
	if _active_stroke && !GodotAnnotate.poly_in_progress:
		_active_stroke.try_annotate_point(get_local_mouse_position(), min_point_distance, false)
		
	if _erasing:
		var erase_stroke_indexes: Array[int] = []
		
		for i in range(_stroke_lines.size()):
			if _stroke_lines[i].collides_with(get_local_mouse_position(), brush_size / 100 * max_brush_size):
				erase_stroke_indexes.append(i)
		
		for erase_count in range(erase_stroke_indexes.size()):
			# subtract the target index by the amount of strokes deleted,
			# since these strokes no longer exist in the array.
			
			var remove_index := erase_stroke_indexes[erase_count] - erase_count
			
			layer_resource.strokes.remove_at(remove_index)
			_stroke_lines[remove_index].queue_free()
			_stroke_lines.remove_at(remove_index)
		
	queue_redraw()

func _draw():
	if lock_canvas:
		return
	
	if GodotAnnotate.poly_in_progress:
		draw_dashed_line(_active_stroke.points[-1], get_local_mouse_position(), brush_color, brush_size * 0.125, brush_size * 0.25)
	
	if _erasing:
		draw_arc(get_local_mouse_position(), brush_size / 100 * max_brush_size / 2, 0, TAU, 32, Color.INDIAN_RED, 3, true)
	elif GodotAnnotate.selected_canvas == self:
		draw_circle(get_local_mouse_position(), brush_size / 100 * max_brush_size / 2, brush_color)
