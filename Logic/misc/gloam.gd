extends Node3D

## If plugged in, will respond to impulses by deactivating
@export var impulse_parent : component_impulse

## Once activated, stays that way permanently until reset
@export var one_way : bool = false

@export var encounter_rate : float = 10.0

@export var encounter_pool : Array[Dictionary] = [
	{
		"weight" : 0.2,
		"result" : Glossary.encounter["gloamling_trio"]
	},
	{
		"weight" : 0.8,
		"result" : Glossary.encounter["gloamling_duo"]
	},
]

@onready var my_area : Area3D = $Area3D
@onready var my_body : StaticBody3D = $StaticBody3D
@onready var my_fog : FogVolume = $FogVolume

func _ready() -> void:
	
	if impulse_parent:
		impulse_parent.activated.connect(_on_impulse_parent_activated)
		impulse_parent.deactivated.connect(_on_impulse_parent_deactivated)

func _enable() -> void:
	pass

func _disable() -> void:
	pass

func _on_impulse_parent_activated() -> void:
	_enable()

func _on_impulse_parent_deactivated() -> void:
	_disable()
