extends Node


var filepath : String = "user://save/" #root filepath

var data_all = resource_player_data.new()
var filename_all : String = "resource_player_data_all.tres"

var data_scene : Dictionary = {
	"player" : {}
}

##For cross-scene use

func save_template_scene(data):
	pass #TODO

func load_template_scene(data):
	pass #TODO

func save_data_scene():
	print_debug("+ Saved scene data")
	get_tree().call_group("save_data_scene","on_save_data_scene")

func load_data_scene():
	print_debug("+ Loaded scene data")
	if !data_scene.player.is_empty():
		get_tree().call_group("load_data_scene","on_load_data_scene")
	else:
		print_debug("+ No scene data found to load, initializing...")

##The actual save file

func save_data_all():
	print_debug("+ Saved all data")
	get_tree().call_group("save_data_all","on_save_data_all")
	ResourceSaver.save(data_all, filepath + filename_all)

func load_data_all():
	print_debug("+ Loaded all data")
	if ResourceLoader.exists(filepath + filename_all):
		data_all = ResourceLoader.load(filepath + filename_all).duplicate(true)
		get_tree().call_group("load_data_all","on_load_data_all")
	else:
		push_error("ERROR: NO FILE FOUND FOR LOADING")
