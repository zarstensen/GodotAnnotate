@tool
class_name GodotAnnotate
extends EditorPlugin
##
## Handles initialization, deinitialization and event forwarding to [AnnotateCanvas] nodes.
##

const AnnotateMode = preload("res://addons/GodotAnnotate/src/annotate_mode.gd")


static var selected_canvas: AnnotateCanvas

static var poly_in_progress := false

static var canvas_toolbar: Control

## List of scripts to load into the annotate_modes list.
static var annotate_mode_scripts: Array[String] = [
	"res://addons/GodotAnnotate/src/annotate_modes/freehand/freehand_mode.gd",
]

static var annotate_modes: Array[AnnotateMode] = []

func _enter_tree():
	
	# initialize variables
	
	canvas_toolbar = preload("res://addons/GodotAnnotate/res/annotate_toolbar.tscn").instantiate()
	canvas_toolbar.visible = false
	
	poly_in_progress = false
	
	# load annotate modes
	
	for script_path in annotate_mode_scripts:
		annotate_modes.append(load(script_path).new() as AnnotateMode)
	
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
	
	for annotate_mode in annotate_modes:
		annotate_mode.queue_free()
	

## Forwards relevant 2d editor user inputs to an [AnnotateCanvas] node.
func _forward_canvas_gui_input(event):
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
