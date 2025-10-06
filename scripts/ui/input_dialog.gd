class_name InputDialog
extends CanvasLayer

signal found_key(key: InputEventKey)

@export var layer_to_hide: CanvasLayer 

@export var action_label: Label
@export var texture_rect: TextureRect
@export var focus_holder: Control

var _finished_focus: Control

func _input(event: InputEvent) -> void:
	if !visible: return
	if event.is_pressed(): return
	if event is InputEventKey:
		found_key.emit(event)

func _ready() -> void:
	visible = false

	found_key.connect(on_found_key)

func prompt_for_input(event: InputEventKey, label: String, finished_focus: Control) -> Signal:
	visible = true
	layer_to_hide.visible = false

	action_label.text = label
	texture_rect.texture = InputUtils.key_to_prompt(event)

	focus_holder.grab_focus()

	_finished_focus = finished_focus

	return found_key

func on_found_key(_key: InputEventKey) -> void:
	visible = false
	layer_to_hide.visible = true
	_finished_focus.grab_focus()
