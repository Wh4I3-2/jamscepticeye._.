class_name ProjectileAdopter
extends Area2D

signal adopted(projectile: Projectile)

@export var projectile_owner: Node
@export var new_scene: PackedScene

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: CollisionObject2D) -> void:
	if not body is Projectile: return
	var projectile := body as Projectile

	if new_scene == null:
		adopt(projectile)
		return
	
	if !new_scene.can_instantiate():
		adopt(projectile)
		return

	var new: Node = new_scene.instantiate()
	if not new is Projectile:
		new.queue_free()
		adopt(projectile)
		return
	
	var new_projectile := new as Projectile
	new_projectile.direction = projectile.direction
	new_projectile.global_position = projectile.global_position

	projectile.get_parent().add_child.call_deferred(new_projectile)
	projectile.destroy()

	adopted.emit(new_projectile)

func adopt(projectile: Projectile) -> void:
	projectile.projectile_owner = projectile_owner	
	adopted.emit(projectile)