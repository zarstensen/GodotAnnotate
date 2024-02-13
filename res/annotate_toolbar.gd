@tool
extends HBoxContainer

var canvas: AnnotateCanvas

var canvas_image_dialog: FileDialog = preload("res://addons/GodotAnnotate/res/CanvasImageDialog.tscn").instantiate()
var upscale_factor_dialog: ConfirmationDialog = preload("res://addons/GodotAnnotate/res/UpscaleFactorDialog.tscn").instantiate()

func _ready() -> void:
	$AnnotateMode.text = ""
	
	upscale_factor_dialog.confirmed.connect(func() -> void:
			EditorInterface.popup_dialog_centered(canvas_image_dialog)
			)

	canvas_image_dialog.file_selected.connect(func(path: String) -> void:
			canvas._on_capture_canvas(path, upscale_factor_dialog.get_node("UpscaleFactorInput").value)
			)

# Called when a new annotate canvas node is selected.
func _on_new_canvas(new_canvas: AnnotateCanvas) -> void:
	canvas = new_canvas
	
	$ToggleAnnotateButton.set_pressed_no_signal(not canvas.lock_canvas)
	
	# TODO: annotate mode


func _on_canvas_to_image_pressed() -> void:
	upscale_factor_dialog.get_node("UpscaleFactorInput").value = 1
	EditorInterface.popup_dialog_centered(upscale_factor_dialog)

func _on_toggle_annotate_button_toggled(toggled_on: bool) -> void:
	canvas.lock_canvas = not toggled_on


func _on_annotate_mode_item_selected(index: int) -> void:
	$AnnotateMode.text = ""
