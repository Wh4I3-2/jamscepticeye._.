extends Node

var fullscreen: bool = false: 
    set(new):
        fullscreen = new
        DisplayServer.window_set_mode(
            DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if fullscreen else
            DisplayServer.WINDOW_MODE_WINDOWED
        )

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("fullscreen"):
        fullscreen = !fullscreen