extends CanvasLayer

signal scene_change_started()
signal scene_change_ended(scene: Node)
signal scene_swapped(scene: Node)

@export var transition_rect: ColorRect
@export_file_path("*.tscn", "*.scn") var default_scene: String

var root: Node
var current: Node

var cached_scenes: Dictionary[String, PackedScene]

func _ready() -> void:
	root = get_tree().current_scene

	transition_rect.visible = false

	change_scene(default_scene)

func change_scene(path: String, transition_enter: SceneTransition = null, transition_exit: SceneTransition = null) -> void:
	var scene: PackedScene = null
	if path in cached_scenes.keys():
		scene = cached_scenes.get(path)
	else:
		scene = load(path)
		cached_scenes.set(path, scene)
	
	if (scene == null): 
		print("No scene at \"%s\"" % path)
		return

	_change_scene(scene, transition_enter, transition_exit)

func change_scene_packed(scene: PackedScene, transition_enter: SceneTransition = null, transition_exit: SceneTransition = null) -> void:
	_change_scene(scene, transition_enter, transition_exit)

func _change_scene(scene: PackedScene, transition_enter: SceneTransition, transition_exit: SceneTransition) -> void:
	if (!scene.can_instantiate()):
		print("Failed to instantiate scene at \"%s\"" % scene.resource_path)
		return
	
	scene_change_started.emit()
	
	transition_rect.visible = true
	if transition_enter != null: await show_transition(transition_enter, true)

	_swap_scene.call_deferred(scene.instantiate())
	
	if transition_exit != null: await show_transition(transition_exit, false)
	transition_rect.visible = false
	
	scene_change_ended.emit(current)


func show_transition(transition: SceneTransition, enter: bool = true) -> Signal:
	var tween: Tween = get_tree().create_tween()

	tween.set_trans(transition.transition_type)
	tween.set_ease(transition.ease_type)

	var property: NodePath
	var final_value: Variant

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	transition_rect.color.a = 1.0
	transition_rect.position = Vector2.ZERO

	match transition.type:
		SceneTransition.FADE:
			property = "color:a"
			if enter: transition_rect.color.a = 0.0
			final_value = 1.0 if enter else 0.0
		SceneTransition.LEFT_TO_RIGHT:
			property = "position:x"
			if enter: transition_rect.position.x = -viewport_size.x
			final_value = 0.0 if enter else viewport_size.x
		SceneTransition.RIGHT_TO_LEFT:
			property = "position:x"
			if enter: transition_rect.position.x = viewport_size.x
			final_value = 0.0 if enter else -viewport_size.x
		SceneTransition.TOP_TO_BOTTOM:
			property = "position:y"
			if enter: transition_rect.position.y = -viewport_size.y
			final_value = 0.0 if enter else viewport_size.y
		SceneTransition.BOTTOM_TO_TOP:
			property = "position:y"
			if enter: transition_rect.position.y = viewport_size.y
			final_value = 0.0 if enter else -viewport_size.y

	tween.tween_property(transition_rect, property, final_value, transition.time)
	
	return tween.finished

func _swap_scene(new_scene: Node) -> void:
	if current != null: current.queue_free()

	current = new_scene
	
	root.add_child(new_scene)
	scene_swapped.emit(new_scene)
