@tool
extends HSlider

func _ready() -> void:
	max_value = GodotAnnotate.config.get_value("toolbar", "max_brush_size", 100)

func _on_gui_input(event:InputEvent) -> void:
	# User can set the maximum value of the slider by rightclicking on the slider.
	# the context menu is implemented as a popup which pops up at the mouse position.
	
	var mouse_button_event = event as InputEventMouseButton

	if mouse_button_event != null \
		and mouse_button_event.pressed \
		and mouse_button_event.button_index == MOUSE_BUTTON_RIGHT:
			$ContextMenu.popup(Rect2(get_global_mouse_position() + Vector2(0, $ContextMenu.size.y), Vector2.ZERO))

func _on_context_menu_id_pressed(id:int) -> void:
	
	# this if statement should always evaluate to false.
	if id != 0:
		return

	%MaxBrushSizeInput.value = max_value
	$NewBrushSizePanel.popup(Rect2($ContextMenu.position, Vector2.ZERO))

func _on_new_max_size_confirmed(new_size:float) -> void:
	max_value = new_size
	GodotAnnotate.config.set_value("toolbar", "max_brush_size", max_value)
