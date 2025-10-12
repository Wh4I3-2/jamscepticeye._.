class_name FractalProgramDefineToken
extends FractalProgramToken

@export var id: String
@export var result: FractalProgramSymbolResult
@export var terminate: Variant

func _to_string() -> String:
	return 'def{token: "%s", id: "%s", result: %s, terminate: "%s"}' % [token, id, result, terminate]