class_name world_entity
extends CharacterBody3D

@export_group("Modules")
@export var state_chart : StateChart
@export var collider : CollisionShape3D

@export_group("Components")

@export var animations : Node3D #TODO Refactor name in code to my_component_animation
@export var my_component_health: component_health
@export var my_component_vis: component_vis

@export var my_component_state_controller_world: component_state_controller_world

@export_group("Other")
@export_enum("FRIENDS","FOES") var alignment : String
@export_enum("PLAYER","DREAMKIN","ENEMY") var classification : String


@onready var glossary : String = Global.get_glossary_nickname(self)
@onready var unique_id : int = Glossary.get_unique_id()

func _enter_tree() -> void:
	name = str(name," ",randi_range(0,99))
