extends Node


var filepath : String = "user://save/" #root filepath

var data_all = resource_player_data.new()
var filename_all : String = "resource_player_data_all.tres"

var data_scene : Dictionary = {
	"player" : {}
}

##For cross-scene use

func save_data_scene():
	get_tree().call_group("save_data_scene","on_save_data_scene")

func load_data_scene():
	get_tree().call_group("load_data_scene","on_load_data_scene")

##The actual save file

func save_data_all():
	get_tree().call_group("save_data_all","on_save_data_all")
	ResourceSaver.save(data_all, filepath + filename_all)

func load_data_all():
	if ResourceLoader.exists(filepath + filename_all):
		data_all = ResourceLoader.load(filepath + filename_all).duplicate(true)
		get_tree().call_group("load_data_all","on_load_data_all")
	else:
		push_error("ERROR: NO FILE FOUND FOR LOADING")
