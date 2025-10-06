class_name DashProjectile
extends SimpleProjectile

@export var acceleration: float
@export var start_speed: float

func _ready() -> void:
	super._ready()

	_speed = start_speed

func _physics_process(delta: float) -> void:
	if !GameManager.player.retribution_window_timer.is_stopped(): return
	
	_speed = move_toward(_speed, speed, delta * acceleration)

	super._physics_process(delta)