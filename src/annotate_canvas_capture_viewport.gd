class_name AnnotateCanvasCaptureViewport
extends SubViewport
##
## Class responsible for saving an image version of a AnnotateCanvas node to disk.
##

var _first_process := true
var _file_location: String

## Construct a AnnotateCanvasCaptureViewport node. [br]
## [param AnnotateCanvas]: AnnotateCanvas which should be saved as an image to disk.
## [param file]: Filename the image will be stored under.
## [param scale]: What the resolution of the image should be scaled by.
func _init(canvas: AnnotateCanvas, file: String, scale: float = 1.0):
	canvas = canvas.duplicate()
	_file_location = file
	
	var canvas_area := canvas.get_canvas_area()
	
	# viewports render anything from (0, 0) to (width, height),
	# so we want to offset the canvas contents to make sure they fit inside this area.
	canvas.position = -canvas_area.position * scale
	canvas.scale *= scale
	canvas_area.position = Vector2.ZERO
	
	add_child(canvas)
	size = canvas_area.size * scale
	
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	transparent_bg = true

func _process(_delta):
	if _first_process:
		# allow viewport to update itself before capturing
		_first_process = false
		return
		
	get_texture().get_image().save_png(_file_location)
	
	# make sure new image file is visible in the editor filesystem
	GodotAnnotate.editor_interface.get_resource_filesystem().scan()
	
	queue_free()
