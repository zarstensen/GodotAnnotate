@tool
class_name GodotAnnotate
extends EditorPlugin
##
## Handles initialization, deinitialization and event forwarding to [AnnotateCanvas] nodes.
##

const CONFIG_FILE: String = "res://addons/GodotAnnotate/config.ini"

static var active_canvas: AnnotateCanvas

static var canvas_toolbar: Control

## List of scripts to load into the annotate_brushes list.
static var annotate_brush_scripts: Array[String] = [
	"res://addons/GodotAnnotate/src/brushes/freehand/freehand_brush.gd",
	"res://addons/GodotAnnotate/src/brushes/rectangle/rectangle_brush.gd",
	"res://addons/GodotAnnotate/src/brushes/capsule/capsule_brush.gd",
	"res://addons/GodotAnnotate/src/brushes/polygon/polygon_brush.gd",
]

## List of loaded GDA_AnnotateBrush from annotate_brush_scripts array.
static var annotate_brushes: Array[GDA_AnnotateBrush] = []

## UndoRedoManager for the GodotAnnotate plugin.
static var undo_redo: EditorUndoRedoManager

static var config: ConfigFile


func _enter_tree():
	# Load plugin configuration file

	config = ConfigFile.new()

	var err := config.load(CONFIG_FILE)

	# If something goes wrong, (including not finding the file on disk),
	# then simply create a new config file.
	if err != OK:
		config.save(CONFIG_FILE)

	# initialize variables	
	canvas_toolbar = preload("res://addons/GodotAnnotate/src/toolbar/annotate_toolbar.tscn").instantiate()
	canvas_toolbar.visible = false
	
	undo_redo = get_undo_redo()
	
	# load annotate brushes
	
	for script_path in annotate_brush_scripts:
		annotate_brushes.append(load(script_path).new() as GDA_AnnotateBrush)
	
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

	annotate_brushes = [ ]

	config.save(CONFIG_FILE)


## Forwards relevant 2d editor user inputs to an [AnnotateCanvas] node and the AnnotateToolbar node if the canvas node does not consume the input.
func _forward_canvas_gui_input(event: InputEvent):
	if not is_instance_valid(active_canvas):
		return false
	
	return active_canvas.on_editor_input(event) or canvas_toolbar.on_editor_event(event)


# returns true on all GodotAnnotate, so editor inputs can be handled by the plugin.
func _handles(object):
	return object is AnnotateCanvas or object is GDA_Stroke


## Keeps track of currently selected node, as special action is required when an [AnnotateCanvas] node is selected.
func _on_selection_changed():
	canvas_toolbar.visible = false

	if is_instance_valid(active_canvas):
		active_canvas.deactivate()
		active_canvas = null
	
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()

	for node in selected_nodes:
		if node is AnnotateCanvas:
			active_canvas = node
			break
		elif node is GDA_Stroke and node.get_parent() is AnnotateCanvas:
			active_canvas = node.get_parent()
			break

	if is_instance_valid(active_canvas):
		canvas_toolbar.visible = true
		canvas_toolbar._on_new_canvas(active_canvas)


static func get_annotate_brush(brush_index: int) -> GDA_AnnotateBrush:
	return annotate_brushes[brush_index]
