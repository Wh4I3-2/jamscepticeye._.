class_name InputPrompt
extends Button

@export var label: String
@export var action: StringName
@export var dialog: InputDialog 

@onready var label_node: Label = %Label
@onready var texture_rect: TextureRect = %TextureRect

var key: InputEventKey

var waiting: bool = false

func _ready() -> void:
	pressed.connect(on_pressed)

	label_node.text = label

	init_prompt()
	update()

func on_pressed() -> void:
	if waiting: return
	waiting = true
	key = await dialog.prompt_for_input(key, label, self)
	waiting = false
	update()

func init_prompt() -> void:
	key = SettingsManager.settings.get(SettingsManager.ACTIONS_PROPERTY_MAP.get(action))

func update() -> void:
	SettingsManager.settings.set(SettingsManager.ACTIONS_PROPERTY_MAP.get(action), key)

	if key == null: return
	texture_rect.texture = InputUtils.key_to_prompt(key)
