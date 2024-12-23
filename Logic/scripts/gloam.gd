extends Node3D

@export var encounter_rate : float = 10.0

@export var encounter_pool : Array = [
	{
		"weight" : 0.5,
		"result" : Glossary.encounter["gloamling_trio"]
	},
	{
		"weight" : 0.5,
		"result" : Glossary.encounter["gloamling_duo"]
	},
]

@onready var my_area : Area3D = $Area3D
@onready var my_body : StaticBody3D = $StaticBody3D
@onready var my_fog : FogVolume = $FogVolume

func _ready() -> void:
	my_area.body_entered.connect(_on_body_entered)
	my_area.body_exited.connect(_on_body_exited)
	
func _on_body_entered(body : Node3D):
	pass

func _on_body_exited(body : Node3D):
	pass
