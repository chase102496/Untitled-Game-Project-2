## Just kind of a catch-all for utility functions and things we use across the board
extends Node
var camera : Node3D = null
var camera_function : Node = null
var camera_object : Node = null
var player : Node3D = null
var state_chart_already_exists : bool = false

var peepee : Dictionary = {}

## Grabs just the script name of the object
func get_glossary_nickname(entity : Node):
	var filepath = entity.get_scene_file_path()
	return filepath.right(-filepath.rfind("/") - 1).left(-5)

## Compares two arrays and returns any matching values between the two
func inner_join(array1: Array, array2: Array) -> Array:
	var matches = []
	for item in array1:
		if item in array2:
			matches.append(item)
	return matches

## Checks if a dictionary is empty
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

## Tween any value based on importing it from a dictionary and tweening the current object's value to the one specificed in the dict
## For example, dict : Dictionary = { "test.subvar" : 10.0 }
## Let Object.test.subvar be 1.0
## Tweens the Object.test.subvar from 1 to 10 in tween_duration seconds
func apply_changes_with_tween(target : Object, changes : Dictionary, tween_duration : float = 1.0) -> void:
	for key in changes:
		var value = changes[key]
		
		# Handle nested paths (e.g., "transform.origin")
		var path = key.split(".")
		var current = target
		for i in range(path.size() - 1):
			if path[i] not in current:
				print("Error: '%s' does not exist on '%s'" % [path[i], current.name])
				return
			current = current.get(path[i])
		
		# Set the final property or tween it
		var final_key = path[-1]
		
		if final_key in current:
			var current_value = current.get(final_key)
			
			# Tween if the value is tweenable
			if typeof(current_value) in [TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]:
				var tween = create_tween()
				tween.tween_property(current, final_key, value, tween_duration)
			else:
				current.set(final_key, value)  # Direct set for non-tweenable values
		elif final_key.begins_with("shader_param:"):  # Handle shader parameters
			var param_name = final_key.replace("shader_param:", "")
			if current is Material:
				var current_value = current.get_shader_parameter(param_name)
				
				# Tween shader parameters if applicable
				if typeof(current_value) in [TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]:
					var tween = create_tween()
					tween.tween_method(current.set_shader_parameter, [param_name, current_value], [param_name, value], tween_duration)
				else:
					current.set_shader_parameter(param_name, value)  # Direct set for non-tweenable
			else:
				print("Error: '%s' is not a material, cannot set shader parameter '%s'" % [current.name, param_name])
		else:
			print("Error: Property '%s' does not exist on '%s'" % [final_key, current.name])

## 
func is_signal_connected_to_anything(node: Object, signal_name: String) -> bool:
	var connections = node.get_signal_connection_list(signal_name)
	return connections.size() > 0

## 
func disconnect_all_connections(node: Object, signal_name: String) -> void:
	var connections = node.get_signal_connection_list(signal_name)
	for connection in connections:
		node.disconnect(signal_name, connection["method"])

## Object -> Dict
## Takes all the strings found in export_data and returns them as key : value pairs in a dictionary
## So if export_data = ["object.my_component_health.max_health"] is the array
## It will pull that variable from the target, and return a dict of:
## { "object.my_component_health.max_health" : (value it found) }
func serialize_data(target: Object, export_data: PackedStringArray) -> Dictionary:
	var result : Dictionary = {}
	var is_valid : bool
	
	for path in export_data:
		var keys = path.split(".") #E.g. splitting save_list which is PackedStringArray
		var current = target
		is_valid = true
		
		# Traverse the path to the final property
		for i in keys.size() - 1:
			if current.get(keys[i]):
				current = current.get(keys[i])
			else:
				is_valid = false
				push_error("Error: '%s' does not exist on '%s'" % [keys[i], current.name])
				break
		
		if is_valid:
			## Grabbing final key, which should be the string of the final part of the node
			## E.g. "test.ing.thing" would be "thing"
			var final_key : String = keys[-1]
			
			## Create nested dictionary structure in result
			var nested = result
			for i in keys.size() - 1:
				if not nested.has(keys[i]):
					nested[keys[i]] = {}
				nested = nested[keys[i]]
			
			## Checking for special get conditions
			## @ denotes we want to call a special function to save the object's info
			## @state_current_nodepath will save the current state as a nodepath relative to state_chart._state
			if final_key[0] == "@":
				var cmd = final_key.substr(1)
				
				match cmd:
					## Save the current state of the node as a NodePath
					"state_current_nodepath":
						if current.get("state_chart"):
							nested[final_key] = current.state_chart.get_current_state_nodepath()
						else:
							push_error("Object has no state_chart to capture serialize states for: ",final_key," ",current)
					_:
						push_error("Could not match command: ",final_key," ",current)
			
			## Is just a normal variable
			elif current.get(final_key):
				## Set the value at the final level
				nested[final_key] = current.get(final_key)
			
			else:
				push_error("Error: Property '%s' does not exist on '%s'" % [final_key, current.name])
	
	return result

## Dict -> Object
## Sets vars found on imported_data dict onto the target
## Basically merges the imported_data into an existing object by setting all the vars to mirror the imported_data
## Also works for functions. Use the STRING reference to the function in the key, and an ARRAY of arguments for the value
## E.g. { "like" : { "this" : 123 } } instead of { "like.this" : 123 }
func deserialize_data(target: Object, imported_data: Dictionary) -> void:
	
	for key in imported_data:
		if typeof(imported_data[key]) == TYPE_DICTIONARY:
			# Nested data handling
			if target.get(key):
				var nested_target = target.get(key)
				if typeof(nested_target) == TYPE_OBJECT:
					deserialize_data(nested_target, imported_data[key]) # Recursively process the nested dictionary
				else:
					push_error("Error: Property '%s' is not an object and cannot have nested data." % key)
			else:
				push_error("Error: Property '%s' does not exist on target '%s'." % [key, target.name])
		## This means we're inside the last dictionary, and we should be referencing the final part
		else:
			
			if key[0] == "@":
				var cmd = key.substr(1)
				
				match cmd:
					## Transition to the state found in the dictionary, which should be a NodePath
					"state_current_nodepath":
						target.state_chart.set_load_state(imported_data[key],true)
					_:
						pass
			
			# Set the value directly
			elif target.get(key):
				if target.has_method(key):
					Callable(target, key).call_deferred(imported_data[key])
				else:
					target.set(key, imported_data[key])
			else:
				push_error("Error: Property or method '%s' does not exist on target '%s'." % [key, target.name])

## An alternate form used for a different format of imported_data
## E.g. { "like.this" : 123 } instead of { "like" : { "this" : 123 } }
func deserialize_data_node(target : Object, imported_data_nodes : Dictionary) -> void:
	for key in imported_data_nodes:
		var value = imported_data_nodes[key]
		
		# Handle nested paths (e.g., "transform.origin")
		var path = key.split(".")
		var current = target
		for i in range(path.size() - 1):
			if path[i] not in current: #It's not a var
				if !current.has_method(path[i]): #It's not a method
					push_error("Error: '%s' does not exist on '%s'" % [path[i], current.name])
					return
			current = current.get(path[i])
		
		# Get the final property
		var final_key = path[-1]
		
		if final_key in current:
			##If it's a callable, the final key will be args in an array
			# The periods are the scope (so object_a.object_ab.current.final_key(value)
			if current.has_method(final_key):
				Callable(current,final_key).callv.call_deferred(value)
			else:
				current.set(final_key, value)
		else:
			push_error("Error: Property '%s' does not exist on '%s'" % [final_key, current.name])
