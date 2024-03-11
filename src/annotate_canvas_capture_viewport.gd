extends SubViewport
##
## Class responsible for saving an image version of a AnnotateCanvas node to disk.
##

var _first_process := true
var _file_location: String
var _strokes: Array[PackedScene]
var _canvas: AnnotateCanvas = AnnotateCanvas.new()
var _scale: float

## Construct an annotate canvas capture node. [br]
## [param AnnotateCanvas]: AnnotateCanvas which should be saved as an image to disk.
## [param file]: Filename the image will be stored under.
## [param scale]: What the resolution of the image should be scaled by.
func _init(canvas: AnnotateCanvas, file: String, scale: float = 1.0):
	# duplicating the AnnotateCanvas leads to some issues with strokes being present twice,
	# so instead we create a new AnnotateCanvas, and import the strokes from the target canvas,
	# to solve this issue.
	_strokes = canvas.get_strokes()
	add_child(_canvas)

	_file_location = file
	_scale = scale


func _ready() -> void:
	_canvas.import_strokes( _strokes)

	var canvas_area := _canvas.get_canvas_area()
	
	# viewports render anything from (0, 0) to (width, height),
	# so we want to offset the canvas contents to make sure they fit inside this area.
	_canvas.position = -canvas_area.position * _scale
	_canvas.scale *= _scale
	canvas_area.position = Vector2.ZERO
	
	size = canvas_area.size * _scale
	
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	transparent_bg = true

func _process(_delta):
	if _first_process:
		# allow viewport to update itself before capturing
		_first_process = false
		return
		
	get_texture().get_image().save_png(_file_location)
	
	# make sure new image file is visible in the editor filesystem
	EditorInterface.get_resource_filesystem().scan()
	
	queue_free()
