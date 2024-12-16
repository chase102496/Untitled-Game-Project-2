## Attach this component and then specify which values you want to toggle for activated and deactivated in export
class_name component_impulse_reciever_tween
extends component_impulse_reciever

## This is where we recieve our activated and deactivated signals
@export var my_impulse : component_impulse

## This is what we change the variables of when a signal is recieved
@export var my_target : Node = self

@export_range(0.0,10.0,0.5) var tween_duration : float = 1.0
@export var dict_activated : Dictionary
@export var dict_deactivated : Dictionary

func _ready() -> void:
	if my_impulse:
		my_impulse.activated.connect(_on_activated)
		my_impulse.deactivated.connect(_on_deactivated)

func apply_changes_with_tween(target: Object, changes: Dictionary, tween_duration : float = 1.0) -> void:
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

func _on_activated() -> void:
	if !dict_activated.is_empty():
		apply_changes_with_tween(my_target,dict_activated,tween_duration)

func _on_deactivated() -> void:
	if !dict_deactivated.is_empty():
		apply_changes_with_tween(my_target,dict_deactivated,tween_duration)
