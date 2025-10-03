class_name HurtBox
extends Area2D

signal hurt(hitbox: HitBox)

@export var hurtbox_owner: Node
@export var immunity_time: float = 0.1

@onready var immunity_timer: Timer = NodeUtils.create_timer(self)

func _ready() -> void:
	area_entered.connect(on_area_entered)

func on_area_entered(area: Area2D) -> void:
	if !immunity_timer.is_stopped(): return
	if not area is HitBox: return
	
	hurt.emit(area)

	immunity_timer.start(immunity_time)
