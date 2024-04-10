@tool
extends AspectRatioContainer

# Size of the container when the editor scale is at 100%
@export
var unscaled_size: Vector2

	
func _draw():
	custom_minimum_size = unscaled_size * EditorInterface.get_editor_scale()
