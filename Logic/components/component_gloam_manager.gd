class_name component_gloam_manager
extends Node3D

var current_gloam_cloud : Node

@onready var my_area : Area3D = $Area3D
@onready var my_fog : FogVolume = $FogVolume
@onready var light : OmniLight3D = $OmniLight3D
@onready var fog_strength : float = $FogVolume.material.density
@onready var state_chart : StateChart = $StateChart

@export var equipment : component_equipment

## How much by default our loomlight clears, 0 for as much as necessary
var clearing_strength : float = 0

func _ready() -> void:
	
	my_area.area_entered.connect(_on_area_entered)
	my_area.area_exited.connect(_on_area_exited)
	
	$StateChart/CompoundState/Outside.state_entered.connect(on_state_entered_outside)
	$StateChart/CompoundState/Inside.state_entered.connect(on_state_entered_inside)
	$StateChart/CompoundState/Inside.state_physics_processing.connect(on_state_physics_processing_inside)

func is_inside_gloam() -> bool:
	if state_chart.get_current_state() == "outside":
		return false
	elif state_chart.get_current_state() == "inside":
		return true
	else:
		push_error("Unknown state for gloam manager")
		return false

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
	#is_inside_gloam = false
	pass
	
func on_state_entered_inside() -> void:
	#is_inside_gloam = true
	pass
	
	# Verify we have a loomlight and it can be equipped
	if equipment.ability_event(equipment.loomlight,"verify_equip"):
		equipment.ability_switch_active(equipment.loomlight)


## Runs when inside the fog
func on_state_physics_processing_inside(delta : float) -> void:
	
	#delta * x is x per second
	#so if we add 1 resource to encounter meter * delta
	#after 1 second, we will have 1 resource
	
	# encounter_rate : float = 1.0 this is the base encounter buildup, defined by the gloam cloud
	# max_encounter_rate : float = 100 this is the value when we trigger an encounter
	# encounter_rate_randomness : float 
	# encounter_pool : Dictionary {
	# 0.5 : Glossary.encounter["gloamling_trio"]
	#} This is a list of things that happen, with weights for each, when encounter is full
	
	# encounter_rate_randomness = randf_range(0,1)
	# encounter_rate * encounter_rate_randomness * delta
	
	## Negates the current gloam cloud by its exact amount. Negative clearing strength makes the clearing weaker, and vice versa
	fog_strength = -(current_gloam_cloud.my_fog.material.get_shader_parameter("density") + clearing_strength)
	
	
