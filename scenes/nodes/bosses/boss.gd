class_name Boss
extends Node2D

@export var hurtboxes: Array[HurtBox]
@export var targets:   Dictionary[Node2D, bool]

@export var hit_modulater: Node2D

@export var max_health: int

@export var current: bool = true

var health: int

func _ready() -> void:
	for hurtbox in hurtboxes:
		hurtbox.hurt.connect(
			func(hitbox: HitBox) -> void:
				on_hurtbox_hurt(hurtbox, hitbox)
		)

	health = max_health

	if current:
		GameManager.boss = self


func get_target(pos: Vector2) -> Node2D:
	var best: Node2D = null
   
	for target in targets.keys():
		if !targets.get(target): continue

		if best == null: 
			best = target
			continue
		
		if pos.distance_squared_to(target.global_position) < pos.distance_squared_to(best.global_position):
			best = target 
	 
	return best

func on_hurtbox_hurt(_hurtbox: HurtBox, hitbox: HitBox) -> void:
	if hitbox.hitbox_owner is Projectile:
		var projectile := hitbox.hitbox_owner as Projectile
		if projectile.projectile_owner == self: return
	health -= hitbox.damage

	Juice.screen_shake(hitbox.damage * 0.5)
	Juice.freeze_frames(0.05)
	hit_modulater.self_modulate += Color(1000.0, 1000.0, 1000.0)

	await Juice.freeze_timer.timeout
	await get_tree().create_timer(0.05).timeout

	hit_modulater.self_modulate -= Color(1000.0, 1000.0, 1000.0)
