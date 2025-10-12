class_name PanelTextureButton
extends TextureButton

@export var normal_box:   StyleBox = StyleBoxEmpty.new()
@export var pressed_box:  StyleBox = StyleBoxEmpty.new()
@export var hover_box:    StyleBox = StyleBoxEmpty.new()
@export var disabled_box: StyleBox = StyleBoxEmpty.new()
@export var focus_box:    StyleBox = StyleBoxEmpty.new()

@export var normal_modulate:   Color = Color.WHITE
@export var pressed_modulate:  Color = Color.WHITE
@export var hover_modulate:    Color = Color.WHITE
@export var disabled_modulate: Color = Color.WHITE

var panel: Panel

var focus_panel: Panel
var focus_panel_box: StyleBox

func _ready() -> void:
	panel = Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	panel.add_theme_stylebox_override("panel", normal_box)
	panel.position = Vector2.ZERO
	panel.size = size

	add_child(panel)


	focus_panel = Panel.new()
	focus_panel.visible = false
	focus_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	focus_panel.add_theme_stylebox_override("panel", focus_box)
	focus_panel.position = Vector2.ZERO
	focus_panel.size = size

	add_child(focus_panel)

	mouse_entered.connect(update.call_deferred)
	mouse_exited.connect(update.call_deferred)
	pressed.connect(update.call_deferred)
	focus_entered.connect(update.call_deferred)
	focus_exited.connect(update.call_deferred)
	button_down.connect(update.call_deferred)
	button_up.connect(update.call_deferred)

	update()

func override_panel(box: StyleBox) -> void:
	if panel.has_theme_stylebox_override("panel"): panel.remove_theme_stylebox_override("panel")
	panel.add_theme_stylebox_override("panel", box)

func update() -> void:
	focus_panel.visible = has_focus()
	
	if disabled:
		override_panel(disabled_box)
		self_modulate = disabled_modulate
		return

	if button_pressed:
		override_panel(pressed_box)
		self_modulate = pressed_modulate
		return
	
	if is_hovered():
		override_panel(hover_box)
		self_modulate = hover_modulate
		return

	override_panel(normal_box)
	self_modulate = normal_modulate