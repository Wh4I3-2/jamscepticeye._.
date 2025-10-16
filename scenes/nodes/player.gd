class_name Player
extends CharacterBody2D

@export var current: bool = true

@export var tutorial: CanvasLayer
@export var sprite_modulate: Node2D
@export var sprite: Sprite2D
@export var ability_animation: AnimatedSprite2D

@export var blood_particles: CPUParticles2D

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
@export var retribution_penalty:  float = 1.0

@onready var retribution_timer:         Timer = NodeUtils.create_timer(self)
@onready var retribution_window_timer:   Timer = NodeUtils.create_timer(self, true)
@onready var retribution_cooldown_timer: Timer = NodeUtils.create_timer(self)
@onready var blood_timer: Timer = NodeUtils.create_timer(self)

var awaiting_retribution: bool = false
var retributing:          bool = false

var has_tutorial: bool = false
var dead: bool = false

func _ready() -> void:
	hurtbox.hurt.connect(on_hurt)

	blood_particles.emitting = false

	projectile_adopter.adopted.connect(on_projectile_adopted)
	retribution_collision.shape = retribution_collision.shape.duplicate()

	if current:
		GameManager.player = self
	
	process_mode = Node.PROCESS_MODE_ALWAYS

	Juice.zooms.set(self, 0.0)
	
	retribution_cooldown_timer.timeout.connect(
		func() -> void:
			flash_color(Color("#BAEAD0") * 4.0, 0.4, sprite_modulate)
			Juice.freeze_frames(0.1)
	)

func _process(_delta: float) -> void:
	sprite.modulate = (
		lerp(Color.LIGHT_PINK, Color.DARK_RED, retribution_cooldown_timer.time_left / retribution_cooldown) if !retribution_cooldown_timer.is_stopped() 
		else Color.WHITE
	)
	blood_particles.emitting = !blood_timer.is_stopped()

func _physics_process(delta: float) -> void:
	if dead: return
	if !retribution_window_timer.is_stopped():
		if !has_tutorial and tutorial != null:
			retribution_window_timer.start(1.0)
			if !tutorial.visible: tutorial.visible = true

		Juice.zooms.set(self, lerpf(Juice.zooms.get(self), 0.2, delta * 4))

		Juice.invert_frames(1.1, true)
		Juice.screen_shake(10.0, true)
		blood_timer.start(0.3)

		if Input.is_action_just_pressed("primary"):
			retribution_window_timer.stop()
			retribution_timer.start(retribution_time)

			retribution_cooldown_timer.start(retribution_cooldown)

			awaiting_retribution = false
			retributing = true
			has_tutorial = true
			Juice.invert_frames(0.1, true)
			Juice.screen_shake(10.0)

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

	if Input.is_action_just_pressed("primary"):
		if retribution_cooldown_timer.is_stopped():
			retribution_cooldown_timer.start(retribution_penalty)
	
	Juice.zooms.set(self, lerpf(Juice.zooms.get(self), 0.0, delta * 8))

	var horizontal: float = Input.get_axis("left", "right")
	var vertical:   float = Input.get_axis("up",   "down")
	
	var move_dir: Vector2 = Vector2(horizontal, vertical).normalized().lerp(Vector2(horizontal, vertical), diagonal_strength)
	
	velocity = move_dir * speed

	if velocity.x == 0: global_position.x = roundf(global_position.x)
	if velocity.y == 0: global_position.y = roundf(global_position.y)
	
	move_and_slide()


func die() -> void:
	awaiting_retribution = false
	dead = true

	await Juice.death_fx()

	SceneManager.change_scene(SceneChange.of(
		"res://scenes/screens/death_menu.tscn", 
		SceneTransition.of(0.2, SceneTransition.Type.FADE, Tween.TRANS_QUAD, Tween.EASE_IN_OUT),
		SceneTransition.of(1.0, SceneTransition.Type.FADE, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT),
		0.6
	))


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

	blood_particles.global_rotation = global_position.angle_to_point(hitbox.global_position)
	blood_timer.start(0.3)

	
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

func flash_color(color: Color, time: float, target: CanvasItem = self) -> void:
	var init_color: Color = target.modulate
	target.modulate = color

	await get_tree().create_timer(time).timeout

	if target.modulate == color:
		target.modulate = init_color
