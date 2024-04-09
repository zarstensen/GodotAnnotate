@tool
extends HBoxContainer

var canvas: AnnotateCanvas

## Percentage size increase to stroke size caused by shift + scroll.
const SIZE_SCROLL_PERC: float = 0.1

func _ready() -> void:
	# setup annotate mode dropdown
	
	$AnnotateModeOption.clear()

	for annotate_mode in GodotAnnotate.annotate_modes:
		$AnnotateModeOption.add_icon_item(load(annotate_mode.get_icon_path()), annotate_mode.get_mode_name())

# Called when a new annotate canvas node is selected.
func _on_new_canvas(new_canvas: AnnotateCanvas) -> void:
	canvas = new_canvas
	
	$ToggleAnnotateButton.set_pressed_no_signal(not canvas.lock_canvas)
	$AnnotateModeOption.selected = canvas.annotate_mode_index

	$BrushSizeSlider.value = canvas.brush_size
	$BrushColorPickerButton.color = canvas.brush_color

	update_variables()

func _on_canvas_to_image_confirmed(path: String, scale: float) -> void:
	canvas.capture_canvas(path, scale)

func _on_toggle_annotate_button_toggled(toggled_on: bool) -> void:
	canvas.lock_canvas = not toggled_on

func _on_annotate_mode_item_selected(index: int) -> void:
	canvas.annotate_mode_index = index
	update_variables()

func _on_brush_size_slider_value_changed(value:float) -> void:
	canvas.brush_size = value

func _on_brush_color_picker_button_color_changed(color:Color) -> void:
	canvas.brush_color = color

func on_editor_event(event: InputEvent) -> bool:
	
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton

	if mouse_event == null:
		return false

	var button_index = event.button_index

	# stroke size (shift + scroll)
	# cannot use ctrl or alt, since they control view position and zoom,
	# and cannot be prevented from being forwarded by returning true.
	if (button_index == MOUSE_BUTTON_WHEEL_DOWN or button_index == MOUSE_BUTTON_WHEEL_UP) and event.pressed and Input.is_key_pressed(KEY_SHIFT):
		
		var direction = 0

		match button_index:
			MOUSE_BUTTON_WHEEL_DOWN:
				direction = -1
			MOUSE_BUTTON_WHEEL_UP:
				direction = 1

		var new_size : float = $BrushSizeSlider.value
		new_size *= 1 + direction * SIZE_SCROLL_PERC
		new_size = min($BrushSizeSlider.max_value as float, max(new_size, 1))
			
		$BrushSizeSlider.value = new_size
		
		return true

	return false

func update_variables():
	# remove all previous variable buttons.
	for c in %StrokeVariablesContainer.get_children():
		c.queue_free()

	var annotate_mode_name =canvas.get_annotate_mode().get_mode_name()

	for variable_name in canvas.stroke_variables[annotate_mode_name]:
		
		var variable_button := CheckBox.new()

		variable_button.text = variable_name
		variable_button.button_pressed = canvas.stroke_variables[annotate_mode_name][variable_name]
		variable_button.toggled.connect(func(new_val: bool):
			canvas.stroke_variables[annotate_mode_name][variable_name] = new_val
			)

		%StrokeVariablesContainer.add_child(variable_button)

	%VariablesSeparator.visible = canvas.stroke_variables[annotate_mode_name].size() > 0
