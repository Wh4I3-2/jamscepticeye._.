extends Node

@onready var freeze_timer: Timer = NodeUtils.create_timer(self)

var camera: Camera2D

var screen_shake_strength: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	get_tree().paused = !freeze_timer.is_stopped()

	if get_tree().paused: return

	if camera == null: return

	screen_shake_strength = lerpf(screen_shake_strength, 0.0, delta * 2.0)

	var shake: Vector2 = Vector2(
		randf_range(-screen_shake_strength, screen_shake_strength), 
		randf_range(-screen_shake_strength, screen_shake_strength)
	) * SettingsManager.settings.screen_shake
	camera.offset = camera.offset.lerp(shake, delta * 4.0)

	var shake_rot = randf_range(-screen_shake_strength, screen_shake_strength) * SettingsManager.settings.screen_shake

	camera.rotation_degrees = lerpf(camera.rotation_degrees, shake_rot, delta * 4.0)

func add_screen_shake(amount: float) -> void:
	screen_shake_strength += amount

func freeze_frames(length: float) -> void:
	if freeze_timer.is_stopped():
		freeze_timer.start(length)
		return
	
	freeze_timer.start(freeze_timer.time_left + length)
