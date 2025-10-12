extends PanelContainer

func _ready() -> void:
	apply.call_deferred()

func apply() -> void:
	set_anchors_preset(PRESET_FULL_RECT, true)