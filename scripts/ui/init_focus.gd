extends Node

@export var focus_target: Control

func _ready() -> void:
	focus_target.grab_focus()
	queue_free()