@tool
extends Button

signal canvas_to_image_confirmed(path: String, scale: float)

func _on_pressed() -> void:
	$UpscaleFactorDialog.popup_centered()

func _on_upscale_factor_dialog_confirmed() -> void:
	$CanvasImageDialog.popup_centered()

func _on_canvas_image_dialog_file_selected(path:String) -> void:
	canvas_to_image_confirmed.emit(path, $UpscaleFactorDialog/UpscaleFactorInput.value)