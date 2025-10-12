class_name SceneChange
extends Resource

@export_file_path("*.tscn", "*.scn") var path: String
@export var transition_enter: SceneTransition
@export var transition_exit: SceneTransition
@export var swap_delay: float = 0.0


@warning_ignore("shadowed_variable")
static func of(path: String, transition_enter: SceneTransition = null, transition_exit: SceneTransition = null, swap_delay: float = 0.0) -> SceneChange:
	var scene_change: SceneChange = SceneChange.new()

	scene_change.path = path
	scene_change.transition_enter = transition_enter
	scene_change.transition_exit = transition_exit
	scene_change.swap_delay = swap_delay

	return scene_change
