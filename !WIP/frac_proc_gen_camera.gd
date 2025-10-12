extends Camera2D

@export var speed: float = 0.1
@export var lerp_speed: float = 8.0

@export var snap_distance: float = 2.0

@export var drag_control: Control

@export var stars: ColorRect
@export var vignette: ColorRect

var drag_control_hovered: bool
var dragging: bool

var target_pos: Vector2
var stars_material: ShaderMaterial
var vignette_material: ShaderMaterial

var dir: Vector2

var just_entered_drag: bool
var mouse_pos: Vector2

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if drag_control_hovered:
					mouse_pos = get_tree().root.get_mouse_position()
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
					dragging = true
			elif Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				Input.warp_mouse.call_deferred(mouse_pos)
				dragging = false
	if event is InputEventMouseMotion:
		if dragging:
			target_pos -= event.relative * speed

func _ready() -> void:
	if stars != null: 
		if stars.material != null: 
			if stars.material is ShaderMaterial: stars_material = stars.material
	if vignette != null: 
		if vignette.material != null: 
			if vignette.material is ShaderMaterial: vignette_material = vignette.material

	drag_control.mouse_entered.connect(set.bindv(["drag_control_hovered", true]))
	drag_control.mouse_exited.connect(set.bindv(["drag_control_hovered", false]))

func _process(delta: float) -> void:
	position = position.lerp(target_pos, delta * lerp_speed)

	if dir != Vector2.ZERO and position.distance_to(target_pos) < snap_distance:
		position = position.round()
		target_pos = target_pos.round()
	
	stars_material.set_shader_parameter("offset", position * 0.2)
	vignette_material.set_shader_parameter("offset", position * 0.2)
