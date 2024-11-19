extends Node

var data_file = resource_player_data.new()
var filepath : String = "user://save/"
var filename : String = "resource_player_data.tres"



func load_data():
	data_file = ResourceLoader.load(filepath + filename).duplicate(true)

func save_data():
	ResourceSaver.save(data_file, filepath + filename)
