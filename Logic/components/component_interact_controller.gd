## Handles general interaction not reliant on equipment or really specific player parameters
## For things like opening other nodes like doors, talking to NPCs, etc
## This is the TRANSMITTER or HOST
## For recievers, like an NPC or a lever, use component_interact
class_name component_interact_controller
extends Node3D

@onready var active_interact_area : Area3D  = $active_interact_area
@onready var active_interact_area_shape : CollisionShape3D  = $active_interact_area/active_interact_area_shape

func _ready() -> void:
	active_interact_area.area_entered.connect(_on_active_interact_area_entered)
	active_interact_area.area_exited.connect(_on_active_interact_area_exited)

func _on_active_interact_area_entered(area : Area3D) -> void:
	pass

func _on_active_interact_area_exited(area : Area3D) -> void:
	pass
