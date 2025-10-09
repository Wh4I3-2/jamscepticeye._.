extends Node

@export var flash_material: ShaderMaterial

@onready var freeze_timer: Timer = NodeUtils.create_timer(self, true)
@onready var flash_timer:  Timer = NodeUtils.create_timer(self, true)

var camera: Camera2D

var screen_shake_strength: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	get_tree().paused = !freeze_timer.is_stopped()
	Engine.time_scale = 1.0 if freeze_timer.is_stopped() else 0.0

	var flash_time: float = clampf(flash_timer.time_left, 0.0, 1.0)
	flash_material.set_shader_parameter("pixelate_weight", flash_time)
	flash_material.set_shader_parameter("invert_weight", flash_time)

	if get_tree().paused: return

	if camera == null: return

	screen_shake_strength = lerpf(screen_shake_strength, 0.0, delta * 2.0)

	var shake: Vector2 = Vector2(
		randf_range(-screen_shake_strength, screen_shake_strength), 
		randf_range(-screen_shake_strength, screen_shake_strength)
	) * SettingsManager.settings.screen_shake
	camera.offset = camera.offset.lerp(shake, delta * 4.0)

	var shake_rot = randf_range(-screen_shake_strength, screen_shake_strength) * SettingsManager.settings.screen_shake * 2.0

	camera.rotation_degrees = lerpf(camera.rotation_degrees, shake_rot, delta * 4.0)

func add_screen_shake(amount: float) -> void:
	screen_shake_strength += amount

func unique_signal_name(desired_name: String = "unnamed") -> String:
	var best_name = desired_name
	var i: int = 0
	
	while has_signal(best_name):
		best_name = "%s_%d" % [desired_name, i]
		
	return best_name

func freeze_frames(length: float, replace: bool = false, wait_for_all: bool = false) -> Signal:
	var signal_name: String = unique_signal_name("freeze_frames")
	add_user_signal(signal_name)
	
	(func() -> void:
		if freeze_timer.is_stopped() or replace:
			freeze_timer.start(length)
			return
	
		freeze_timer.start(freeze_timer.time_left + length)
	).call()

	connect(signal_name, 
		func() -> void:
			if has_user_signal(signal_name): remove_user_signal(signal_name)
	)

	var on_timeout: Callable = (
		func() -> void:
			if has_signal(signal_name): emit_signal(signal_name)	
	)

	if wait_for_all: freeze_timer.timeout.connect(on_timeout)
	else: get_tree().create_timer(length).timeout.connect(on_timeout)

	return Signal(self, signal_name)

func flash_frames(length: float, replace: bool = false) -> void:
	if flash_timer.is_stopped() or replace:
		flash_timer.start(length)
		return
	
	flash_timer.start(flash_timer.time_left + length)
	
