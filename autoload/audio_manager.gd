extends Node

var master_bus: int : 
	get(): return AudioServer.get_bus_index("Master")
var music_bus: int : 
	get(): return AudioServer.get_bus_index("Music")
var sfx_bus: int : 
	get(): return AudioServer.get_bus_index("SFX")

var master_volume: float :
	set(new):
		master_volume = new
		AudioServer.set_bus_volume_linear(master_bus, new)

var music_volume: float :
	set(new):
		music_volume = new
		AudioServer.set_bus_volume_linear(music_bus, new)

var sfx_volume: float :
	set(new):
		sfx_volume = new
		AudioServer.set_bus_volume_linear(sfx_bus, new)