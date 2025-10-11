extends Button

@export var speed: float = 4.0

@export var hover_margin: float = 4.0
@export var focus_margin: float = 5.0

@export var pointer: Control
@export var focus_panel: Panel

var normal_base_margin:  float
var hover_base_margin:   float
var pressed_base_margin: float

var font_var: FontVariation

var normal:      StyleBox
var hover:       StyleBox
var focus:       StyleBoxFlat
var pressed_box: StyleBox

var base_width: float
var base_x:     float

var height: float
var margin: float

func _ready() -> void:
	normal      = get_theme_stylebox("normal").duplicate()
	hover       = get_theme_stylebox("hover").duplicate()
	pressed_box = get_theme_stylebox("pressed").duplicate()

	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed_box)

	normal_base_margin  = normal.content_margin_left
	hover_base_margin   = hover.content_margin_left
	pressed_base_margin = pressed_box.content_margin_left

	if pointer != null:
		base_width = pointer.size.x
		base_x = pointer.position.x

	height = size.y

	focus = focus_panel.get_theme_stylebox("panel").duplicate()
	focus_panel.add_theme_stylebox_override("panel", focus)

	if pointer != null:
		pointer.size.x     = 0.0
		pointer.position.x = base_x + base_width
	
	mouse_entered.connect(
		func() -> void:
			grab_focus()
	)


func _process(delta: float) -> void:
	var target_margin = 0.0
	var target_size: float = 0.0

	if is_hovered(): 
		target_margin = hover_margin
		target_size = base_width
	if has_focus(): 
		target_margin = focus_margin
		target_size = base_width
	
	focus.border_width_left = floori(lerpf(focus.border_width_left, focus_panel.size.x if has_focus() else 0.0, delta * speed))

	margin = lerpf(margin, target_margin, delta * speed)

	normal.content_margin_left      = roundf(margin + normal_base_margin)
	hover.content_margin_left       = roundf(margin + hover_base_margin)
	pressed_box.content_margin_left = roundf(margin + pressed_base_margin)

	if pointer != null:
		pointer.size.x     = lerpf(pointer.size.x,     target_size, delta * speed)
		pointer.position.x = lerpf(pointer.position.x, base_x + base_width - target_size, delta * speed)

	size.y = height
