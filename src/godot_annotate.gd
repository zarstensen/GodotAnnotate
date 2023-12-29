@tool
class_name GodotAnnotate
extends EditorPlugin
##
## Handles initialization, deinitialization and event forwarding to [AnnotateCanvas] nodes.
##

static var selected_canvas: AnnotateCanvas

static var poly_in_progress := false

static var canvas_image_dialog_scene := preload("res://addons/GodotAnnotate/res/CanvasImageDialog.tscn")
static var upscale_factor_dialog_scene := preload("res://addons/GodotAnnotate/res/UpscaleFactorDialog.tscn")

static var editor_interface: EditorInterface

func _enter_tree():
	add_custom_type("AnnotateCanvas", "Node2D", preload("res://addons/GodotAnnotate/src/annotate_canvas.gd"), preload("res://addons/GodotAnnotate/annotate_layer.svg"))
	editor_interface = get_editor_interface()

func _exit_tree():
	remove_custom_type("AnnotateCanvas")

## Forwards relevant 2d editor user inputs to an [AnnotateCanvas] node.
## TODO: clean this up a bit.
func _forward_canvas_gui_input(event):
	if not selected_canvas or selected_canvas.lock_canvas:
		return false
	
	if event is InputEventKey:
		
		# canvas capture (shortcut: shift + alt + s)
		if event.keycode == KEY_S && event.pressed && event.alt_pressed && event.shift_pressed:
			var upscale_factor_dialog := upscale_factor_dialog_scene.instantiate()
			upscale_factor_dialog.confirmed.connect(func():
				
				var canvas_image_dialog := canvas_image_dialog_scene.instantiate()
				canvas_image_dialog.file_selected.connect(func(file):
					
					# upscale factor is present in the spinbox child of the upscale factor dialog.
					selected_canvas._on_capture_canvas(file, upscale_factor_dialog.get_child(0).value)
				
				)
				
				get_editor_interface().popup_dialog_centered(canvas_image_dialog)
			
			)
			
			get_editor_interface().popup_dialog_centered(upscale_factor_dialog)
		
		# polygon drawing
		if poly_in_progress:
			if event.keycode == KEY_ALT && !event.pressed:
				selected_canvas._on_end_stroke()
				poly_in_progress = false
				return true
	
	if event is InputEventMouseButton:
		# drawing
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if event.alt_pressed && not poly_in_progress:
				selected_canvas._on_begin_stroke()
				poly_in_progress = true
			if poly_in_progress:
				selected_canvas._on_draw_poly_stroke()
			else:
				selected_canvas._on_begin_stroke()
			return true
		elif event.button_index == MOUSE_BUTTON_LEFT && not event.pressed && not poly_in_progress:
			if !poly_in_progress:
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
