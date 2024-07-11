@tool
class_name GDA_Stroke
extends Control
##
## Control node acting as the parent node to a godot annotate stroke.
##


signal stroke_changed(stroke: GDA_Stroke)

## Size of the stroke lines (if relevant)
@export
var stroke_size: float:
	set(v):
		stroke_size = v

		if not is_node_ready():
			await ready

		_set_stroke_size(stroke_size)
		on_stroke_changed()
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
		on_stroke_changed()
	get:
		return stroke_color

var _saved_stroke: PackedScene

var _is_stroke_finished := true


## Load a GDA_Stroke from the passed scene.
## This should be the used in favor of saved_stroke.instantiate(), if any PackedScene functionallity is used.
static func load_stroke(saved_stroke: PackedScene):
	var stroke = saved_stroke.instantiate()
	stroke._saved_stroke = saved_stroke
	return stroke

func _ready() -> void:
	_stroke_resized()

## Initialize a stroke with the given stroke size, color and starting position.
## Should only be called when the stroke is first created, and not when instantiated from a PackedScene saved to a canvas.
func stroke_init(stroke_size: float, stroke_color: Color, first_point: Vector2) -> void:
	_is_stroke_finished = false
	_saved_stroke = PackedScene.new()

	ready.connect(func():
		self.stroke_size = stroke_size
		self.stroke_color = stroke_color
		_stroke_created(first_point)
		)

## Packs stroke into scene passed to stroke_init or load_stroke and returns the PackedScene.
func save_stroke() -> PackedScene:
	_saved_stroke.pack(self)
	return get_saved_stroke()

## Returns packed scene passed to stroke_init or load_stroke.
func get_saved_stroke() -> PackedScene:
	return _saved_stroke

## Finish annotating the stroke.
## After this has been called, the stroke should only be modified by changing the
## stroke_size, stroke_color or the size / position of the Stroke control node.
func stroke_finished() -> bool:
	_is_stroke_finished = true

	var update_stroke := func():
		_stroke_resized()
		on_stroke_changed()

	update_stroke.call_deferred()

	return _stroke_finished()

## Check if the stroke collides with a given circle.
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

func get_collision_area() -> Area2D:
	return %CollisionArea

func on_stroke_changed():
	save_stroke()
	stroke_changed.emit(self)

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

## Virtual method called when the stroke is finished being annotated.
## Returns whether the stroke was completed succesfully or not.
## If false is returned, the stroke is deleted as soon as possible.
func _stroke_finished() -> bool:
	return true

# signal callback for Stroke.resized signal.
func _on_resized() -> void:
	# update the boundary shape to match the new size of the Stroke control node
	%BoundaryShape.shape.size = size
	%BoundaryShape.position = size / 2

	# we do not want to notify the stroke of it being resized during annotation.
	if _is_stroke_finished:
		_stroke_resized()

func _on_item_rect_changed() -> void:
	on_stroke_changed()
