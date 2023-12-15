@tool
class_name GodotAnnotate
extends EditorPlugin
## Handles initialization, deinitialization and event forwarding to [AnnotateCanvas] nodes.

static var selected_layer: AnnotateCanvas

func _enter_tree():
	add_custom_type("AnnotateCanvas", "Node2D", preload("annotate_canvas.gd"), preload("../annotate_layer.svg"))

func _exit_tree():
	remove_custom_type("AnnotateCanvas")

## Forwards relevant 2d editor user inputs to an [AnnotateCanvas] node.
func _forward_canvas_gui_input(event):
	if not selected_layer:
		return false
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			selected_layer._on_begin_stroke()
			return true
		elif event.button_index == MOUSE_BUTTON_LEFT && not event.pressed:
			selected_layer._on_end_stroke()
			return true
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			selected_layer._on_begin_erase()
			return true
		elif event.button_index == MOUSE_BUTTON_RIGHT && not event.pressed:
			selected_layer._on_end_erase()
			return true
				
	return false

## Keeps track of currently selected node, as special action is required when an [AnnotateCanvas] node is selected.
func _handles(object):
	if object is AnnotateCanvas:
		selected_layer = object
		return true
	
	selected_layer = null
	
	return false
