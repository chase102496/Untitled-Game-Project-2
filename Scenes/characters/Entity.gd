class_name Entity
extends CharacterBody3D

## Pass additional variables to us on creation
func create(glossary : String, overrides : Dictionary = {}, parent : Node = null) -> Entity:
	var inst = Glossary.entity_scene[glossary].instantiate()
	if parent:
		parent.add_child.call_deferred(inst)
	if !overrides.is_empty():
		Glossary.deserialize_data.call_deferred(inst,overrides)
	return inst
