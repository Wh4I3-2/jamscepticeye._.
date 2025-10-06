extends Menu

@export var title_template: String = "%s"
@export var possible_titles: Array[String]

@export var title: RichTextLabel
@export var retry_button: Button
@export var menu_button:  Button

func _ready() -> void:
	title.text = title_template % possible_titles.pick_random()

	retry_button.pressed.connect(
		func() -> void:
			SceneManager.change_scene(
				"res://scenes/screens/game.tscn", 
				SceneTransition.of(0.8, SceneTransition.Type.FADE, Tween.TRANS_SINE, Tween.EASE_IN_OUT),
				SceneTransition.of(0.3, SceneTransition.Type.FADE, Tween.TRANS_QUAD, Tween.EASE_IN_OUT),
				0.5
			)
	)
	menu_button.pressed.connect(
		func() -> void:
			SceneManager.change_scene(
				"res://scenes/screens/main_menu.tscn", 
				SceneTransition.of(0.8, SceneTransition.Type.TOP_TO_BOTTOM, Tween.TRANS_SINE, Tween.EASE_IN_OUT),
				SceneTransition.of(0.3, SceneTransition.Type.FADE, Tween.TRANS_QUAD, Tween.EASE_IN_OUT),
				0.5
			)
	)
