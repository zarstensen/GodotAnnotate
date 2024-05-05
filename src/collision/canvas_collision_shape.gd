@tool
class_name CanvasCollisionShape
extends Node

@export
var canvas: AnnotateCanvas:
    set(new_canvas):

        if canvas != null:
            canvas.canvas_changed.disconnect(_update_collision)

        if new_canvas != null:
            new_canvas.canvas_changed.connect(_update_collision)

        canvas = new_canvas
        _update_collision()


var _collision_shapes: Array[CollisionShape2D] = []


func _ready():
    _update_collision()

    tree_exiting.connect(_free_shapes)
    tree_entered.connect(_update_collision)


func _update_collision(s = null):
    _free_shapes()

    for stroke: GDA_Stroke in canvas.get_stroke_nodes():
        var collision_area: Area2D = stroke.get_collision_area()

        for child: CollisionShape2D in collision_area.get_children():
            var duplicate_shape :CollisionShape2D = child.duplicate()
            duplicate_shape.global_transform = child.global_transform
            get_parent().add_child(duplicate_shape)
            _collision_shapes.append(duplicate_shape)

func _free_shapes():
    for shape: CollisionShape2D in _collision_shapes:
        shape.queue_free()

    _collision_shapes.clear()
