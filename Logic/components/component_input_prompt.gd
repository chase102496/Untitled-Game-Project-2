class_name component_input_prompt
extends Node3D

##
var active_inputs : Dictionary = {}

##
signal input_open(input_name : String)
## TBD
signal input_pressed(input_name : String)
##
signal input_closed(input_name : String)

##
func _ready() -> void:
	input_open.connect(_on_input_open)
	input_closed.connect(_on_input_closed)

##
func _on_input_open(input_name : String) -> void:
	var inst = Glossary.create_input_prompt(self,input_name)
	active_inputs[input_name] = inst

##
func _on_input_closed(input_name : String) -> void:
	active_inputs[input_name].queue_free()
	active_inputs.erase(input_name)
