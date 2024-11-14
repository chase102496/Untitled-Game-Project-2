class_name world_entity_default
extends CharacterBody3D

@export_group("Modules")
@export var state_chart : StateChart
@export var animations : Node3D
@export var collider : CollisionShape3D

@export_group("Components")
@export var my_component_health: component_health
@export var my_component_vis: component_vis
#@export var my_component_ability: component_ability TODO
@export var my_component_state_controller_world: component_state_controller_world

#@export_group("Stats")
#@export var stats : Dictionary = {
	#"alignment" : "", #Side of the field I will fight on
	#"classification" : "", #Grouping I am in
	#"glossary" : "", #Exact unit category I was spawned from
	#"spacing" : Vector3(0.8,0,-0.1) #spacing when unit is spawned in battle
#}

@onready var state_init_override = null
