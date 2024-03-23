@tool
extends HBoxContainer

var canvas: AnnotateCanvas

var canvas_image_dialog: FileDialog = preload("res://addons/GodotAnnotate/popups/canvas_image_dialog.tscn").instantiate()
var upscale_factor_dialog: ConfirmationDialog = preload("res://addons/GodotAnnotate/popups/upscale_factor_dialog.tscn").instantiate()

func _ready() -> void:
	upscale_factor_dialog.confirmed.connect(func() -> void:
			EditorInterface.popup_dialog_centered(canvas_image_dialog)
			)

	canvas_image_dialog.file_selected.connect(func(path: String) -> void:
			canvas.capture_canvas(path, upscale_factor_dialog.get_node("UpscaleFactorInput").value)
			)

	upscale_factor_dialog.set_unparent_when_invisible(true)
	canvas_image_dialog.set_unparent_when_invisible(true)
			
	# setup annotate mode dropdown
	
	$AnnotateMode.clear()

	for annotate_mode in GodotAnnotate.annotate_modes:
		$AnnotateMode.add_icon_item(load(annotate_mode.get_icon_path()), annotate_mode.get_mode_name())
	
	$AnnotateMode.text = ""

func _notification(what: int) -> void:
	# popup scenes are not removed when this node is freed, since unparent when invisible is set to true for them,
	# so we need to do this manually upon toolbar node deletion.
	if(what == NOTIFICATION_PREDELETE):
		upscale_factor_dialog.queue_free()
		canvas_image_dialog.queue_free()

# Called when a new annotate canvas node is selected.
func _on_new_canvas(new_canvas: AnnotateCanvas) -> void:
	canvas = new_canvas
	$ToggleAnnotateButton.set_pressed_no_signal(not canvas.lock_canvas)
	$AnnotateMode.selected = canvas.annotate_mode_index
	$AnnotateMode.text = ""


func _on_canvas_to_image_pressed() -> void:
	upscale_factor_dialog.get_node("UpscaleFactorInput").value = 1
	EditorInterface.popup_dialog_centered(upscale_factor_dialog)

func _on_toggle_annotate_button_toggled(toggled_on: bool) -> void:
	canvas.lock_canvas = not toggled_on


func _on_annotate_mode_item_selected(index: int) -> void:
	$AnnotateMode.text = ""
	canvas.annotate_mode_index = index
