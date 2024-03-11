@tool
class_name GDA_AnnotateMode
extends Resource
###
### Abstract / Interface class representing an annotation mode for the GodotAnnotate plugin.
### All methods defined should be seen as virtual methods, which have no effect if not implemented.
###

## Returns the icon to be used to represent the AnnotateMode.
func get_icon_path() -> String:
	return ""

## Returns the name to be used to represent the AnnotateMode.
func get_mode_name() -> String:
	return ""

## Draw a cursor on a canvas item, at the given position, with the given brush size and color.
func draw_cursor(pos: Vector2, brush_size: float, brush_color: Color, canvas: CanvasItem) -> void:
	pass

## Begin a stroke with the given size and color, at the given position.
## Should return the new stroke.
## it will be added to the AnnotateCanvas node and will be visible to the user during annotation.
func on_begin_stroke(pos: Vector2, size: float, color: Color, canvas: AnnotateCanvas) -> Node2D:
	return Node2D.new()

## End a stroke with the final point being drawn at the given parameters.
func on_end_stroke(pos: Vector2, stroke: Node2D, canvas: AnnotateCanvas) -> void:
	pass

## Called repeadetly during stroke annotation, similar to _process.
## (most likely called on every _process of the parent AnnotateCanvas, but this is not guaranteed)
func on_annotate_process(delta: float, stroke: Node2D, canvas: AnnotateCanvas) -> void:
	pass

## Called any time the AnnotateMode needs to handle an InputEvent during a stroke annotation.
## Return whether the event should be blocked from reaching any other input handlers.
func on_annotate_input(event: InputEvent) -> bool:
	return false

## Called when an AnnotateCanvas wants to check if an AnnotateMode wants to begin annotating.
func should_begin_stroke(event: InputEvent) -> bool:
	return false

## Called when an AnnotateCanvas wants to check if an AnnotateMode wnats to end annotating.
func should_end_stroke(event: InputEvent) -> bool:
	return false
