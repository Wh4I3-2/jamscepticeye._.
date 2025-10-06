extends Menu

@export var back_button:   Button

func _ready() -> void:
	back_button.pressed.connect(
		func() -> void:
			SceneManager.change_scene(
				"res://scenes/screens/main_menu.tscn", 
				SceneTransition.of(0.4 , SceneTransition.Type.RIGHT_TO_LEFT, Tween.TRANS_SINE, Tween.EASE_IN),
				SceneTransition.of(0.4 , SceneTransition.Type.RIGHT_TO_LEFT, Tween.TRANS_SINE, Tween.EASE_OUT),
				0.1
			)
	)
