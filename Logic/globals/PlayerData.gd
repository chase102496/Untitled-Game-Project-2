extends Node

var filepath : String = "user://save/" #root filepath

## For persistent data, like in a save file
var data_persistent = resource_player_data.new()
var filename_persistent : String = "resource_player_data_persistent.tres"

## For single-session use
var data_session : Dictionary = {
	"player" : {
	}
}

func is_dictionary_completely_empty(dict: Dictionary) -> bool:
	for key in dict:
		var value = dict[key]
		if typeof(value) == TYPE_DICTIONARY:
			# If the value is a dictionary, check recursively
			if not is_dictionary_completely_empty(value):
				return false
		else:
			# If the value is not a dictionary and is not empty, return false
			return false
	# If we get here, everything was empty
	return true

##For single session use

func save_template_session(data):
	pass #TODO

func load_template_session(data):
	pass #TODO

func save_data_session():
	print_debug("+ Saved session data")
	get_tree().call_group("save_data_session","on_save_data_session")

func load_data_session():
	if !is_dictionary_completely_empty(data_session):
		get_tree().call_group("load_data_session","on_load_data_session")
		print_debug("+ Loaded session data")
	else:
		print_debug("+ No session data found to load, initializing...")

##The actual save file

func save_data_persistent():
	print_debug("+ Saved persistent data")
	get_tree().call_group("save_data_persistent","on_save_data_persistent")
	ResourceSaver.save(data_persistent, filepath + filename_persistent)

func load_data_persistent():
	if ResourceLoader.exists(filepath + filename_persistent):
		data_persistent = ResourceLoader.load(filepath + filename_persistent).duplicate(true)
		get_tree().call_group("load_data_persistent","on_load_data_persistent")
		print_debug("+ Loaded persistent data")
	else:
		push_error("++ Making new persistent save file")
