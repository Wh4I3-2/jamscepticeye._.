extends Projectile

@onready var flip_timer: Timer = NodeUtils.create_timer(self)

var flipped: bool = false

func _physics_process(_delta: float) -> void:
	velocity.x = 100 if flipped else -100
	if flip_timer.is_stopped():
		if is_on_wall() or is_on_floor(): 
			flipped = !flipped
			flip_timer.start(1)
	
	move_and_slide()
