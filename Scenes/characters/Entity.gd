class_name Entity
extends CharacterBody3D

## Pass additional variables to us on creation
func create(glossary : String, overrides : Dictionary = {}, parent : Node = null) -> Entity:
	var inst = Glossary.entity_scene[glossary].instantiate()
	if parent:
		parent.add_child.call_deferred(inst)
	if !overrides.is_empty():
		Global.deserialize_data_node.call_deferred(inst,overrides)
	return inst

func _enter_tree() -> void:
	#name = str(name," ",randi_range(0,99))
	#var name_debug = str(name," ",randi_range(0,99))
	pass
