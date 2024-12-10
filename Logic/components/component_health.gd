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

func change(amt : int, from_tether : bool = false, type : Dictionary = {}):
	
	var old_health = health
	
	## Healing
	if amt > 0:
		Glossary.create_text_particle(owner.animations.selector_anchor,str(amt),"float_away",Color.GREEN)
	## Damage
	elif amt < 0:
		Glossary.create_text_particle(owner.animations.selector_anchor,str(amt),"float_away",Color.RED)
		#To protect recursive when using heartstitch
		if !from_tether:
			Events.battle_entity_damaged.emit(owner,amt)
	
	health = clamp(health + amt,0,max_health)
	
	print_debug(old_health," HP -> ",health," HP")
	
	##Death handling
	if health == 0: #If we're dying
		##Query our death protection statuses to see if any want to intervene with a message before we die
		var death_protection_result = owner.my_component_ability.my_status.status_event("on_death_protection",[amt,from_tether,type],true)
		
		##If they do, ignore our normal death process and have the status fx handle it
		if death_protection_result.size() == 0:
			owner.animations.tree.get("parameters/playback").travel("Death") #queue us for death
		
	elif amt < 0:
		owner.state_chart.send_event("on_hurt")
	
	
	

	
	
