class_name component_health
extends Node

@export var max_health : int = 6
var health : int

func _ready() -> void:
	health = max_health

func damage(amt,type : Dictionary = Global.type.NEUTRAL):
	
	if amt != 0:
		match type:
			Global.type.VOID:
				pass
				#do void damage
			Global.type.NEUTRAL:
				print_debug(health," HP -> ",health - amt," HP")
				health -= amt
				
				if health <= 0:
					owner.state_chart.send_event("on_death")
				else:
					owner.state_chart.send_event("on_hurt")
