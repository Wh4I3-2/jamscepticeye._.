extends SubViewportContainer

@export var sub_viewport: SubViewport

var base_stretch_shrink: int = 1
var set_from_update: bool = false

func _input(event: InputEvent) -> void:
	sub_viewport.push_input(event)

func _set(property: StringName, value: Variant) -> bool:
	if property == &"stretch_shrink":
		base_stretch_shrink = int(value)
		if !set_from_update:
			stretch_shrink = int(value)
			update()
		return true
	
	return false

func _ready() -> void:
	get_tree().root.size_changed.connect(update)
	SettingsManager.settings.changed.connect(update)

	update.call_deferred()

func update() -> void:
	var window_size: Vector2 = get_tree().root.size
	var target_size: Vector2 = get_tree().root.content_scale_size

	var ratio: float = window_size.y / target_size.y
	
	set_from_update = true
	stretch_shrink = max(roundi(6.0 * float(base_stretch_shrink) * ratio), 1)
	
	set_deferred("set_from_update", false)

	if material is ShaderMaterial:
		material.set_shader_parameter("texture_scale", stretch_shrink)
