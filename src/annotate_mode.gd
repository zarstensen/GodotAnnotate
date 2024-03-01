extends Resource

const Stroke := preload("res://addons/GodotAnnotate/src/stroke.gd")

func get_icon_path() -> String:
	return ""

func get_mode_name() -> String:
	return ""

func draw_cursor(canvas: CanvasItem, pos: Vector2, brush_size: float, brush_color: Color) -> void:
	pass

func on_begin_stroke(pos: Vector2, size: float, color: Color, canvas: AnnotateCanvas) -> Node2D:
	return Node2D.new()

func on_end_stroke(pos: Vector2, stroke: Node2D, canvas: AnnotateCanvas) -> void:
	pass

func on_annotate_process(delta: float, stroke: Node2D, canvas: AnnotateCanvas) -> void:
	pass

func on_annotate_input(event: InputEvent) -> bool:
	return false

func should_begin_stroke(event: InputEvent) -> bool:
	return false

func should_end_stroke(event: InputEvent) -> bool:
	return false
