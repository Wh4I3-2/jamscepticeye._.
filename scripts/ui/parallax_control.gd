class_name ParallaxControl
extends Control

@export var strength: float

var base_position: Vector2 
var has_init: bool = false

func _ready() -> void:
	init_control.call_deferred()

func init_control() -> void:
	base_position = position 
	has_init = true

func _process(_delta: float) -> void:
	if !has_init: return
	position = base_position - get_canvas_layer_node().offset * strength