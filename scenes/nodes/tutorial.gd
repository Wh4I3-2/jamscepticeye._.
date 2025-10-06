extends CanvasLayer

@export var prompt_texture: TextureRect
@export var prompt: Control
@export var text: RichTextLabel

@onready var write_timer: Timer = NodeUtils.create_timer(self)
@onready var prompt_timer: Timer = NodeUtils.create_timer(self)
@onready var delay_timer: Timer = NodeUtils.create_timer(self)

func _ready() -> void:
	visibility_changed.connect(on_visibility)
	visible = false

func _process(_delta: float) -> void:
	if !delay_timer.is_stopped(): return

	if write_timer.is_stopped():
		if text.visible_characters < len("TAKE YOUR REVENGE"):
			text.visible_characters += 1
			write_timer.start(0.5 if "TAKE YOUR REVENGE"[text.visible_characters-1] == " " else 0.1)

	if !prompt_timer.is_stopped(): prompt.modulate.a = 1.0 - prompt_timer.time_left / 4.0

func on_visibility() -> void:
	if !visible: return
	text.visible_characters = 0
	prompt.modulate.a = 0.0

	prompt_texture.texture = InputUtils.key_to_prompt(SettingsManager.settings.controls_primary)

	delay_timer.start(1.0)

	await delay_timer.timeout

	write_timer.start(0.1)

	await get_tree().create_timer(3).timeout

	prompt_timer.start(4.0)
