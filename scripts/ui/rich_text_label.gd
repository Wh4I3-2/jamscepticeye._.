extends RichTextLabel

@export var underline_meta_on_hover: bool = true

func _ready() -> void:
	if OS.get_name() != "HTML5":
		meta_clicked.connect(
			func(meta: String) -> void:
				OS.shell_open(meta)
		)
	
	mouse_entered.connect(
		func():
			if underline_meta_on_hover: meta_underlined = true
	)
	
	mouse_exited.connect(
		func():
			if underline_meta_on_hover: meta_underlined = false
	)
	
