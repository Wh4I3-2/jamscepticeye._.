extends Menu

@export var play_button:     Button
@export var settings_button: Button
@export var controls_button: Button
@export var credits_button:  Button
@export var exit_button:     Button

func _ready() -> void:
	if play_button != null: play_button.pressed.connect(
		func() -> void:
			SceneManager.change_scene(SceneChange.of(
				"res://scenes/screens/game.tscn", 
				SceneTransition.of(0.8, SceneTransition.Type.LEFT_TO_RIGHT, Tween.TRANS_SINE, Tween.EASE_IN_OUT),
				SceneTransition.of(0.3, SceneTransition.Type.FADE, Tween.TRANS_QUAD, Tween.EASE_IN_OUT),
				0.5
			))
	)

	if settings_button != null: settings_button.pressed.connect(
		func() -> void:
			SceneManager.change_scene(SceneChange.of(
				"res://scenes/screens/settings_menu.tscn", 
				SceneTransition.of(0.4 , SceneTransition.Type.LEFT_TO_RIGHT, Tween.TRANS_SINE, Tween.EASE_IN),
				SceneTransition.of(0.4 , SceneTransition.Type.LEFT_TO_RIGHT, Tween.TRANS_SINE, Tween.EASE_OUT),
				0.1
			))
	)

	if controls_button != null: controls_button.pressed.connect(
		func() -> void:
			SceneManager.change_scene(SceneChange.of(
				"res://scenes/screens/controls_menu.tscn", 
				SceneTransition.of(0.4 , SceneTransition.Type.LEFT_TO_RIGHT, Tween.TRANS_SINE, Tween.EASE_IN),
				SceneTransition.of(0.4 , SceneTransition.Type.LEFT_TO_RIGHT, Tween.TRANS_SINE, Tween.EASE_OUT),
				0.1
			))
	)

	if credits_button != null: credits_button.pressed.connect(
		func() -> void:
			SceneManager.change_scene(SceneChange.of(
				"res://scenes/screens/credits_menu.tscn", 
				SceneTransition.of(0.4 , SceneTransition.Type.LEFT_TO_RIGHT, Tween.TRANS_SINE, Tween.EASE_IN),
				SceneTransition.of(0.4 , SceneTransition.Type.LEFT_TO_RIGHT, Tween.TRANS_SINE, Tween.EASE_OUT),
				0.1
			))
	)

	if exit_button != null: exit_button.pressed.connect(
		func() -> void:
			SceneManager.change_scene(SceneChange.of(
				"res://scenes/exit.tscn", SceneTransition.of(1.5, SceneTransition.FADE, Tween.TRANS_QUAD, Tween.EASE_IN)
			))
	)
