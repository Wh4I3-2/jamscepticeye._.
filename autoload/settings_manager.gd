extends Node

@export var default_settings: Settings
@export var static_settings: StaticSettings

var ACTIONS_PROPERTY_MAP: Dictionary[StringName, StringName] = {
	&"left":       &"controls_left",
	&"right":      &"controls_right",
	&"up":         &"controls_up",
	&"down":       &"controls_down",
	&"ui_left":    &"_controls_left",
	&"ui_right":   &"_controls_right",
	&"ui_up":      &"_controls_up",
	&"ui_down":    &"_controls_down",
	&"primary":    &"controls_primary",
	&"ui_accept":  &"_controls_primary",
	&"pause":      &"controls_pause",
	&"fullscreen": &"controls_fullscreen",
}

var input_defaults: Dictionary[StringName, Array]

var settings: Settings

func _ready() -> void:
	init_settigns()

	settings.changed.connect(func() -> void:
		save()
		update()
	)

	update()

func init_settigns() -> void:
	if ResourceLoader.exists("user://settings.tres"):
		settings = load("user://settings.tres")
		return
	
	settings = default_settings.duplicate()

func save() -> void:
	ResourceSaver.save(settings, "user://settings.tres")

func update() -> void:
	AudioManager.master_volume = settings.master_vol
	AudioManager.music_volume  = settings.music_vol
	AudioManager.sfx_volume    = settings.sfx_vol

	WindowManager.fullscreen = settings.fullscreen

	RenderingServer.global_shader_parameter_set("flashing_fx", !settings.remove_flashing_fx)

	for action in ACTIONS_PROPERTY_MAP.keys():
		update_input_action(action, ACTIONS_PROPERTY_MAP.get(action))


func update_input_action(action: StringName, property: StringName) -> void:
	var include_defaults: bool = false
	if property.begins_with("_"):
		include_defaults = true
		property = StringName(property.trim_prefix("_"))

	if include_defaults and not action in input_defaults.keys():
		if InputMap.has_action(action):
			input_defaults.set(action, InputMap.action_get_events(action))
		else: input_defaults.set(action, [])
	
	var event: InputEventKey = settings.get(property)
	if event == null: return

	if InputMap.has_action(action):
		InputMap.erase_action(action)
	
	InputMap.add_action(action)
	InputMap.action_add_event(action, event)
	if include_defaults:
		for e in input_defaults.get(action):
			InputMap.action_add_event(action, e)