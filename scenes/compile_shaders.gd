extends Node

func _ready() -> void:
	get_tree().root.add_child.call_deferred(NodeUtils.with_group(
		load("res://scenes/fx/stars.tscn").instantiate(), "fx"
	))
	get_tree().root.add_child.call_deferred(NodeUtils.with_group(
		load("res://scenes/fx/vignette.tscn").instantiate(), "fx"
	))