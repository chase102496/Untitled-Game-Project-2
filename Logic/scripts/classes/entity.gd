class_name entity
extends CharacterBody3D

@export_group("Modules")
@export var my_battle_gui : Control
@export var state_chart : StateChart
@export var animations : Node3D
@export var collider : CollisionShape3D
@export var status_hud : Node3D

@export_group("Components")
@export var my_component_input_controller : Node
@export var my_component_health: component_health
@export var my_component_vis: component_vis
@export var my_component_ability: component_ability
@export var my_component_state_controller_battle: component_state_controller_battle

@export_group("Stats")
@export var stats : Dictionary = {
	"alignment" : "", #Side of the field I will fight on
	"classification" : "", #Grouping I am in
	"glossary" : "", #Exact unit category I was spawned from
	"spacing" : Vector3(0.8,0,-0.1) #spacing when unit is spawned in battle
}

@onready var state_init_override = null
