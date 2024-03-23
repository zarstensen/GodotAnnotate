@tool
@icon("res://addons/GodotAnnotate/annotate_layer_icon.svg")
class_name AnnotateCanvas
extends Node2D
##
## Node allowing user to paint and view [AnnotateStroke]s in the 2D editor.
##

## Imports
const AnnotateCanvasCaptureViewport := preload("res://addons/GodotAnnotate/src/annotate_canvas_capture_viewport.gd")
const EraserScene := preload("res://addons/GodotAnnotate/src/eraser/eraser.tscn")
const Eraser := preload("res://addons/GodotAnnotate/src/eraser/eraser.gd")

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

@export
## Index of annotate mode currently being used on the canvas.
var annotate_mode_index: int = 0
## Stroke currently being painted by the user.
var _active_stroke: GDA_Stroke
## [code] true [/code] if user is currently trying to erase strokes.
var _erasing := false
var _eraser: Eraser

@export
## Array of Strokes currently stored in the canvas.
var _strokes: Array[PackedScene] = [ ]

func _ready():
	if not Engine.is_editor_hint() and not show_when_running:
		queue_free()

	# restore lines from previously saved state.
	_instantiate_strokes(_strokes)

func _process(delta):

	if _active_stroke:
		get_annotate_mode().on_annotate_process(delta, _active_stroke, self)
	
	if _eraser != null:
		_eraser.position = get_local_mouse_position()

	if _eraser != null:
		var erase_stroke_indexes: Array[int] = []
		var erased_strokes: Dictionary = {}
		
		var eraser_transform := _eraser.get_global_transform()

		for i in range(get_child_count()):
			var stroke: GDA_Stroke = get_child(i) as GDA_Stroke
			if stroke != null and stroke.collides_with_circle(_eraser.shape, eraser_transform):
				erase_stroke_indexes.append(i)
				erased_strokes[i] = _strokes[i]

		# Only create an undoable erase action, if something is actually erased.
		if len(erase_stroke_indexes) > 0:
			var ur := GodotAnnotate.undo_redo

			ur.create_action("GodotAnnotateEraseStroke")
			ur.add_do_method(self, "_do_erase", erase_stroke_indexes)
			ur.add_undo_method(self, "_undo_erase", erased_strokes)
			ur.commit_action()

	queue_redraw()


func _draw():
	# handles drawing of the cursor preview for the current stroke mode.
	if lock_canvas or _eraser != null:
		return
	
	elif GodotAnnotate.selected_canvas == self:
		get_annotate_mode().draw_cursor(get_local_mouse_position(),
				brush_size / 100 * max_brush_size,
				brush_color,
				self)


func on_editor_input(event: InputEvent) -> bool:

	if _active_stroke:
		
		if get_annotate_mode().should_end_stroke(event):
			
			# finalize stroke annotating
			get_annotate_mode().on_end_stroke(get_local_mouse_position(), _active_stroke, self)
			_active_stroke.stroke_finished()
			
			# save stroke as packed scene.
			var scene = PackedScene.new()
			scene.pack(_active_stroke)
			
			_strokes.append(scene)
			
			# add stroke creation to undo / redo history.

			var ur := GodotAnnotate.undo_redo

			ur.create_action("GodotAnnotateNewStroke")
			ur.add_do_method(self, "_redo_stroke", scene)
			ur.add_undo_method(self, "_undo_stroke", len(_strokes) - 1)
			# Stroke was already added at this point, so we do not want to execute redo_stroke.
			ur.commit_action(false)

			_active_stroke = null

			return true
			
		return get_annotate_mode().on_annotate_input(event)
	
	elif event is InputEventMouseButton:
		# erasing
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			_eraser = EraserScene.instantiate()
			_eraser.stroke_size = brush_size / 100 * max_brush_size
			add_child(_eraser)
			return true
		elif event.button_index == MOUSE_BUTTON_RIGHT && not event.pressed:
			_eraser.queue_free()
			_eraser = null
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
	
	# Check if the current annotate mode wants to begin a new stroke,
	# If so, add the stroke to the scene, so the user can see the stroke being drawn in realtime.
	if get_annotate_mode().should_begin_stroke(event):
		_active_stroke = get_annotate_mode().on_begin_stroke(get_local_mouse_position(), brush_size / 100 * max_brush_size, brush_color, self)
		add_child(_active_stroke)
		
		return true
	
	return false


## Converts the current canvas into an image file and saves it to disk
func capture_canvas(file: String, scale: float) -> void:
	add_child(AnnotateCanvasCaptureViewport.new(self, file, scale))

func resize_stroke(direction: float):
	brush_size *= 1 + direction * SIZE_SCROLL_PERC
	brush_size = min(100, max(brush_size, 1))

	if _eraser != null:
		_eraser.stroke_size = brush_size / 100 * max_brush_size

func get_annotate_mode() -> GDA_AnnotateMode:
	return GodotAnnotate.get_annotate_mode(annotate_mode_index)

func get_stroke_nodes() -> Array[GDA_Stroke]:
	var strokes: Array[GDA_Stroke] = []

	strokes.assign(get_children()
		.filter(func(s): return s is GDA_Stroke))

	return strokes

## Return the smallest Rect2, which contains all the strokes currently stored in the canvas
func get_canvas_area() -> Rect2:
	var boundaries: Array[Rect2] = []
	
	boundaries.assign(get_stroke_nodes()
		.map(func(s): return s.boundary))

	return _merge_rects(boundaries)

## Get an array of all strokes currently saved in the canvas.
func get_strokes() -> Array[PackedScene]:
	return _strokes

## Adds the passed strokes to the canvas.
func import_strokes(new_strokes: Array[PackedScene]):
	_strokes += new_strokes

	_instantiate_strokes(new_strokes)

func _instantiate_strokes(strokes: Array[PackedScene]) -> void:
	for stroke in strokes:
		var stroke_node := stroke.instantiate()
		add_child(stroke_node)

# stroke_nodes must only contains nodes which have been added via. _instantiate_strokes.
func _remove_stroke_nodes(stroke_nodes: Array[GDA_Stroke]) -> void:
	for stroke_node in stroke_nodes:
		stroke_node.queue_free()

func _undo_stroke(stroke_index: int):
	_remove_stroke_nodes([ get_child(stroke_index) as GDA_Stroke ])
	_strokes.remove_at(stroke_index)

func _redo_stroke(stroke_scene: PackedScene):
	_instantiate_strokes([ stroke_scene ])
	_strokes.append(stroke_scene)

## Erase all strokes at the passed indexes.
func _do_erase(erase_stroke_indexes: Array[int]):

	var erase_nodes: Array[GDA_Stroke] = [ ]

	for erase_count in range(erase_stroke_indexes.size()):
		
		erase_nodes.append(get_child(erase_stroke_indexes[erase_count]))

		# subtract the target index by the amount of strokes deleted,
		# since these strokes no longer exist in the array.
		
		var remove_index := erase_stroke_indexes[erase_count] - erase_count
		_strokes.remove_at(remove_index)

	_remove_stroke_nodes(erase_nodes)

## Read all the passed strokes at the index of their key value.
func _undo_erase(erased_strokes: Dictionary):

	var indexes := erased_strokes.keys()
	indexes.sort()

	for insert_index in indexes:

		var stroke_scene = erased_strokes[insert_index] as PackedScene

		_strokes.insert(insert_index, stroke_scene)
		
		var stroke = stroke_scene.instantiate()
		add_child(stroke)
		# move stroke back to its original index, so the z-order is the same as when the stroke was erased.
		move_child(stroke, insert_index)

## Return the smallest possible Rect2 Which contains all the passed Rect2's.
func _merge_rects(rects: Array[Rect2]) -> Rect2:
	
	if len(rects) <= 0:
		return Rect2()
	
	var final_rect = rects[0]

	for rect in rects.slice(1):
		final_rect = final_rect.merge(rect)
		
	return final_rect
