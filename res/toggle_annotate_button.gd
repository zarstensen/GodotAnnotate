@tool
extends Button

func _on_toggled(toggled_on):
	GodotAnnotate.selected_canvas.lock_canvas = not toggled_on
