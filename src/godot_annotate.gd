@tool
class_name GodotAnnotate
extends EditorPlugin
##
## Handles initialization, deinitialization and event forwarding to [AnnotateCanvas] nodes.
##

static var selected_canvas: AnnotateCanvas

static var canvas_toolbar: Control

## List of scripts to load into the annotate_modes list.
static var annotate_mode_scripts: Array[String] = [
	"res://addons/GodotAnnotate/src/annotate_modes/freehand/freehand_mode.gd",
	"res://addons/GodotAnnotate/src/annotate_modes/rectangle/no_fill/rectangle_no_fill_mode.gd",
	"res://addons/GodotAnnotate/src/annotate_modes/rectangle/fill/rectangle_fill_mode.gd",
	"res://addons/GodotAnnotate/src/annotate_modes/capsule/no_fill/capsule_no_fill_mode.gd",
	"res://addons/GodotAnnotate/src/annotate_modes/capsule/fill/capsule_fill_mode.gd",
]

static var annotate_modes: Array[GDA_AnnotateMode] = []

## UndoRedoManager for the GodotAnnotate plugin.
static var undo_redo: EditorUndoRedoManager

func _enter_tree():
	# initialize variables	
	canvas_toolbar = preload("res://addons/GodotAnnotate/src/toolbar/annotate_toolbar.tscn").instantiate()
	canvas_toolbar.visible = false
	
	undo_redo = get_undo_redo()
	
	# load annotate modes
	
	for script_path in annotate_mode_scripts:
		annotate_modes.append(load(script_path).new() as GDA_AnnotateMode)
	
	# setup signals
	
	EditorInterface.get_selection().selection_changed.connect(_on_selection_changed)
	
	# setup toolbar
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, canvas_toolbar)

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, canvas_toolbar)
	canvas_toolbar.queue_free()
	
	EditorInterface.get_selection().selection_changed.disconnect(_on_selection_changed)
	
	# free variables

	canvas_toolbar.queue_free()
	
	annotate_modes = [ ]
	

## Forwards relevant 2d editor user inputs to an [AnnotateCanvas] node.
func _forward_canvas_gui_input(event: InputEvent):
	if event is InputEventKey:
		var ke: InputEventKey = event
		if ke.key_label == KEY_F10:
			EditorInterface.get_selection().clear()
			EditorInterface.get_selection().add_node(selected_canvas.get_child(0))
			pass
		pass

	if not selected_canvas or selected_canvas.lock_canvas:
		return false
	
	return selected_canvas.on_editor_input(event)

# returns true on all GodotAnnotate, so editor inputs can be handled by the plugin.
func _handles(object):
	return object is AnnotateCanvas

## Keeps track of currently selected node, as special action is required when an [AnnotateCanvas] node is selected.
func _on_selection_changed():
	canvas_toolbar.visible = false
	selected_canvas = null
	
	var nodes := EditorInterface.get_selection().get_selected_nodes()

	if len(nodes) == 1 and nodes[0] is AnnotateCanvas:
		canvas_toolbar.visible = true
		selected_canvas = nodes[0] as AnnotateCanvas
		canvas_toolbar._on_new_canvas(selected_canvas)

static func get_annotate_mode(mode_index: int) -> GDA_AnnotateMode:
	return annotate_modes[mode_index]
