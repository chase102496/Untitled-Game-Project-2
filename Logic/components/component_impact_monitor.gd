@icon("res://Art/icons/node icons/node_3D/icon_area_meteo.png")

class_name component_impact_monitor
extends Area3D

## What speed of velocity_length() do we trigger this monitor?
@export var velocity_thereshold : float = 18
## If stopped after reaching the velocity threshold, the object regains its previous velocity, useful for breaking objects after hitting static bodies.
@export var preserve_velocity_on_impact : bool = true

signal body_impacted(body : Node3D, vel : Vector3)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node3D) -> void:
	
	
	
	var velocity_history_reversed = body.my_component_physics.get_velocity_history(15).duplicate()
	velocity_history_reversed.reverse()
	
	for vel in velocity_history_reversed:
		if vel.length() > velocity_thereshold:
			if preserve_velocity_on_impact:
				body.velocity = vel
			body_impacted.emit(body,vel)
			Debug.message(["Impact thereshold met: ",vel.length()],Debug.msg_category.PHYSICS)
			Glossary.create_fx_particle_custom(owner,"dust",true,200,120,vel.length()*0.5,body.velocity.normalized(),Global.palette["Oxford Blue"])
			break
