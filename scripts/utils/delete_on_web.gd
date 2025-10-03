extends Node

@export var node: Node

func _ready() -> void:
	if OS.get_name() == "Web": 
		if node == null: queue_free()
		else: node.queue_free()