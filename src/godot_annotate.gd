@tool
class_name GodotAnnotate
extends EditorPlugin
## Handles initialization, deinitialization and event forwarding to [AnnotateCanvas] nodes.

static var selected_canvas: AnnotateCanvas

func _enter_tree():
	add_custom_type("AnnotateCanvas", "Node2D", preload("annotate_canvas.gd"), preload("../annotate_layer.svg"))

func _exit_tree():
	remove_custom_type("AnnotateCanvas")

## Forwards relevant 2d editor user inputs to an [AnnotateCanvas] node.
func _forward_canvas_gui_input(event):
	if not selected_canvas or selected_canvas.lock_canvas:
		return false
		
	if event is InputEventMouseButton:
		# drawing
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			selected_canvas._on_begin_stroke()
			return true
		elif event.button_index == MOUSE_BUTTON_LEFT && not event.pressed:
			selected_canvas._on_end_stroke()
			return true
		
		# erasing
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			selected_canvas._on_begin_erase()
			return true
		elif event.button_index == MOUSE_BUTTON_RIGHT && not event.pressed:
			selected_canvas._on_end_erase()
			return true
		
		# stroke size (shift + scroll)
		# cannot use ctrl or alt, since they control view position and zoom,
		# and cannot be prevented from being forwarded by returning true.
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN && Input.is_key_pressed(KEY_SHIFT):
			if event.pressed:
				selected_canvas._on_stroke_resize(-1)
			
			return true
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP && Input.is_key_pressed(KEY_SHIFT):
			if event.pressed:
				selected_canvas._on_stroke_resize(1)
			
			return true

	return false

## Keeps track of currently selected node, as special action is required when an [AnnotateCanvas] node is selected.
func _handles(object):
	if object is AnnotateCanvas:
		selected_canvas = object
		return true
	
	selected_canvas = null
	
	return false
