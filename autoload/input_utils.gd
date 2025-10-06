class_name InputUtils

static func key_to_prompt(key: InputEventKey) -> Texture:
	var name: String = key.as_text_physical_keycode().to_snake_case()
	if name in ["left", "right", "up", "down"]: name = "arrow_%s" % name

	return load("res://addons/kenney_input_prompts/Keyboard & Mouse/Default/keyboard_%s_outline.png" % name)