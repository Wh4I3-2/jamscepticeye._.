extends CanvasLayer

@export var play_button:     Button
@export var settings_button: Button
@export var credits_button:  Button
@export var exit_button:     Button

func _ready() -> void:
	if play_button != null: play_button.pressed.connect(
		func() -> void:
			pass
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
