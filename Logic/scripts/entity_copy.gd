extends CharacterBody3D

#Dreamkin + Player
@export var my_battle_gui : Control
@export var my_component_input_controller : Node
#Statecharts
@export var state_chart : StateChart
@onready var state_init_override = null
#Animations
@export var animations : Node3D
#Collision Box
@export var collider : CollisionShape3D
#Status HUD
@export var status_hud : Node3D
#Battle entity
@export var my_component_health: component_health
@export var my_component_vis: component_vis
@export var my_component_ability: component_ability
@export var my_component_state_controller_battle: component_state_controller_battle
#Default stats
@export var stats : Dictionary = {
	"alignment" : Battle.alignment.FRIENDS, #Side of the field I will fight on
	"classification" : Battle.classification.PLAYER, #Grouping I am in
	"glossary" : "player", #Exact unit category I was spawned from
	"spacing" : Vector3(0,0,0) #spacing when unit is spawned in battle
}
#Core
@export var my_component_core : Node

func _ready() -> void:
	animations.tree.active = true
	if my_component_core:
		my_component_core.initialize()
