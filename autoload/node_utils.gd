class_name NodeUtils

static func create_timer(node: Node = null) -> Timer:
    if node == null:
        node = SceneManager.current
    
    var timer: Timer = Timer.new()

    timer.one_shot = true
    timer.autostart = false
    
    node.add_child.call_deferred(timer)

    return timer