class_name RandomUtils

static var calls: int = 0

static func weighted_random(weighted_dict: Dictionary) -> Variant:
	var sum: int = 0
	for v in weighted_dict.values():
		sum += int(v)
	
	calls = (calls + 43) % 5000
 
	var rand := RandomNumberGenerator.new()
	rand.seed = calls
	rand.randomize()

	var value: int = rand.randi_range(0, sum)

	var curr_weight: int = 0
	for k in weighted_dict.keys():
		var weight: int = int(weighted_dict.get(k))
		curr_weight += weight

		if curr_weight < value: continue
		
		return k

	if len(weighted_dict.keys()) > 0:
		return weighted_dict.keys().back()

	return null
