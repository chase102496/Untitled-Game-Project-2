class_name component_health
extends Node

@export var max_health : int = 6
var health : int
var previous_particle : Node

func _ready() -> void:
	health = max_health

func revive():
	
	Glossary.create_text_particle(owner,owner.animations.sprite.global_position,str("Revived!"),"float_away",Color.GREEN_YELLOW)
	
	#Events.battle_entity_revived.emit(owner)
	health = max_health

#func heal(amt : int):
	#Events.battle_entity_healed.emit(owner,amt)

func damage(amt : int, mirror_damage : bool = false, type : Dictionary = Battle.type.NEUTRAL):
	
	if health > 0:
		Glossary.create_text_particle(owner,owner.animations.sprite.global_position,str(amt),"float_away",Color.INDIAN_RED)
		
		if amt != 0:
			
			if !mirror_damage: #To protect recursive when using heartstitch
				Events.battle_entity_damaged.emit(owner,amt)
			match type:
				Battle.type.VOID:
					print_debug(health," HP -> ",health - amt," HP")
					health -= amt
				Battle.type.NEUTRAL:
					print_debug(health," HP -> ",health - amt," HP")
					health -= amt
				Battle.type.NOVA:
					print_debug(health," HP -> ",health - amt," HP")
					health -= amt
			
			if health <= 0: #If we're dying
				var death_protection_result = owner.my_component_ability.current_status_effects.status_event("on_death_protection",[amt,mirror_damage,type],true)
				if len(death_protection_result) > 0: #If we have any death protection events
					pass #ignore normal death process
				else: #normal death process
					owner.animations.tree.get("parameters/playback").travel("Death") #queue us for death
			else:
				owner.state_chart.send_event("on_hurt")
	else: #if we're already dead
		pass
