extends Node


func _ready() -> void:
	get_tree().root.add_child.call_deferred(load("res://scenes/fx/stars.tscn").instantiate())
	get_tree().root.add_child.call_deferred(load("res://scenes/fx/vignette.tscn").instantiate())

	SceneManager.change_scene(
		"res://scenes/screens/main_menu.tscn",
		SceneTransition.of(0.5, SceneTransition.Type.FADE, Tween.TRANS_SINE, Tween.EASE_IN_OUT),
		SceneTransition.of(0.5, SceneTransition.Type.FADE, Tween.TRANS_SINE, Tween.EASE_IN_OUT),
		0.1
	)
