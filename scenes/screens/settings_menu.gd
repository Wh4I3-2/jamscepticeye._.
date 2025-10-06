extends Menu

@export var back_button:   Button
@export var master_volume: HSlider
@export var music_volume:  HSlider
@export var sfx_volume:    HSlider
@export var fullscreen:    CheckButton
@export var screen_shake:  HSlider

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

	init_settings()

	master_volume.value_changed.connect(
		func(v: float) -> void: SettingsManager.settings.master_vol = v
	)
	music_volume.value_changed.connect(
		func(v: float) -> void: SettingsManager.settings.music_vol = v
	)
	sfx_volume.value_changed.connect(
		func(v: float) -> void: SettingsManager.settings.sfx_vol = v
	)

	fullscreen.toggled.connect(
		func(toggled_on: bool) -> void: SettingsManager.settings.fullscreen = toggled_on
	)

	screen_shake.value_changed.connect(
		func(v: float) -> void: SettingsManager.settings.screen_shake = v
	)

func init_settings() -> void:
	master_volume.value       = SettingsManager.settings.master_vol
	music_volume.value        = SettingsManager.settings.music_vol
	sfx_volume.value          = SettingsManager.settings.sfx_vol
	fullscreen.button_pressed = SettingsManager.settings.fullscreen
	screen_shake.value        = SettingsManager.settings.screen_shake
