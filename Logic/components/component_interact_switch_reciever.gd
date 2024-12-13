## Drag this onto a single node and then specify which values you want to toggle for activated and deactived in export
class_name component_interact_switch_reciever
extends Node3D

@export var my_component_interact_switch_controller : Node3D
@export var my_owner : Node = self

@export_range(0.0,10.0,0.5) var tween_duration : float = 1.0
@export var dict_activated : Dictionary
@export var dict_deactivated : Dictionary

func _ready() -> void:
	my_component_interact_switch_controller.activated.connect(_on_activated)
	my_component_interact_switch_controller.deactivated.connect(_on_deactivated)

func apply_changes_with_tween(target: Object, changes: Dictionary, tween_duration : float = 1.0) -> void:
	var tween = create_tween()  # Create a new tween for this operation
	for key in changes:
		var value = changes[key]
		
		# Handle nested paths (e.g., "transform.origin")
		var path = key.split(".")
		var current = target
		for i in range(path.size() - 1):
			if not current.get(path[i]):
				print("Error: '%s' does not exist on '%s'" % [path[i], current.name])
				return
			current = current.get(path[i])
		
		# Set the final property or tween it
		var final_key = path[-1]
		if current.get(final_key):
			var current_value = current.get(final_key)
			
			# Tween if the value is tweenable
			if typeof(current_value) in [TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]:
				tween.tween_property(current, final_key, value, tween_duration)
			else:
				current.set(final_key, value)  # Direct set for non-tweenable values
		elif final_key.begins_with("shader_param:"):  # Handle shader parameters
			var param_name = final_key.replace("shader_param:", "")
			if current is Material:
				var current_value = current.get_shader_parameter(param_name)
				
				# Tween shader parameters if applicable
				if typeof(current_value) in [TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]:
					tween.tween_method(current.set_shader_parameter, [param_name, current_value], [param_name, value], tween_duration)
				else:
					current.set_shader_parameter(param_name, value)  # Direct set for non-tweenable
			else:
				print("Error: '%s' is not a material, cannot set shader parameter '%s'" % [current.name, param_name])
		else:
			print("Error: Property '%s' does not exist on '%s'" % [final_key, current.name])

func _on_activated() -> void: #TODO tweening val
	if !dict_activated.is_empty():
		apply_changes_with_tween(my_owner,dict_activated,tween_duration)

func _on_deactivated() -> void:
	if !dict_deactivated.is_empty():
		apply_changes_with_tween(my_owner,dict_deactivated,tween_duration)
