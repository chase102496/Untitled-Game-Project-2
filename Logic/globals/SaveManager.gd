extends Node

## Root filepath for persistent saves
var filepath : String = "user://save/" 
var filename_persistent : String = "resource_player_data_persistent.tres"

## For persistent data, like in a save file
var data_persistent = resource_player_data.new()

## For single-session use
var data_session : Dictionary = {}

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

## Gets the specific save location of an object based on a global id
func get_save_location_global(obj : Object, data : Variant, global_id : String):
	if data.has(global_id):
		pass
	else:
		data[global_id] = {}
	
	return data[global_id]

## Gets the specific save location of an object with a save_id_scene
# This is used for saving scene-specific info, e.g. Levers being flipped, chests being opened, etc.
# Requires the object, and the dict or object we are looking for it
func get_save_location_scene(obj : Object, data : Variant):
	
	if !obj.has_meta("save_id_scene"):
		push_error("Saveable object did not have a save_id_scene. Make sure it is in the save_id_scene group :", obj.name, " ", obj)
		return
	
	var obj_save_id = obj.get_meta("save_id_scene")

	## Might need to create new save spot for it
	if !data.has(obj_save_id):
		data[obj_save_id] = {}
	
	return data[obj_save_id]

### Sets the root object's variables based on
## If an object with its ID exists (CASE 1)
#func import_data(root : Object) -> void:
	#pass
#
### Gets the object's variables based on
## If a dictionary with its ID exists (CASE 1)
#func export_data(dict : Dictionary) -> void:
	#pass

##For single session use

func save_data_session():
	print_debug("+ Saved session data")
	get_tree().call_group("save_data_session","on_save",SaveManager.data_session)

func load_data_session():
	if !is_dictionary_completely_empty(data_session):
		get_tree().call_group("load_data_session","on_load",SaveManager.data_session)
		print_debug("+ Loaded session data")
	else:
		print_debug("+ No session data found to load, initializing...")

## For persistent data, like in a save file

func save_data_persistent():
	print_debug("+ Saved persistent data")
	get_tree().call_group("save_data_persistent","on_save",SaveManager.data_persistent)
	ResourceSaver.save(data_persistent, filepath + filename_persistent)

func load_data_persistent():
	if ResourceLoader.exists(filepath + filename_persistent):
		data_persistent = ResourceLoader.load(filepath + filename_persistent).duplicate(true)
		get_tree().call_group("load_data_persistent","on_load",SaveManager.data_persistent)
		print_debug("+ Loaded persistent data")
	else:
		print_debug("++ Making new persistent save file")
