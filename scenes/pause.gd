extends CanvasLayer

@export var pause_nodes: Array[Node]

@export var resume_button: Button
@export var menu_button: Button
@export var quit_button: Button

var pause_node_defaults: Dictionary[Node, Node.ProcessMode]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		visible = !visible

func _ready() -> void:
	visibility_changed.connect(on_visibility_changed)

	process_mode = Node.PROCESS_MODE_ALWAYS

	pause_node_defaults = {}

	for node in pause_nodes:
		pause_node_defaults.set(node, node.process_mode)

	resume_button.pressed.connect(
		func() -> void:
			if !visible: return
			visible = false
	)
	menu_button.pressed.connect(
		func() -> void:
			if !visible: return
			SceneManager.change_scene(
				"res://scenes/screens/main_menu.tscn", 
				SceneTransition.of(0.4 , SceneTransition.Type.RIGHT_TO_LEFT, Tween.TRANS_SINE, Tween.EASE_IN),
				SceneTransition.of(0.4 , SceneTransition.Type.RIGHT_TO_LEFT, Tween.TRANS_SINE, Tween.EASE_OUT),
				0.1
			)
	)
	if quit_button != null: quit_button.pressed.connect(
		func() -> void:
			if !visible: return
			SceneManager.change_scene("res://scenes/exit.tscn", SceneTransition.of(1.5, SceneTransition.FADE, Tween.TRANS_QUAD, Tween.EASE_IN))
	)

func on_visibility_changed() -> void:
	for node in pause_nodes:
		node.process_mode = Node.PROCESS_MODE_DISABLED if visible else pause_node_defaults.get(node)

	if visible: resume_button.grab_focus()
