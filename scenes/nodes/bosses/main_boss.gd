extends Boss

enum Attack {
	DASH_A,
	DASH_B,
	SPIN,
}

@export var body_animation: AnimatedSprite2D
@export var body_copy: Node2D

@export var projectile_scene:        PackedScene
@export var lethal_projectile_scene: PackedScene

@export var body: Node2D

@onready var attack_timer: Timer = NodeUtils.create_timer(self)
@onready var misc_timer:   Timer = NodeUtils.create_timer(self)

var ATTACK_CALLABLES: Dictionary[Attack, Callable] = {
	Attack.SPIN:   spin_attack,
	Attack.DASH_A: dash_a,
	Attack.DASH_B: dash_b,
}
const BASE_ATTACK_POOL: Array[Attack] = [
	Attack.DASH_B,
	Attack.DASH_B,
]
const PHASE_TWO_ATTACK_POOL: Array[Attack] = [
	Attack.DASH_B,
	Attack.DASH_A,
	Attack.SPIN
]

var rot: float

var attack_pool: Array[Attack]
var current_attack: Attack
var just_entered_attack: bool

func _process(_delta: float) -> void:
	body_copy.position = body.position 

func _physics_process(delta: float) -> void:
	if !GameManager.player.retribution_window_timer.is_stopped(): return
	
	just_entered_attack = false
	if attack_timer.is_stopped():
		pick_attack()
		just_entered_attack = true

	if current_attack in ATTACK_CALLABLES.keys(): ATTACK_CALLABLES.get(current_attack).call(delta)

func flip_sprite() -> void:
	body_animation.flip_v = body.global_position.x > GameManager.player.global_position.x
	pass


func pick_attack() -> void:
	if len(attack_pool) <= 0:
		if health < max_health / 2.0: attack_pool = PHASE_TWO_ATTACK_POOL.duplicate()
		else:                         attack_pool = BASE_ATTACK_POOL.duplicate()
	
	attack_pool.shuffle()

	current_attack = attack_pool.back()
	attack_pool.pop_back()


enum DashState {
	REPOSITION,
	WINDUP,
	DASH,
}

@export_category("Dash")
@export var dash_projectile_scene: PackedScene
@export var dash_lethal_projectile_scene: PackedScene
@export var dash_curve_reposition: Curve
@export var dash_curve_windup:     Curve
@export var dash_curve_dash:       Curve
var dash_curve:       Curve
var dash_state:       DashState
var dash_target:      Vector2
var dash_start:       Vector2
var dashes:           int
var dash_time:        float
var dash_projectiles: int
func dash_a(delta: float, is_b: bool = false) -> void:
	if just_entered_attack:
		dash_state = DashState.DASH
		dashes = 2 + 1
		dash_projectiles = 0
	
	if dashes >= 0:
		attack_timer.start(1.0)

	if misc_timer.is_stopped():
		dash_start = body.position
		match dash_state:
			DashState.REPOSITION: 
				dash_state = DashState.WINDUP
				dash_time = 0.5
				if dashes == 2: dash_target = Vector2(-154.0,  52.0)
				if dashes == 1: dash_target = Vector2( 154.0, -52.0)
				if dashes == 0: dashes -= 1
				dash_curve = dash_curve_windup
			DashState.WINDUP: 
				dash_state = DashState.DASH
				dash_time = 1.0
				if dashes == 2: dash_target = Vector2( 200.0,  52.0)
				if dashes == 1: dash_target = Vector2(-200.0, -52.0)
				if dashes == 0: dash_target = Vector2(-144.0,   0.0)
				dash_curve = dash_curve_dash
				dash_projectiles = 0
			DashState.DASH: 
				dashes -= 1
				dash_state = DashState.REPOSITION
				dash_time = 1.5
				if dashes == 2: dash_target = Vector2(-144.0,  52.0)
				if dashes == 1: dash_target = Vector2( 144.0, -52.0)
				if dashes == 0: dash_target = Vector2(-144.0,   0.0)
				if body.position.x <= -200 or body.position.x >= 200.0:
					dash_start.y = dash_target.y
				dash_curve = dash_curve_reposition
		
		if is_b: dash_target = -dash_target
		misc_timer.start(dash_time)


	var t:  float = 1.0 - misc_timer.time_left / dash_time
	var ct: float = dash_curve.sample(t)
	body.position = dash_start.lerp(dash_target, ct)
	
	var target_rot: float

	match dash_state:
		DashState.REPOSITION:
			target_rot = body.global_position.angle_to_point(GameManager.player.global_position)
			flip_sprite()
		DashState.WINDUP:
			target_rot = body.position.angle_to_point(dash_target * Vector2(-1.0, 1.0))
			flip_sprite()
		DashState.DASH:
			target_rot = body.position.angle_to_point(dash_target)
			var pt: float = ct * 1.6 - 0.2
			for i in range(10):
				if i + 1 <= dash_projectiles: continue
				if pt > float(i) / 10.0:
					var scene: PackedScene = dash_lethal_projectile_scene if ((i+3) % 5 == 0) else dash_projectile_scene
					var projectile: Projectile = scene.instantiate()
					projectile.direction = body.global_position.direction_to(GameManager.player.global_position)
					projectile.global_position = body.global_position
					projectile.projectile_owner = self
					dash_projectiles += 1
					SceneManager.current.add_child(projectile)


	rot = lerp_angle(rot, target_rot, delta * 4.0)
	body_animation.global_rotation_degrees = roundf(rad_to_deg(rot) / 2.0) * 2.0

func dash_b(delta: float) -> void:
	dash_a(delta, true)

var spin_times: int
var spin_angle: float 
var spin_time: float
func spin_attack(delta: float) -> void:
	if just_entered_attack:
		spin_times = 10

	spin_time += delta

	var target_pos: Vector2 = Vector2.from_angle(deg_to_rad(spin_time * 180.0)) * -150.0
	var target_rot: float = body.position.angle_to_point(target_pos)

	var speed: float = 10.0

	if spin_times < 0:
		speed = 5.0
		target_pos = Vector2(-134.0, 0.0)
		target_rot = body.global_position.angle_to_point(GameManager.player.global_position)

	body.position = body.position.lerp(target_pos, delta * speed)

	rot = target_rot
	body_animation.global_rotation_degrees = roundf(rad_to_deg(rot) / 2.0) * 2.0

	if spin_times < 0:
		return
	
	attack_timer.start(4.0)

	if !misc_timer.is_stopped():
		return
	
	var p: int = 6
	if spin_times == 0: p = 15

	for i in range(p):
		for j in range(2):
			var a: float = spin_angle + j * 180

			var scene: PackedScene = lethal_projectile_scene
			if spin_times == 0:
				scene = projectile_scene

			var projectile: Projectile = scene.instantiate()
			projectile.direction = Vector2.from_angle(deg_to_rad(a))
			projectile.global_position = projectile.direction * -160
			projectile.projectile_owner = GameManager.boss

			SceneManager.current.add_child(projectile)

			if spin_times == 0: 
				if i % 3 == 0:
					var lethal_projectile: Projectile = lethal_projectile_scene.instantiate()
					lethal_projectile.direction = Vector2.from_angle(deg_to_rad(a))
					lethal_projectile.global_position = projectile.direction * -180
					lethal_projectile.projectile_owner = GameManager.boss

					SceneManager.current.add_child(lethal_projectile)
				continue

			var when_zero: Signal = NodeUtils.property_equals(projectile, "global_position", Vector2.ZERO)

			var when_zero_func: Callable = (func() -> void:
				var lethal_projectile: Projectile = lethal_projectile_scene.instantiate()
				lethal_projectile.direction = Vector2.from_angle(deg_to_rad(a+36))
				lethal_projectile.global_position = projectile.global_position
				lethal_projectile.projectile_owner = projectile.projectile_owner

				SceneManager.current.add_child(lethal_projectile)

				projectile.queue_free()
			) if i == 0 else (func() -> void:
				projectile.destroy()
			)
			
			when_zero.connect(when_zero_func)
			projectile.destroyed.connect(
				func() -> void:
					if when_zero_func == null: return
					if when_zero == null: return
					if self == null: return
					if when_zero.get_object() == null: return
					if when_zero.is_connected(when_zero_func): when_zero.disconnect(when_zero_func)
			)

		spin_angle += 12
	
	misc_timer.start(1)
	spin_times -= 1
