class_name ProjectileAdopter
extends Area2D

signal adopted(projectile: Projectile)

@export var projectile_owner: Node
@export var projectile_scene: PackedScene
@export var lethal_projectile_scene: PackedScene

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: CollisionObject2D) -> void:
	if not body is Projectile: return
	var projectile := body as Projectile

	if projectile.non_adoptable: return

	var scene: PackedScene = projectile_scene
	if projectile.is_lethal:
		scene = lethal_projectile_scene

	if scene == null:
		adopt(projectile)
		return

	if !scene.can_instantiate():
		adopt(projectile)
		return

	var new: Node = scene.instantiate()
	if not new is Projectile:
		new.queue_free()
		adopt(projectile)
		return
	
	var new_projectile := new as Projectile
	new_projectile.direction = projectile.direction
	new_projectile.global_position = projectile.global_position

	projectile.get_parent().add_child.call_deferred(new_projectile)
	projectile.destroy()

	adopt(new_projectile)

func adopt(projectile: Projectile) -> void:
	projectile.projectile_owner = projectile_owner	
	adopted.emit(projectile)