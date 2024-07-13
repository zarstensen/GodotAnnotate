@tool
@icon("res://addons/GodotAnnotate/src/canvas/annotate_canvas_icon.svg")
class_name AnnotateCanvas
extends Node2D
##
## Node allowing user to paint and view [AnnotateStroke]s in the 2D editor.
##

## Imports
const AnnotateCanvasCaptureViewport := preload("res://addons/GodotAnnotate/src/canvas/annotate_canvas_capture_viewport.gd")
const EraserScene := preload("res://addons/GodotAnnotate/src/eraser/eraser.tscn")
const Eraser := preload("res://addons/GodotAnnotate/src/eraser/eraser.gd")

signal canvas_changed(canvas: AnnotateCanvas)

@export_group("Brush")

## Current size of the brush (size in pixels) used to paint strokes.
## Shortcut: shift + scroll via. annotate toolbar
@export_range(1, 100, 0.1)
var brush_size: float = GodotAnnotate.config.get_value("canvas", "default_brush_size", 50) if GodotAnnotate.config else 0


@export
var brush_color: Color = GodotAnnotate.config.get_value("canvas", "default_brush_color", Color(141 / 255.0, 165 / 255.0, 243 / 255.0)) if GodotAnnotate.config else Color()

@export_group("Visibility")

## Do not remove [AnnotateCanvas] node from scene when running outside editor.
## User will not be able to paint on the canvas, even if this is set to [code] true [/code]
@export
var show_when_running := false


@export_group("Advanced")

## Current [AnnotateCanvas] mode, if true, the canvas is in the Annotate Mode, if false it is in the Edit Mode.
## The preffered way to toggle this is via. the toolbar.
@export
var annotate_mode := false

@export
## Index of annotate brush currently being used on the canvas.
## The preffered way to toggle this is via. the toolbar.
var annotate_brush_index: int = 0

## Stroke currently being painted by the user.
var _active_stroke: GDA_Stroke
## [code] true [/code] if user is currently trying to erase strokes.
var _erasing := false
var _eraser: Eraser

## Array of Strokes currently stored in the canvas.
var strokes: Array[PackedScene] = [ ]

## Dictionary between annotate brushes, and an array of GDA_AnnotateBrush.StrokeVariables
## Is updated on every call to ready.
@export
var stroke_variables := {}

## Number of strokes currently instantiated in the canvas.
var _stroke_instance_count := 0

func _ready():
	if not Engine.is_editor_hint() and not show_when_running:
		queue_free()

	set_notify_transform(true)

	# restore lines from previously saved state.
	_add_stroke_nodes(strokes.map(func(s) -> GDA_Stroke: return GDA_Stroke.load_stroke(s) as GDA_Stroke) as Array[GDA_Stroke])

	# update stroke_variables list.

	for annotate_brush: GDA_AnnotateBrush in GodotAnnotate.annotate_brushes:

		var brush_name = annotate_brush.get_brush_name()

		if not stroke_variables.has(brush_name):
			stroke_variables[brush_name] = {}

		# remove variables no longer present in the annotate brush.

		var annotate_brush_stroke_variables = annotate_brush.get_stroke_variables()

		for canvas_variable_name in stroke_variables[brush_name]:
			if not annotate_brush_stroke_variables.has(canvas_variable_name):
				stroke_variables[brush_name].erase(canvas_variable_name)

		# add any missing variables, setting them to their default value.

		for stroke_variable in annotate_brush_stroke_variables:
			if not stroke_variables[brush_name].has(stroke_variable):
				stroke_variables[brush_name][stroke_variable] = annotate_brush_stroke_variables[stroke_variable]

func _process(delta):

	if _active_stroke:
		get_annotate_brush().on_annotate_process(delta, _active_stroke, self)
	
	if _eraser != null:
		_eraser.position = get_local_mouse_position()

		var erase_stroke_indexes: Array[int] = []
		var erased_strokes: Dictionary = {}
		
		var eraser_transform := _eraser.get_global_transform()

		for i in range(get_child_count()):
			var stroke: GDA_Stroke = get_child(i) as GDA_Stroke
			if stroke != null and stroke.collides_with_circle(_eraser.shape, eraser_transform):
				erase_stroke_indexes.append(i)
				erased_strokes[i] = stroke

		# Only create an undoable erase action, if something is actually erased.
		if len(erase_stroke_indexes) > 0:
			var ur := GodotAnnotate.undo_redo

			ur.create_action("GodotAnnotateEraseStroke")
			ur.add_do_method(self, "_do_erase", erase_stroke_indexes)
			ur.add_undo_method(self, "_undo_erase", erased_strokes)
			ur.commit_action()
	
	if Engine.is_editor_hint():
		queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		canvas_changed.emit(self)

func _draw():
	# handles drawing of the cursor preview for the current annotate brush.
	if annotate_mode or get_meta("_edit_lock_", false) or _eraser != null:
		return
	
	elif GodotAnnotate.active_canvas == self:
		get_annotate_brush().draw_cursor(get_local_mouse_position(),
				brush_size,
				brush_color,
				self)

func _validate_property(property: Dictionary):
	# annotate_brush_index and strokes should ONLY be modified through this script.
	if property.name == "annotate_brush_index" \
		or property.name == "strokes":
			property.usage = PROPERTY_USAGE_NO_EDITOR

## Should be called whenever the canvas is no longer the active canvas.
func deactivate():
	if _eraser:
		_eraser.queue_free()
		_eraser = null

func on_editor_input(event: InputEvent) -> bool:

	# TODO: if this gets any larger, it should be split up into multiple functions.

	if get_meta("_edit_lock_", false):
		return false

	if annotate_mode:
		var mouse_event := event as InputEventMouseButton 
		
		if mouse_event != null and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			# Stroke Selection
			var select_shape := CircleShape2D.new()
			select_shape.radius = 10 / get_viewport().global_canvas_transform.get_scale().x

			var select_transform := Transform2D(0, get_global_mouse_position())

			var selection = EditorInterface.get_selection()

			for i in range(get_child_count()):
				var stroke: GDA_Stroke = get_child(i) as GDA_Stroke

				if stroke != null\
					and stroke.collides_with_circle(select_shape, select_transform)\
					and stroke != selection.get_selected_nodes()[-1]:
						
					if not mouse_event.shift_pressed:
						selection.clear()
					
					selection.add_node(stroke)
					return true

		return false

	if _active_stroke:
		
		if get_annotate_brush().should_end_stroke(event):
			
			# finalize stroke annotating
			get_annotate_brush().on_end_stroke(get_local_mouse_position(), _active_stroke, self)
			
			var success := _active_stroke.stroke_finished()
			
			if success:
				# save stroke as packed scene.
				strokes.append(_active_stroke.save_stroke())
				
				# add stroke creation to undo / redo history.

				var ur := GodotAnnotate.undo_redo

				ur.create_action("GodotAnnotateNewStroke")
				ur.add_do_method(self, "_redo_stroke", _active_stroke)
				ur.add_undo_method(self, "_undo_stroke", len(strokes) - 1)
				# Stroke was already added at this point, so we do not want to execute redo_stroke.
				ur.commit_action(false)
			else:
				_remove_stroke_nodes([_active_stroke])
				_active_stroke.queue_free()

			_active_stroke = null

			return true
			
		return get_annotate_brush().on_annotate_input(event, _active_stroke, self)
	
	elif event is InputEventMouseButton and _active_stroke == null:
		# erasing
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_eraser = EraserScene.instantiate()
			_eraser.stroke_size = brush_size
			add_child(_eraser)
			return true
		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed and _eraser != null:
			_eraser.queue_free()
			_eraser = null
			return true
		
	
	# Check if the current annotate brush wants to begin a new stroke,
	# If so, add the stroke to the scene, so the user can see the stroke being drawn in realtime.
	if get_annotate_brush().should_begin_stroke(event):
		_active_stroke = get_annotate_brush().on_begin_stroke(get_local_mouse_position(), brush_size, brush_color, stroke_variables[get_annotate_brush().get_brush_name()], self)
		_add_stroke_nodes([ _active_stroke ])
		
		return true
	
	return false


## Converts the current canvas into an image file and saves it to disk
func capture_canvas(file: String, scale: float) -> void:
	add_child(AnnotateCanvasCaptureViewport.new(self, file, scale))

## Retrieve annotate brush which is currently active on the canvas.
func get_annotate_brush() -> GDA_AnnotateBrush:
	return GodotAnnotate.get_annotate_brush(annotate_brush_index)

## Return the smallest Rect2, which contains all the strokes currently stored in the canvas
func get_canvas_area() -> Rect2:
	var boundaries: Array[Rect2] = []
	
	boundaries.assign(get_stroke_nodes()
		.map(func(s): return s.get_global_rect()))

	return _merge_rects(boundaries)

## Get an array of all strokes currently saved in the canvas.
func get_strokes() -> Array[PackedScene]:
	return strokes

## Retreive all children of current canvas, which are GDA_Strokes.
func get_stroke_nodes() -> Array[GDA_Stroke]:
	var strokes_arr: Array[GDA_Stroke] = []

	strokes_arr.assign(get_children()
		.filter(func(s): return s is GDA_Stroke and not s.is_queued_for_deletion()))

	return strokes_arr

## Adds the passed strokes to the canvas.
func import_strokes(new_strokes: Array[PackedScene]):
	strokes += new_strokes

	_add_stroke_nodes(new_strokes.map(func(s): return GDA_Stroke.load_stroke(s)))

# Undo Redo callbacks

func _undo_stroke(stroke_index: int):
	_remove_stroke_nodes([ get_child(stroke_index) as GDA_Stroke ])
	strokes.remove_at(stroke_index)


func _redo_stroke(stroke: GDA_Stroke):
	strokes.append(stroke.get_saved_stroke())
	_add_stroke_nodes([ stroke ])


## Erase all strokes at the passed indexes.
func _do_erase(erase_stroke_indexes: Array[int]):
	var erase_nodes: Array[GDA_Stroke] = [ ]
	var selected_nodes := EditorInterface.get_selection().get_selected_nodes()

	for erase_count in range(erase_stroke_indexes.size()):
		var stroke: GDA_Stroke = get_child(erase_stroke_indexes[erase_count])
		erase_nodes.append(stroke)

		# Keep track of how the new selection will look like after the strokes have been erased.
		var selection_index := selected_nodes.find(stroke)

		if selection_index >= 0 :
			selected_nodes.remove_at(selection_index)

		# subtract the target index by the amount of strokes deleted,
		# since these strokes no longer exist in the array.
		
		var remove_index := erase_stroke_indexes[erase_count] - erase_count
		strokes.remove_at(remove_index)

	# If the new selection does not contain a stroke or a canvas, we add the current canvas, for a smoother workflow.

	var valid_selection := false

	for node in selected_nodes:
		if node is GDA_Stroke or node is AnnotateCanvas:
			valid_selection = true
			break

	if not valid_selection:
		EditorInterface.get_selection().add_node(self)

	_remove_stroke_nodes(erase_nodes)


## Re-add all the passed strokes at the index of their key value.
func _undo_erase(erased_strokes: Dictionary):

	var indexes := erased_strokes.keys()
	indexes.sort()

	for insert_index in indexes:

		var stroke = erased_strokes[insert_index] as GDA_Stroke

		strokes.insert(insert_index, stroke.get_saved_stroke())
		
		# move stroke back to its original index, so the z-order is the same as when the stroke was erased.
		_add_stroke_nodes([ stroke ], insert_index)
		

# adds the given list of GDA_Stroke nodes to the canvas,
# making sure they all exist at the start of the canvas child array,
# with no other node types mixed with them.
func _add_stroke_nodes(nodes: Array, index: int = -1) -> void:
	var stroke_nodes: Array[GDA_Stroke]
	
	stroke_nodes.assign(nodes)

	var offset = 0

	if index > 0:
		offset = _stroke_instance_count - index

	for stroke_node in stroke_nodes:
		stroke_node.stroke_changed.connect(func(s): canvas_changed.emit(self))
		add_child(stroke_node)
		move_child(stroke_node, _stroke_instance_count - offset)
		_stroke_instance_count += 1

# stroke_nodes must only contains nodes which have been added via. _add_stroke_nodes.
func _remove_stroke_nodes(stroke_nodes: Array[GDA_Stroke]) -> void:
	for stroke_node in stroke_nodes:
		# stroke_node should NOT be freed here, as it may be undone,
		# and it is critical the readded stroke instance is the same as the removed one, 
		# otherwise transforms performed by the editor cannot be undone.
		remove_child(stroke_node)

	_stroke_instance_count -= len(stroke_nodes)

	canvas_changed.emit(self)


## Return the smallest possible Rect2 Which contains all the passed Rect2's.
func _merge_rects(rects: Array[Rect2]) -> Rect2:
	
	if len(rects) <= 0:
		return Rect2()
	
	var final_rect = rects[0]

	for rect in rects.slice(1):
		final_rect = final_rect.merge(rect)
		
	return final_rect



