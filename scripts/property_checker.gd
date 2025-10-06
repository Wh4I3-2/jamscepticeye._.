class_name PropertyChecker
extends Node

signal property_equals

var node: Node
var property: NodePath
var value: Variant

func _ready() -> void:
    if node == null or property == null: 
        queue_free()
        return

func _physics_process(_delta: float) -> void:
    var property_value = node.get_indexed(property)

    if property_value == value: 
        property_equals.emit()
        queue_free()