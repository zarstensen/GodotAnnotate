@tool
class_name GDA_AnnotateBrush
extends Resource
###
### Abstract / Interface class representing an annotation brush for the GodotAnnotate plugin.
### All methods defined should be seen as virtual methods, which have no effect if not implemented.
###

## Returns the icon to be used to represent the AnnotateBrush.
func get_icon_path() -> String:
	return ""

## Returns the name to be used to represent the AnnotateBrush.
func get_brush_name() -> String:
	return ""

## Each annotate brush has the posibility to expose variables the user can use to configure the stroke being created.
## For now each variable is a simple true false value.
## The annotate brush informs the addon of the variables by returning them in this dictionary.
## A key in this dictionary is the name of the variable, and the value is the default value of the variable.
func get_stroke_variables() -> Dictionary:
	return { }

## Draw a cursor on a canvas item, at the given position, with the given brush size and color.
func draw_cursor(pos: Vector2, brush_size: float, brush_color: Color, canvas: CanvasItem) -> void:
	pass

## Begin a stroke with the given size and color, at the given position.
## Should return the new stroke.
## it will be added to the AnnotateCanvas node and will be visible to the user during annotation.
## the variables dictionary have all the keys which have been returned from get_stroke_variables, as well as their actual values.
func on_begin_stroke(pos: Vector2, size: float, color: Color, variables: Dictionary, canvas: AnnotateCanvas) -> GDA_Stroke:
	return GDA_Stroke.new()

## End a stroke with the final point being drawn at the given parameters.
func on_end_stroke(pos: Vector2, stroke: GDA_Stroke, canvas: AnnotateCanvas) -> void:
	pass

## Called repeadetly during stroke annotation, similar to _process.
## (most likely called on every _process of the parent AnnotateCanvas, but this is not guaranteed)
func on_annotate_process(delta: float, stroke: GDA_Stroke, canvas: AnnotateCanvas) -> void:
	pass

## Called any time the AnnotateBrush needs to handle an InputEvent during a stroke annotation.
## Return whether the event should be blocked from reaching any other input handlers.
func on_annotate_input(event: InputEvent, stroke: GDA_Stroke, canvas: AnnotateCanvas) -> bool:
	return false

## Called when an AnnotateCanvas wants to check if an GDA_AnnotateBrush wants to begin annotating.
func should_begin_stroke(event: InputEvent) -> bool:
	return false

## Called when an AnnotateCanvas wants to check if an GDA_AnnotateBrush wants to end annotating.
func should_end_stroke(event: InputEvent) -> bool:
	return false
