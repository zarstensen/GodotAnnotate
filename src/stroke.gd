@tool
class_name GDA_Stroke
extends Control
##
## Control node acting as the parent node to a godot annotate stroke.
##

const Canvas = preload("res://addons/GodotAnnotate/src/annotate_canvas.gd")

## Size of the stroke lines (if relevant)
@export
var stroke_size: float:
	set(v):
		stroke_size = v

		if not is_node_ready():
			await ready

		_set_stroke_size(stroke_size)
	
	get:
		return stroke_size

## Color of the entire stroke.
@export
var stroke_color: Color:
	set(v):
		stroke_color = v

		if not is_node_ready():
			await ready

		_set_stroke_color(stroke_color)
	
	get:
		return stroke_color

var _is_stroke_finished := true

func _ready() -> void:
	_stroke_resized()

## Virtual method calledwhenever the stroke is created for the first time, at the given point.
func _stroke_created(first_point: Vector2) -> void:
	pass

## Virtual method called whenever stroke_size is set,
## Should be overriden if specific actions needs to be taken to update the color of the implementing stroke.
func _set_stroke_size(size: float) -> void:
	pass

## Virtual method called whenever stroke_color is set,
func _set_stroke_color(size: Color) -> void:
	pass

## Virtual method called whenever the Stroke control node is resized.
## This is also called whenever the stroke is loaded from disk, or it has finished being annotated.
func _stroke_resized() -> void:
	pass

## Initialize a stroke with the given stroke size, color and starting position.
## Should only be called when the stroke is first created, and not when instantiated from a PackedScene saved to a canvas.
func stroke_init(stroke_size: float, stroke_color: Color, first_point: Vector2) -> void:
	_is_stroke_finished = false
	
	ready.connect(func():
		self.stroke_size = stroke_size
		self.stroke_color = stroke_color
		_stroke_created(first_point)
		)

## Finish annotating the stroke.
## After this has been called, the stroke should only be modified by changing the
## stroke_size, stroke_color or the size / position of the Stroke control node.
func stroke_finished() -> void:
	_is_stroke_finished = true
	_stroke_resized()

# Check if the stroke collides with a given circle.
func collides_with_circle(circle: CircleShape2D, transform: Transform2D) -> bool:
	# first check if erase cursor is inside the strokes boundary box,
	# before using the more refined CollisionArea Area2D,
	# in order to reduce overhead.

	if not circle.collide(transform, %BoundaryShape.shape, %BoundaryShape.get_global_transform()):
		return false

	# now go through each shape in the collision area2d and check if it collides with the cursor.

	for child in %CollisionArea.get_children():
		var shape := child as CollisionShape2D

		if shape != null && circle.collide(transform, shape.shape, shape.get_global_transform()):
			return true
	
	return false


# signal callback for Stroke.resized signal.
func _on_resized() -> void:
	# update the boundary shape to match the new size of the Stroke control node
	%BoundaryShape.shape.size = size
	%BoundaryShape.position = size / 2
	
	# we do not want to notify the stroke of it being resized during annotation.
	if _is_stroke_finished:
		_stroke_resized()
