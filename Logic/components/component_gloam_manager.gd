class_name component_gloam_manager
extends Node3D

var is_inside_gloam : bool = false
var current_gloam_cloud : Node

@onready var my_area : Area3D = $Area3D
@onready var my_fog : FogVolume = $FogVolume
@onready var light : OmniLight3D = $OmniLight3D
@onready var fog_strength : float = $FogVolume.material.density
@onready var state_chart : StateChart = $StateChart

@export var equipment : component_equipment
@export var clearing_strength : float = 0
@export var max_clearing_strength : float

func _ready() -> void:
	
	max_clearing_strength = clearing_strength
	
	my_area.area_entered.connect(_on_area_entered)
	my_area.area_exited.connect(_on_area_exited)
	
	$StateChart/CompoundState/Outside.state_entered.connect(on_state_entered_outside)
	$StateChart/CompoundState/Inside.state_entered.connect(on_state_entered_inside)
	$StateChart/CompoundState/Inside.state_physics_processing.connect(on_state_physics_processing_inside)

## What happens when we enter fog
# Auto-equip our loomlight if we have one
func _on_area_entered(area : Area3D):
	current_gloam_cloud = area.owner
	state_chart.send_event("on_inside")
## What happens when we exit fog
func _on_area_exited(area : Area3D):
	current_gloam_cloud = null
	state_chart.send_event("on_outside")

## --- State Charts --- ##

func on_state_entered_outside() -> void:
	is_inside_gloam = false
	
func on_state_entered_inside() -> void:
	is_inside_gloam = true
	
	# Adjust fog removal to be relative to the cloud (So we can always see no matter the density of it)
	
	
	# Verify we have a loomlight and it can be equipped
	if equipment.ability_event(equipment.loomlight,"verify_equip"):
		equipment.ability_switch_active(equipment.loomlight)

func on_state_physics_processing_inside(delta : float) -> void:
	
	#delta is 1 per second
	#so if we add 1 resource to encounter meter * delta
	#after 1 second, we will have 1 resource
	
	# encounter_rate_base : float = 1.0
	# encounter_rate_modifier : float = 0.0
	# encounter_pool : 
	
	# encounter_rate_base * delta * encounter_rate_modifier
	# encounter_rate_modifier * randf_range(0,1)
	
	fog_strength = -(current_gloam_cloud.my_fog.material.get_shader_parameter("density") + clearing_strength)
	
	
