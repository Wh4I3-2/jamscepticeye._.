extends CanvasLayer

signal scene_change_started()
signal scene_change_ended(scene: Node)
signal scene_swapped(scene: Node)
signal next_scene_ready

@export var transition_rect: ColorRect

var root: Node
var current: Node

var cached_scenes: Dictionary[String, PackedScene]

var transitioning: bool = false

func _ready() -> void:
	root = get_tree().current_scene

	transition_rect.visible = false

	for setup_scene in SettingsManager.static_settings.setup_scenes:
		change_scene(setup_scene, false)
		await next_scene_ready

	change_scene(SettingsManager.static_settings.default_scene)


func change_scene(scene_change: SceneChange, cache: bool = true) -> void:
	var scene: PackedScene = null
	if cache and scene_change.path in cached_scenes.keys():
		scene = cached_scenes.get(scene_change.path)
	else:
		scene = load(scene_change.path)
		cached_scenes.set(scene_change.path, scene)
	
	if (scene == null): 
		print("No scene at \"%s\"" % scene_change.path)
		return

	_change_scene(scene, scene_change.transition_enter, scene_change.transition_exit, scene_change.swap_delay)

func change_scene_packed(scene: PackedScene, transition_enter: SceneTransition = null, transition_exit: SceneTransition = null, swap_delay: float = 0.0) -> void:
	_change_scene(scene, transition_enter, transition_exit, swap_delay)

func _change_scene(scene: PackedScene, transition_enter: SceneTransition, transition_exit: SceneTransition, swap_delay: float) -> void:
	if transitioning: return

	if (!scene.can_instantiate()):
		print("Failed to instantiate scene at \"%s\"" % scene.resource_path)
		return
	
	get_tree().paused = true
	scene_change_started.emit()
	transitioning = true
	
	transition_rect.visible = true

	if transition_enter != null: await show_transition(transition_enter, true)

	if swap_delay > 0: await get_tree().create_timer(swap_delay).timeout

	_swap_scene.call_deferred(scene.instantiate())
	get_tree().paused = false

	if transition_exit != null: await show_transition(transition_exit, false)
	transition_rect.visible = false

	transitioning = false	
	scene_change_ended.emit(current)


func show_transition(transition: SceneTransition, enter: bool = true) -> Signal:
	var tween: Tween = get_tree().create_tween()

	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

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

	root.add_child.call_deferred(new_scene)
	scene_swapped.emit(new_scene)

	if !new_scene.is_node_ready(): await new_scene.ready

	next_scene_ready.emit()
