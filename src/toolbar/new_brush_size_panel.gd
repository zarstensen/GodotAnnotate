@tool
extends PopupPanel

signal new_size_confirmed(new_size: float)

func popup_value(popup_rect: Rect2, max_size_value: float):
	popup(popup_rect)
	%MaxBrushSizeInput.value = max_size_value

func _on_window_input(event:InputEvent) -> void:
	var key_event := event as InputEventKey

	if key_event == null or not key_event.pressed:
		return

	if key_event.keycode == KEY_ESCAPE:
		hide()
	
	if key_event.keycode == KEY_ENTER:
		new_size_confirmed.emit(%MaxBrushSizeInput.value)
		hide()
