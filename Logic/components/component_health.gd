class_name component_health
extends Node

@export var max_health : int = 6
var health : int

func _ready() -> void:
	health = max_health

func damage(amt, mirror_damage : bool = false, type : Dictionary = Battle.type.NEUTRAL,):
	
	if amt != 0:
		if !mirror_damage: #To protect recursive when using heartstitch
			Events.battle_entity_damaged.emit(owner,amt)
		match type:
			Battle.type.VOID:
				#Send signal out that we recieved damage, who we are, and how much
				print_debug(health," HP -> ",health - amt," HP")
				health -= amt
				
				if health <= 0:
					owner.state_chart.send_event("on_death")
				else:
					owner.state_chart.send_event("on_hurt")
			Battle.type.NEUTRAL:
				print_debug(health," HP -> ",health - amt," HP")
				health -= amt
				
				if health <= 0:
					owner.state_chart.send_event("on_death")
				else:
					owner.state_chart.send_event("on_hurt")
			Battle.type.NOVA:
				print_debug(health," HP -> ",health - amt," HP")
				health -= amt
				
				if health <= 0:
					owner.state_chart.send_event("on_death")
				else:
					owner.state_chart.send_event("on_hurt")
