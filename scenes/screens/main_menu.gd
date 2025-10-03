extends CanvasLayer

@export var play_button:     Button
@export var settings_button: Button
@export var credits_button:  Button
@export var exit_button:     Button

func _ready() -> void:
	if play_button != null: play_button.pressed.connect(
		func() -> void:
			SceneManager.change_scene(
				"res://scenes/screens/game.tscn", 
				SceneTransition.of(0.8, SceneTransition.Type.LEFT_TO_RIGHT, Tween.TRANS_SINE, Tween.EASE_IN_OUT),
				SceneTransition.of(0.3, SceneTransition.Type.FADE, Tween.TRANS_QUAD, Tween.EASE_IN_OUT),
				0.5
			)
	)

	if settings_button != null: settings_button.pressed.connect(
		func() -> void:
			pass
	)

	if credits_button != null: credits_button.pressed.connect(
		func() -> void:
			pass
	)

	if exit_button != null: exit_button.pressed.connect(
		func() -> void:
			SceneManager.change_scene("res://scenes/exit.tscn", SceneTransition.of(1.5, SceneTransition.FADE, Tween.TRANS_QUAD, Tween.EASE_IN))
	)
