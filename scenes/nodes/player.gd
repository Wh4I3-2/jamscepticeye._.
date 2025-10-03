class_name Player
extends CharacterBody2D

@export var hurtbox: HurtBox

@export var speed: float = 80.0
@export var diagonal_strength: float = 0.3
@export var retribution_radius: float = 40.0

@export var retribution_window:   float = 2
@export var retribution_cooldown: float = 2.0

@onready var retribution_window_timer:   Timer = NodeUtils.create_timer(self)
@onready var retribution_cooldown_timer: Timer = NodeUtils.create_timer(self)

func _ready() -> void:
	hurtbox.hurt.connect(on_hurt)

func _physics_process(delta: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if !retribution_window_timer.is_stopped():
		process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().paused = true
		
		camera.zoom = camera.zoom.lerp(Vector2(2, 2), delta * 4)

		if Input.is_action_just_pressed("primary"):
			retribution_window_timer.stop()
		
		return
	
	process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().paused = false
	
	camera.zoom = camera.zoom.lerp(Vector2(1, 1), delta * 8)

	var horizontal: float = Input.get_axis("move_left", "move_right")
	var vertical:   float = Input.get_axis("move_up",   "move_down")
	
	var move_dir: Vector2 = Vector2(horizontal, vertical).normalized().lerp(Vector2(horizontal, vertical), diagonal_strength)
	
	velocity = move_dir * speed
	
	move_and_slide()

func on_hurt(hitbox: HitBox) -> void:
	if hitbox.hitbox_owner is Projectile:
		var projectile: Projectile = hitbox.hitbox_owner
		if projectile.is_lethal: return

	retribution_window_timer.start(retribution_window)
	
	print("hurt")
	
