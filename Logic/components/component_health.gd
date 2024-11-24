class_name component_health
extends Node

@export var max_health : int = 6
var health : int
var previous_particle : Node

func _ready() -> void:
	health = max_health

func revive():
	
	Glossary.create_text_particle(owner.animations.selector_anchor,str("Revived!"),"float_away",Color.GREEN_YELLOW)
	
	#Events.battle_entity_revived.emit(owner)
	health = max_health

#func heal(amt : int):
	#Events.battle_entity_healed.emit(owner,amt)

func damage(amt : float, mirror_damage : bool = false, type : Dictionary = Battle.type.BALANCE):
	
	var amt_rounded = int(round(amt))
	
	##Damage handling
	if health > 0:
		
		Glossary.create_text_particle(owner.animations.selector_anchor,str(amt_rounded),"float_away",Color.INDIAN_RED)
		
		if amt != 0:
			
			var old_health = health
			
			##Apply damage
			health -= amt_rounded
			health = clamp(health,0,max_health)
			
			if !mirror_damage: #To protect recursive when using heartstitch
				Events.battle_entity_damaged.emit(owner,amt_rounded)
			
			print_debug(old_health," HP -> ",health," HP")
			
		##Death handling
		if health == 0: #If we're dying
			
			##Query our death protection statuses to see if any want to intervene with a message before we die
			var death_protection_result = owner.my_component_ability.current_status_effects.status_event("on_death_protection",[amt_rounded,mirror_damage,type],true)
			
			##If they do, ignore our normal death process and have the status fx handle it
			if death_protection_result.size() > 0:
				pass
			##If they don't, just send us to death state
			else:
				owner.animations.tree.get("parameters/playback").travel("Death") #queue us for death
		else:
			
			owner.state_chart.send_event("on_hurt")
		
	else: #if we're already dead and damage is trying to get to us
		pass #ignore damage
	

	
