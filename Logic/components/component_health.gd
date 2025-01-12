class_name component_health
extends component_node

signal health_changed(amt : int)

@export var max_health : int = 24
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
	
	## Calculation
	var old_health = health
	health = clamp(health + amt,0,max_health)
	var amt_changed = health - old_health
	
	Debug.message([old_health," HP -> ",health," HP"],Debug.msg_category.BATTLE)
	
	## Healing
	if amt_changed > 0:
		Glossary.create_text_particle(owner.animations.selector_anchor,str(amt),"float_away",Color.LIGHT_GREEN)
	
	## Damage
	elif amt_changed < 0:
		Glossary.create_text_particle(owner.animations.selector_anchor,str(amt),"float_away",Color.RED)
		#To protect recursive when using heartsurge
		if !from_tether:
			Events.battle_entity_damaged.emit(owner,amt)

		## We are dying
		if health == 0: #If we're dying
			var death_protection_result = owner.my_component_ability.my_status.status_event("on_death_protection",[amt,from_tether,type],true)
			if death_protection_result.is_empty():
				_on_dying(death_protection_result)
			## This means the code will be handled in status effect preventing death or modifying it in some way
			else:
				pass
		## We are getting hurt by something
		else:
			_on_hurt()
	
	## Updates the actual health change
	_update(amt_changed)

func _on_dying(result : Array) -> void:
	owner.state_chart.send_event("on_dying")

func _on_hurt() -> void:
	## If already in hurt state
	#if owner.state_chart.get_current_state() == "Hurt":
		#owner.animations.tree.set_state("Hurt")
	#else:
		#owner.state_chart.send_event("on_hurt")
		
	owner.state_chart.send_event("on_hurt")
