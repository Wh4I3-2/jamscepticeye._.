class_name NodeUtils

static func create_timer(node: Node = null, ignore_time_scale: bool = false) -> Timer:
	if node == null:
		node = SceneManager.current
	
	var timer: Timer = Timer.new()

	timer.ignore_time_scale = ignore_time_scale

	timer.one_shot = true
	timer.autostart = false
	
	node.add_child.call_deferred(timer)

	return timer

static func property_equals(node: Node, property: NodePath, value: Variant) -> Signal:
	var property_checker := PropertyChecker.new()
	property_checker.node = node
	property_checker.property = property
	property_checker.value = value

	node.add_child.call_deferred(property_checker)
	return property_checker.property_equals
