class_name FractalProgramSymbolResult
extends Resource

@export var result: String : set = set_result, get = get_result

func set_result(new: String) -> void:
	result = new

func get_result() -> String:
	return result

func _to_string() -> String:
	return '"%s"' % result