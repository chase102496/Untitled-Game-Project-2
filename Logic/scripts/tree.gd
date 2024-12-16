extends Node3D
#@onready var my_component_ghosting: component_ghosting = $Components/component_ghosting
@onready var body = $MeshInstance3D/StaticBody3D

func _ready() -> void:
	body.set_collision_layer_value(1,true) #Player
	body.set_collision_layer_value(2,true)	#Dreamkin
	body.set_collision_layer_value(9,true) #Ghosting
