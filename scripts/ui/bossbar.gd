extends Slider

@export var shader_material: ShaderMaterial
@export var speed: float = 4.0

func _process(delta: float) -> void:
	if GameManager.boss == null: 
		value = min_value
		return
	
	max_value = GameManager.boss.max_health
	min_value = 0

	value = lerpf(value, float(GameManager.boss.health), delta * max_value)

	if shader_material != null:
		shader_material.set_shader_parameter("v", value / max_value)