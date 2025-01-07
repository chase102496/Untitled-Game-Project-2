class_name component_gloam_manager
extends component_node_3d

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

## Abstractions

func reset_encounter_progress(val : float = 0.0) -> void:
	encounter_rate = val

func set_vignette_opacity(val : float) -> void:
	owner.my_vignette.get_child(0).material.set_shader_parameter("MainAlpha",val)

func is_inside_gloam() -> bool:
	if state_chart.get_current_state() == "Outside":
		return false
	elif state_chart.get_current_state() == "Inside":
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
	var tween = create_tween()
	tween.tween_method(set_vignette_opacity, 0.1, 0.0, 1.0)
	reset_encounter_progress()
	
func on_state_entered_inside() -> void:
	var tween = create_tween()
	tween.tween_method(set_vignette_opacity, 0.0, 0.1, 1.0)
	
	# Verify we have a loomlight and it can be equipped
	if equipment.ability_event(equipment.loomlight,"verify_equip"):
		equipment.switch_active(equipment.loomlight)

var encounter_rate : float = 0.0
var max_encounter_rate : float = 100.0 #Point at which encounter is triggered
var encounter_rate_randomness : float #Runtime-decided percentage that makes progress semi-random (0.0 to 1.0)

var vignette_rate_start : float = 1.0
var vignette_rate_end : float = 0.5

@export var encounter_rate_base : float = 20.5 #Max rate at which we accumulate encounter progress per second
@export var encounter_pool : Array = [ #Pool of possible encounters and their weights
		{
			"weight" : 0.5,
			"result" : Glossary.encounter["gloamling_trio"]
		},
		{
			"weight" : 0.5,
			"result" : Glossary.encounter["gloamling_duo"]
		},
]

## Runs when inside the fog
func on_state_physics_processing_inside(delta : float) -> void:
	
	## So we can disable encounters when debugging
	if !Debug.enabled:
		## If moving or at 90% of encounter, progress encounter rate
		if owner.velocity.x != 0 or owner.velocity.z != 0 or encounter_rate/max_encounter_rate > 0.9:
			encounter_rate_randomness = randf_range(0,1)
			var result = encounter_rate_randomness * encounter_rate_base
			encounter_rate = clamp(encounter_rate + (result * delta), 0, max_encounter_rate)
			#Debug.message([encounter_rate,"/",max_encounter_rate]) #TODO weird edge case
		
		##Check new encounter progress
		#Flickering? Maybe for certain milestones like 50% or 90%? Or for special encounters?
		#Fog thickens?
		#Vignette?
		owner.my_vignette.get_child(0).material.set_shader_parameter("outerRadius",vignette_rate_start - (encounter_rate/max_encounter_rate))
		
		if encounter_rate == max_encounter_rate:
			Battle.battle_initialize_verbose(Global.pick_weighted(encounter_pool))
			state_chart.send_event("on_outside")
	
	## Negates the current gloam cloud by its exact amount. Negative clearing strength makes the clearing weaker, and vice versa
	fog_strength = -(current_gloam_cloud.my_fog.material.get_shader_parameter("density") + clearing_strength)
	
	
