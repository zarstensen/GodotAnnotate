@tool
@icon("res://addons/GodotAnnotate/annotate_layer_icon.svg")
class_name AnnotateCanvas
extends Node2D
##
## Node allowing user to paint and view [AnnotateStroke]s on a [AnnotateLayer] in the 2D editor.
##

## Imports
const AnnotateMode := preload("res://addons/GodotAnnotate/src/annotate_mode.gd")
const Stroke := preload("res://addons/GodotAnnotate/src/stroke.gd")

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

## Annotate mode currently being used on the canvas.
var _annotate_mode: AnnotateMode = GodotAnnotate.annotate_modes[0]
## Stroke currently being painted by the user.
var _active_stroke: Node2D
## [code] true [/code] if user is currently trying to erase strokes.
var _erasing := false

@export
## Array of Strokes currently stored in the canvas.
var _strokes: Array[PackedScene] = [ ]

## Return the smallest possible Rect2 Which contains all the passed Rect2's.
func _merge_rects(rects: Array[Rect2]) -> Rect2:
	
	if len(rects) <= 0:
		return Rect2()
	
	var final_rect = rects[0]

	for rect in rects.slice(1):
		final_rect = final_rect.merge(rect)
		
	return final_rect

## Return the smallest Rect2, which contains all the strokes currently stored in the canvas
func get_canvas_area() -> Rect2:
	return _merge_rects(_strokes.map(func(s): s.boundary))

func _ready():
	if not Engine.is_editor_hint() and not show_when_running:
		queue_free()
	
	# restore lines from previously saved state.
	
	for stroke in _strokes:
		add_child(stroke.instantiate())

func resize_stroke(direction: float):
	brush_size *= 1 + direction * SIZE_SCROLL_PERC
	brush_size = min(100, max(brush_size, 1))

func _on_capture_canvas(file: String, scale: float):
	add_child(AnnotateCanvasCaptureViewport.new(self, file, scale))

func _process(delta):
	if _active_stroke:
		_annotate_mode.on_annotate_process(delta, _active_stroke, self)
		
	if _erasing:
		var erase_stroke_indexes: Array[int] = []
		
		for i in range(get_child_count()):
			if get_child(i).collides_with_circle(get_local_mouse_position(), brush_size / 100 * max_brush_size):
				erase_stroke_indexes.append(i)
		
		for erase_count in range(erase_stroke_indexes.size()):
			# subtract the target index by the amount of strokes deleted,
			# since these strokes no longer exist in the array.
			
			var remove_index := erase_stroke_indexes[erase_count] - erase_count
			
			get_child(remove_index).queue_free()
			_strokes.remove_at(remove_index)
		
	queue_redraw()

func _draw():
	if lock_canvas:
		return

	if _erasing:
		draw_arc(get_local_mouse_position(),
				brush_size / 100 * max_brush_size,
				0, TAU, 32, Color.INDIAN_RED, 3, true)
	
	elif GodotAnnotate.selected_canvas == self:
		_annotate_mode.draw_cursor(self,
				get_local_mouse_position(),
				brush_size / 100 * max_brush_size,
				brush_color)
	
	#if GodotAnnotate.poly_in_progress:
		#draw_dashed_line(_active_stroke.points[-1], get_local_mouse_position(), brush_color, brush_size * 0.125, brush_size * 0.25)
	#elif GodotAnnotate.selected_canvas == self:
		#draw_circle(get_local_mouse_position(), brush_size / 100 * max_brush_size / 2, brush_color)

func on_editor_input(event: InputEvent) -> bool:

	if _active_stroke:
		
		if _annotate_mode.should_end_stroke(event):
			
			_annotate_mode.on_end_stroke(get_local_mouse_position(), _active_stroke, self)
			
			var scene = PackedScene.new()
			scene.pack(_active_stroke)
			
			_strokes.append(scene)
			
			_active_stroke = null
			
			return true
			
		return _annotate_mode.on_annotate_input(event)
	
	elif event is InputEventMouseButton:
		# erasing
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			_erasing = true
			return true
		elif event.button_index == MOUSE_BUTTON_RIGHT && not event.pressed:
			_erasing = false
			return true
		
		# stroke size (shift + scroll)
		# cannot use ctrl or alt, since they control view position and zoom,
		# and cannot be prevented from being forwarded by returning true.
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN && Input.is_key_pressed(KEY_SHIFT):
			if event.pressed:
				resize_stroke(-1)
			
			return true
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP && Input.is_key_pressed(KEY_SHIFT):
			if event.pressed:
				resize_stroke(1)
			
			return true
	
	if _annotate_mode.should_begin_stroke(event):
		_active_stroke = _annotate_mode.on_begin_stroke(get_local_mouse_position(), brush_size, brush_color, self)
		add_child(_active_stroke)
		return true
	
	return false
