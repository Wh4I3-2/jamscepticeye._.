class_name FractalEditor
extends Control

@export var file: FractalProgramFile
var compare_file: FractalProgramFile

@export var load_button: BaseButton
@export var save_button: BaseButton
@export var save_as_button: BaseButton

@export var code_edit: TextEdit
@export var axiom_edit: LineEdit

var title: String

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tools.save"):
		save_file()
	if event.is_action_pressed("tools.save_as"):
		save_file_as()

func load_file() -> void:
	if file == null: return
	if file.path == "": 
		var dialog := FileDialog.new()
		
		dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		dialog.access = FileDialog.ACCESS_USERDATA
		dialog.use_native_dialog = true
		dialog.add_filter("*.frp", "Fractal Program")
		dialog.add_filter("*.tres, *.res", "Godot Resource")

		add_child(dialog)
		dialog.popup_centered_ratio()

		dialog.file_selected.connect(
			func(found: String) -> void: 
				file.path = found
				load_file()
				dialog.queue_free()
		)
		return
	file = ResourceLoader.load(file.path)

	code_edit.text = file.source
	axiom_edit.text = file.axiom

func save_file() -> void:
	if file.path == "":
		save_file_as()
		return
	
	ResourceSaver.save(file, file.path)

func save_file_as() -> void:
	var dialog := FileDialog.new()
	
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_USERDATA
	dialog.use_native_dialog = true
	dialog.add_filter("*.frp", "Fractal Program")
	dialog.add_filter("*.tres, *.res", "Godot Resource")

	add_child(dialog)
	dialog.popup_centered_ratio()

	dialog.file_selected.connect(
		func(found: String) -> void: 
			file.path = found
			save_file()
			dialog.queue_free()
	)

func _ready() -> void:
	load_button.pressed.connect(load_file)
	save_button.pressed.connect(save_file)
	save_as_button.pressed.connect(save_file_as)

	code_edit.text_changed.connect(update)
	axiom_edit.text_changed.connect(update)

	title = "Unnamed"

	code_edit.text = file.source
	axiom_edit.text = file.axiom

	update_name()

func update() -> void:
	if file == null: file = FractalProgramFile.new()

	title = file.path.get_file()

	file.source = code_edit.text
	file.axiom = axiom_edit.text

	update_name()

func update_name() -> void:
	name = title
