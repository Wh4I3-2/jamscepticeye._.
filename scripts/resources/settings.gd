class_name Settings
extends Resource

@export_category("Graphics")
@export var fullscreen: bool : 
	set(new): fullscreen = new; emit_changed()

@export_category("Audio")
@export_range(0.0, 1.0, 0.01) var master_vol: float = 0.5 : 
	set(new): master_vol = new; emit_changed()
@export_range(0.0, 1.0, 0.01) var sfx_vol:    float = 0.5 : 
	set(new): sfx_vol = new; emit_changed()
@export_range(0.0, 1.0, 0.01) var music_vol:  float = 0.5 : 
	set(new): music_vol = new; emit_changed()

@export_category("Accessibility")
@export_range(0.0, 1.0, 0.01) var screen_shake: float = 1.0 : 
	set(new): screen_shake = new; emit_changed()

@export_category("Controls")
@export var controls_left:       InputEventKey: 
	set(new): controls_left = new; emit_changed()
@export var controls_right:      InputEventKey: 
	set(new): controls_right = new; emit_changed()
@export var controls_up:         InputEventKey: 
	set(new): controls_up = new; emit_changed()
@export var controls_down:       InputEventKey: 
	set(new): controls_down = new; emit_changed()
@export var controls_primary:    InputEventKey: 
	set(new): controls_primary = new; emit_changed()
@export var controls_pause:      InputEventKey: 
	set(new): controls_pause = new; emit_changed()
@export var controls_fullscreen: InputEventKey: 
	set(new): controls_fullscreen = new; emit_changed()