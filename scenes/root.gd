extends Node2D

@export var adoptive_parent: Node

func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)

func _on_child_entered_tree(child: Node) -> void:
	if child is CanvasLayer: return
	child.reparent(adoptive_parent)