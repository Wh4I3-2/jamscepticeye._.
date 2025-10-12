extends Node

@export var targets: Array[Control]

func _ready() -> void:
	for target in targets:
		process_mode = Node.PROCESS_MODE_ALWAYS
	
		target.focus_entered.connect(on_focus_entered)
		target.focus_exited.connect(on_focus_exited)

func on_focus_entered() -> void:
	Juice.set_deferred("paused", true)

func on_focus_exited() -> void:
	Juice.paused = false
