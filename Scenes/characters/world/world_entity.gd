class_name world_entity
extends Entity

@export_group("Modules")
@export var state_chart : StateChart
@export var collider : CollisionShape3D

@export_group("Components")

@export var animations : Node3D #TODO Refactor name in code to my_component_animation
@export var my_component_health : component_health
@export var my_component_vis : component_vis
@export var my_component_physics : component_physics

@export var my_component_state_controller_world: component_state_controller_world

@export_group("Other")
@export_enum("FRIENDS","FOES") var alignment : String
@export_enum("PLAYER","DREAMKIN","ENEMY") var classification : String

## Default icon for entities
@onready var glossary : String = Global.get_glossary_nickname(self)
@onready var unique_id : int = Glossary.get_unique_id()
