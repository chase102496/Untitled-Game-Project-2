## Drag this onto a single node and then specify which values you want to toggle for activated and deactived in export
class_name component_interact_switch_reciever
extends FogVolume

@export var my_component_interact_switch_controller : Node3D

@export var dict_activated : Dictionary
@export var dict_deactivated : Dictionary

func _ready() -> void:
	my_component_interact_switch_controller.activated.connect(_on_activated)
	my_component_interact_switch_controller.deactivated.connect(_on_deactivated)

func _on_activated() -> void: #TODO tweening val
	pass


func _on_deactivated() -> void:
	pass
	#for key in dict_deactivated:
		#var value = dict_deactivated[key]
		#set(key,value)
