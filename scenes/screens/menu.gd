class_name Menu
extends CanvasLayer

@onready var viewport_size: Vector2 = get_viewport().get_visible_rect().size

func _process(delta: float) -> void:
    var p: Vector2 = get_viewport().get_mouse_position().clamp(Vector2.ZERO, viewport_size) / viewport_size
    offset = offset.lerp(-(p * 2.0 - Vector2.ONE), delta * 2.0)