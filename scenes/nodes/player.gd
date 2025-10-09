class_name Player
extends CharacterBody2D

@export var current: bool = true

@export var tutorial: CanvasLayer
@export var ability_animation: AnimatedSprite2D

@export var hurtbox: HurtBox
@export var projectile_adopter: ProjectileAdopter
@export var retribution_collision: CollisionShape2D 

@export var speed: float = 80.0
@export var diagonal_strength: float = 0.3
@export var retribution_radius: float = 40.0

@export var retribution_time:     float = 0.2
@export var retribution_hold:     float = 0.1
@export var retribution_window:   float = 2
@export var retribution_cooldown: float = 2.0

@onready var retribution_timer:         Timer = NodeUtils.create_timer(self)
@onready var retribution_window_timer:   Timer = NodeUtils.create_timer(self)
@onready var retribution_cooldown_timer: Timer = NodeUtils.create_timer(self)

var awaiting_retribution: bool = false
var retributing:          bool = false

var has_tutorial: bool = false

func _ready() -> void:
	hurtbox.hurt.connect(on_hurt)

	projectile_adopter.adopted.connect(on_projectile_adopted)
	retribution_collision.shape = retribution_collision.shape.duplicate()

	if current:
		GameManager.player = self

func _process(_delta: float) -> void:
	modulate = lerp(Color.WHITE, Color.DARK_GRAY, retribution_cooldown_timer.time_left / retribution_cooldown)

func _physics_process(delta: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if !retribution_window_timer.is_stopped():
		if !has_tutorial and tutorial != null:
			retribution_window_timer.start(1.0)
			if !tutorial.visible: tutorial.visible = true

		camera.zoom = camera.zoom.lerp(Vector2(1.2, 1.2), delta * 4)

		if Input.is_action_just_pressed("primary"):
			retribution_window_timer.stop()
			retribution_timer.start(retribution_time)

			retribution_cooldown_timer.start(retribution_cooldown)

			awaiting_retribution = false
			retributing = true
			has_tutorial = true

			Juice.freeze_frames(0.2)
			Juice.add_screen_shake(20.0)

			if tutorial != null: tutorial.queue_free()

		return
	
	if retribution_window_timer.is_stopped() and awaiting_retribution:
		die()
		return
	
	if retributing:
		var weight: float = 1.0 - retribution_timer.time_left / retribution_time

		if retribution_collision.shape is CircleShape2D: 
			retribution_collision.shape.radius = lerpf(1.0, retribution_radius, weight)

		ability_animation.animation = &"Main"
		ability_animation.frame = int(ability_animation.sprite_frames.get_frame_count(&"Main") * weight) - 1

		projectile_adopter.monitoring = true

		if retribution_timer.is_stopped():
			retributing = false
			
			await get_tree().create_timer(retribution_hold).timeout
			if retribution_collision.shape is CircleShape2D:
				ability_animation.play("None")
				retribution_collision.shape.radius = 1
			
			return
		return
	
	projectile_adopter.monitoring = false
	
	camera.zoom = camera.zoom.lerp(Vector2(1, 1), delta * 8)

	var horizontal: float = Input.get_axis("left", "right")
	var vertical:   float = Input.get_axis("up",   "down")
	
	var move_dir: Vector2 = Vector2(horizontal, vertical).normalized().lerp(Vector2(horizontal, vertical), diagonal_strength)
	
	velocity = move_dir * speed

	if velocity.x == 0: global_position.x = roundf(global_position.x)
	if velocity.y == 0: global_position.y = roundf(global_position.y)
	
	move_and_slide()


func die() -> void:
	awaiting_retribution = false

	Juice.add_screen_shake(20.0)
	Juice.flash_frames(1.2)
	await Juice.freeze_frames(0.8)

	SceneManager.change_scene(
		"res://scenes/screens/death_menu.tscn", 
		SceneTransition.of(0.2, SceneTransition.Type.FADE, Tween.TRANS_QUAD, Tween.EASE_IN_OUT),
		SceneTransition.of(1.0, SceneTransition.Type.FADE, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT),
		0.6
	)


enum HurtResult {
	IGNORED,
	CAN_RETRIBUTE,
	DIED,
}

func on_hurt(hitbox: HitBox) -> void:
	if retributing: return
	var result: HurtResult = (
		func() -> HurtResult:
			if hitbox.hitbox_owner is Projectile:
				var projectile := hitbox.hitbox_owner as Projectile
				if projectile.projectile_owner == self: return HurtResult.IGNORED

				awaiting_retribution = true

				if projectile.is_lethal: return HurtResult.DIED

				if !retribution_cooldown_timer.is_stopped():
					return HurtResult.DIED
				
				return HurtResult.CAN_RETRIBUTE
			
			return HurtResult.DIED
	).call()
	
	match result:
		HurtResult.CAN_RETRIBUTE:
			retribution_window_timer.start(retribution_window)
		HurtResult.DIED:
			die()



func on_projectile_adopted(projectile: Projectile) -> void:
	if GameManager.boss == null: return
	var target: Node2D = GameManager.boss.get_target(projectile.global_position)
	if target == null: return
	projectile.direction = projectile.global_position.direction_to(target.global_position)
	projectile.destroyed.emit()
