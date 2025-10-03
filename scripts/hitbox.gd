class_name HitBox 
extends Area2D

signal hit(hurtbox: HurtBox)

@export var hitbox_owner: Node

@export var damage: float

func _ready() -> void:
    area_entered.connect(on_area_entered)

func on_area_entered(area: Area2D) -> void:
    if not area is HurtBox: return

    hit.emit(area)