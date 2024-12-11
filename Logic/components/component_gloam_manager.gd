extends Node3D

var range : int
var light_strength : float = 2
var is_inside_gloam : bool = false

@onready var area = $Area3D
@onready var gleam = $FogVolume
@onready var light = $OmniLight3D

@export var equipment : component_equipment

func _ready() -> void:
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)

## What happens when we enter fog
# Auto-equip our loomlight if we have one
func _on_area_entered(area : Area3D):
	
	is_inside_gloam = true
	
	# Verify we have a loomlight and it can be equipped
	if equipment.ability_event(equipment.loomlight,"verify_equip"):
		equipment.ability_switch_active(equipment.loomlight)

## What happens when we exit fog
func _on_area_exited(area : Area3D):
	is_inside_gloam = false
