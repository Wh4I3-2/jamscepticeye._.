class_name SimpleProjectile
extends Projectile

var sub_position: Vector2

var _speed: float

func _ready() -> void:
	hitbox.hit.connect(on_hit)
	_speed = speed

func _physics_process(_delta: float) -> void:
	if !GameManager.player.retribution_window_timer.is_stopped(): return
	
	velocity = direction * _speed

	if global_position.x > 350 or global_position.x < -350: 
		destroy()
	
	if global_position.y > 350 or global_position.y < -350: 
		destroy()
	
	global_position = global_position + sub_position

	move_and_slide()

	var rounded: Vector2 = global_position.round()
	sub_position = global_position - rounded
	global_position = rounded


func on_hit(hurtbox: HurtBox) -> void:
	if hurtbox.hurtbox_owner == projectile_owner: return
	destroy()
	