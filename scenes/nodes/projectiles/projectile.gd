class_name Projectile
extends CharacterBody2D

signal destroyed

@export var projectile_owner: Node
@export var hitbox: HitBox

@export var speed: float = 100
@export var direction: Vector2

@export var is_lethal: bool = false
@export var non_adoptable: bool = false

func destroy() -> void:
	destroyed.emit()
	queue_free()
