class_name FractalProgramWeightedSymbolResult
extends FractalProgramSymbolResult

@export var weights: Dictionary[String, int] 

func get_result() -> String:
	return RandomUtils.weighted_random(weights)

func _to_string() -> String:
	return "Weighted%s" % str(weights)
