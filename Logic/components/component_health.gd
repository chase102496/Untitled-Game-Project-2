class_name component_health
extends component_node

signal health_changed(amt : int)

@export var max_health : int = 6
@export var status_hud : Node3D

var health : int:
	set(value):
		health = value
		_update(value)

func _ready() -> void:
	if !health: #If we didn't set health manually
		health = max_health
	_update(0)

## For calcs
func get_current_ratio() -> float:
	return float(health)/float(max_health)

## Local and global emission of health changed event
func _update(amt : int) -> void:
	health_changed.emit(amt)
	Events.entity_health_changed.emit(owner,amt)

func revive():
	
	Glossary.create_text_particle(owner.animations.selector_anchor,str("Revived!"),"float_away",Color.GREEN_YELLOW)
	
	#Events.battle_entity_revived.emit(owner)
	health = max_health

func change(amt : int, from_tether : bool = false, type : Dictionary = {}):
	
	var old_health = health
	
	## Healing
	if amt > 0:
		Glossary.create_text_particle(owner.animations.selector_anchor,str(amt),"float_away",Color.LIGHT_GREEN)
	## Damage
	elif amt < 0:
		Glossary.create_text_particle(owner.animations.selector_anchor,str(amt),"float_away",Color.RED)
		#To protect recursive when using heartlink
		if !from_tether:
			Events.battle_entity_damaged.emit(owner,amt)
	
	health = clamp(health + amt,0,max_health)
	
	Debug.message([old_health," HP -> ",health," HP"],Debug.msg_category.BATTLE)
	
	##Death handling
	if health == 0: #If we're dying
		##Query our death protection statuses to see if any want to intervene with a message before we die
		var death_protection_result = owner.my_component_ability.my_status.status_event("on_death_protection",[amt,from_tether,type],true)
		
		##If they do, ignore our normal death process and have the status fx handle it
		if death_protection_result.size() == 0:
			owner.animations.tree.get("parameters/playback").travel("Death") #queue us for death
		
	elif amt < 0:
		if owner.state_chart.get_current_state() == "Hurt":
			owner.animations.tree.get("parameters/playback").travel("Hurt")
		else:
			owner.state_chart.send_event("on_hurt")
	
	_update(amt)
	
	
	

	
	
