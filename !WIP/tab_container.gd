class_name FileTabContainer
extends TabContainer

signal tab_close_pressed(tab: int)

func _ready() -> void:
	var tab_bar: TabBar = get_tab_bar()

	tab_bar.close_with_middle_mouse = true
	tab_bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY

	tab_bar.tab_close_pressed.connect(
		func(tab: int) -> void: tab_close_pressed.emit(tab)
	)