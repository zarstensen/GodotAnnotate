class_name AnnotateCanvasCaptureViewport
extends SubViewport

var _first_process := true
var _file_location: String

func _init(canvas: AnnotateCanvas, file: String, scale: float = 1.0):
	canvas = canvas.duplicate()
	_file_location = file
	
	# get top, left and bottom right corner of canvas.
	
	var canvas_area := canvas.get_canvas_area()
	
	canvas.position = canvas_area.position
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
	print("CAPTURE CANVAS")
	queue_free()
