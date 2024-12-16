extends Node3D

var is_inside_gloam : bool = false
var current_gloam_cloud : Node

@onready var my_area : Area3D = $Area3D
@onready var my_fog : FogVolume = $FogVolume
@onready var light : OmniLight3D = $OmniLight3D
@onready var fog_strength : float = $FogVolume.material.density

@export var equipment : component_equipment
@export var clearing_strength : float = 1

func _ready() -> void:
	my_area.area_entered.connect(_on_area_entered)
	my_area.area_exited.connect(_on_area_exited)

## What happens when we enter fog
# Auto-equip our loomlight if we have one
func _on_area_entered(area : Area3D):
	
	is_inside_gloam = true
	current_gloam_cloud = area.owner
	$FogVolume.material.density = -(current_gloam_cloud.my_fog.material.get_shader_parameter("density") + clearing_strength)
	
	# Verify we have a loomlight and it can be equipped
	if equipment.ability_event(equipment.loomlight,"verify_equip"):
		equipment.ability_switch_active(equipment.loomlight)

## What happens when we exit fog
func _on_area_exited(area : Area3D):
	is_inside_gloam = false
	current_gloam_cloud = null
