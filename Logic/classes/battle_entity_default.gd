class_name battle_entity_default
extends CharacterBody3D

@export_group("Modules")
@export var state_chart : StateChart
@export var animations : Node3D
@export var collider : CollisionShape3D

@export_group("Components")

@export var my_component_health: component_health
@export var my_component_vis: component_vis
@export var my_component_ability: component_ability
@export var my_component_state_controller_battle: component_state_controller_battle

@export_group("Other")
@export var alignment : String
@export var classification : String
@export var glossary : String
@export var spacing := Vector3(0.6,0,-0.1)

@onready var state_init_override = null