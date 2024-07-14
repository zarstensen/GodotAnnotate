@tool
@icon("res://addons/GodotAnnotate/src/collision/canvas_collision_shape_icon.svg")
class_name CanvasCollisionShape
extends Node
##
## Node responsible for adding a series of CollisionShape2D nodes, which represent all strokes on a canvas, to its parent.
##

## Canvas which strokes will be used to generate a collision shape from.
@export
var canvas: AnnotateCanvas:
    set(new_canvas):

        if canvas != null:
            canvas.canvas_changed.disconnect(_update_collision)

        if new_canvas != null:
            new_canvas.canvas_changed.connect(_update_collision)

        canvas = new_canvas
        _update_collision(canvas)


var _collision_shapes: Array[CollisionShape2D] = []

func _ready():
    _update_collision(canvas)

    tree_exiting.connect(_free_shapes)
    tree_entered.connect(func(): _update_collision(canvas))

# populate the current parent node with CollisionShape2D nodes, which represent strokes of the assigned canvas.
func _update_collision(canvas):
    _free_shapes()

    for stroke: GDA_Stroke in canvas.get_stroke_nodes():
        var collision_area: Area2D = stroke.get_collision_area()

        # all children of the collision_area should be of type CollisionShape2D.

        for child: CollisionShape2D in collision_area.get_children():
            var duplicate_shape: CollisionShape2D = child.duplicate()

            var add_shape = func():
                get_parent().add_child(duplicate_shape)
                duplicate_shape.global_transform = child.global_transform
            
            add_shape.call_deferred()
            _collision_shapes.append(duplicate_shape)

# free all CollisionShape2D nodes currently managed by this node.
func _free_shapes():
    for shape: CollisionShape2D in _collision_shapes:
        shape.queue_free()

    _collision_shapes.clear()
