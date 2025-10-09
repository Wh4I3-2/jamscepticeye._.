extends Node

@export var fx_shader: ShaderMaterial

@onready var freeze_timer: Timer = NodeUtils.create_timer(self, true)
@onready var invert_timer:  Timer = NodeUtils.create_timer(self, true)
@onready var pixelate_timer:  Timer = NodeUtils.create_timer(self, true)

var camera: Camera2D

var screen_shake_strength: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	get_tree().paused = !freeze_timer.is_stopped()
	Engine.time_scale = 1.0 if freeze_timer.is_stopped() else 0.0

	fx_shader.set_shader_parameter("pixelate_weight", pixelate_timer.time_left)
	fx_shader.set_shader_parameter("invert_weight", invert_timer.time_left)

	if get_tree().paused: 
		if camera != null: camera.global_rotation_degrees = move_toward(camera.global_rotation_degrees, 0.0, delta * 20.0)
		return

	if camera == null: return

	screen_shake_strength = lerpf(screen_shake_strength, 0.0, delta * 2.0)

	var shake: Vector2 = Vector2(
		randf_range(-screen_shake_strength, screen_shake_strength), 
		randf_range(-screen_shake_strength, screen_shake_strength)
	) * SettingsManager.settings.screen_shake
	camera.offset = camera.offset.lerp(shake, delta * 4.0)

	var shake_rot = randf_range(-screen_shake_strength, screen_shake_strength) * SettingsManager.settings.screen_shake * 0.25

	camera.global_rotation_degrees = move_toward(camera.global_rotation_degrees, shake_rot, delta * (screen_shake_strength * 2.0 + 1.0))

func screen_shake(amount: float, replace: bool = false) -> void:
	if replace:
		screen_shake_strength = amount
		return
	screen_shake_strength += amount

func freeze_frames(length: float, replace: bool = false, wait_for_all: bool = false) -> Signal:
	var node: Node = Node.new()
	node.add_user_signal("freeze_frames")

	add_child(node)

	(func() -> void:
		if freeze_timer.is_stopped() or replace:
			freeze_timer.start(length)
			return
	
		freeze_timer.start(freeze_timer.time_left + length)
	).call()

	node.connect("freeze_frames", 
		func() -> void: node.queue_free()
	)

	var on_timeout: Callable = (
		func() -> void:
			if node == null: return
			if !node.has_user_signal("freeze_frames"): return
			node.emit_signal("freeze_frames")
	)

	if wait_for_all: freeze_timer.timeout.connect(on_timeout)
	else: get_tree().create_timer(length).timeout.connect(on_timeout)

	return Signal(node, "freeze_frames")

func invert_frames(length: float, replace: bool = false) -> void:
	if invert_timer.is_stopped() or replace:
		invert_timer.start(length)
		return
	
	invert_timer.start(invert_timer.time_left + length)

func pixelate_frames(length: float, replace: bool = false) -> void:
	if pixelate_timer.is_stopped() or replace:
		pixelate_timer.start(length)
		return
	
	pixelate_timer.start(pixelate_timer.time_left + length)
	
func death_fx() -> Signal:
	Juice.screen_shake(20.0)
	Juice.invert_frames(2.0, true)
	Juice.pixelate_frames(1.2, true)
	return Juice.freeze_frames(0.8, true)
