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

@export_group("Other")
@export var alignment : String
@export var classification : String
#@export var glossary : String
@export var spacing := Vector3(0.8,0,-0.1)

@onready var glossary : String = Global.get_glossary_nickname(self)
@onready var unique_id : int = Glossary.get_unique_id()
