extends Node

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()