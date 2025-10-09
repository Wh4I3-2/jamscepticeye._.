@tool
extends CanvasLayer


@export var container: Control

@export var properties: Dictionary[StringName, Variant] : 
	set(new): properties = new; update_properties()
var property_nodes: Dictionary[StringName, Label]

var ui_visible: bool = true

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event.is_action_pressed("debug.menu"):
		visible = !visible
	if event.is_action_pressed("debug.toggle_ui"):
		ui_visible = !ui_visible
		for node in get_tree().get_nodes_in_group("ui"):
			node.visible = ui_visible

func on_root_child_entered_tree(node: Node) -> void:
	if node.is_in_group("ui"):
		node.visible = ui_visible

func _ready() -> void:
	visible = false

	get_tree().root.child_entered_tree.connect(on_root_child_entered_tree)

	container.visible = true
	if Engine.is_editor_hint():
		if self == DebugMenu: container.visible = false
	update_properties()

func _process(_delta: float) -> void:
	set_property(&"FPS", Engine.get_frames_per_second())

func set_property(property: StringName, value: Variant) -> void:
	properties.set(property, value)

	update_properties()

func remove_property(property: StringName) -> void:
	properties.erase(property)
	var label: Label = property_nodes.get(property)
	if label != null: label.queue_free()

func update_properties() -> void:
	for property in property_nodes.keys():
		if not property in properties.keys():
			var c: Label = property_nodes.get(property)
			if c != null: c.queue_free()
			property_nodes.erase(property)
	for property in properties.keys():
		var label: Label
		if not property in property_nodes.keys(): 
			if container == null: continue
			label = Label.new()
			container.add_child(label)
			label.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
			property_nodes.set(property, label)
		else:
			label = property_nodes.get(property)
		
		label.text = "%s: %s" % [property, properties.get(property)]
