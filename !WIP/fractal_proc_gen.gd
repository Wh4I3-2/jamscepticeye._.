class_name FractalProcGen
extends Node2D

static var logger: FractalLogger

@export var line_prefab: Line2D
@export var viewport: SubViewport

@export var camera: Camera2D

@export var fullscreen_button: BaseButton
@export var viewport_container: SubViewportContainer

@export var hide_on_fullscreen: Array[Control]

@export var logger_to_make_static: FractalLogger

@export var program_edit: TextEdit
@export var axiom_edit: LineEdit

@export var run_button: BaseButton

@export var length: float = 10.0

var program_hash: int

var program: FractalProgram

var lines: Array[Line2D] = []


func _ready() -> void:
	logger = logger_to_make_static

	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_tree().root.content_scale_size *= 6.0

	for fx in get_tree().get_nodes_in_group("fx"):
		fx.queue_free()

	fullscreen_button.toggled.connect(toggle_fullscreen)

	run_button.pressed.connect(run)

func run() -> void:
	if program_edit.text.hash() != program_hash:
		program_hash = program_edit.text.hash()
		program = FractalProgram.from(program_edit.text)
	var result: String = program.run(axiom_edit.text)
	logger.info(result, "Fractal")

	generate(result)

func generate(axiom: String) -> void:
	line_prefab.clear_points()

	for line in lines:
		if line == null: continue
		line.free()
	
	lines.clear()

	var root_line: Line2D = line_prefab.duplicate()
	root_line.global_position = line_prefab.global_position
	line_prefab.add_child(root_line)

	lines.append(root_line)

	root_line.add_point(Vector2.ZERO)

	var branches: Array[Line2D] = [root_line]
	var dirs: Dictionary[Line2D, Vector2] = {root_line: Vector2.UP}

	for c in axiom:
		if not c in program.tokens.keys(): continue
		var id: String = program.tokens.get(c).id

		match id:
			"branch_enter": 
				var branch: Line2D = line_prefab.duplicate()
				branch.global_position = line_prefab.global_position
				branches.back().add_child(branch)
				var dir: Vector2 = dirs.get(branches.back())
				dirs.set(branch, dir.rotated(deg_to_rad(-40.0)))
				branch.add_point(branches.back().get_point_position(branches.back().get_point_count() - 1))
				branches.append(branch)
				lines.append(branch)
			"branch_exit": 
				dirs.erase(branches.back())
				branches.pop_back()
			"continue":
				var last_point: Vector2 = branches.back().get_point_position(branches.back().get_point_count() - 1)
				branches.back().add_point(last_point + dirs.get(branches.back()) * length)
			"turn_left":
				var dir: Vector2 = dirs.get(branches.back())
				dir = dir.rotated(deg_to_rad(-30.0))
				dirs.set(branches.back(), dir)
				var last_point: Vector2 = branches.back().get_point_position(branches.back().get_point_count() - 1)
				branches.back().add_point(last_point + dir * 0.5 * length)
			"turn_right":
				var dir: Vector2 = dirs.get(branches.back())
				dir = dir.rotated(deg_to_rad(30.0))
				dirs.set(branches.back(), dir)
				var last_point: Vector2 = branches.back().get_point_position(branches.back().get_point_count() - 1)
				branches.back().add_point(last_point + dir * 0.5 * length)


func toggle_fullscreen(toggled: bool) -> void:
	for c in hide_on_fullscreen:
		c.visible = !toggled
	
	if toggled:
		viewport_container.stretch_shrink = 2
		return

	viewport_container.stretch_shrink = 1
