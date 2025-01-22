class_name component_health
extends component_node

signal health_changed(amt : int)

@export var max_health : int = 24
## Subtracts damage on-hit
@export var armor : int = 0
## Subtracts damage on-hit and disappears after blocking
@export var temporary_armor : int = 0
## When we successfully block, how much damage do we negate?
@export var block_power : int = 1
## Super-temporary armor that resets every attack
var block_armor : int = 0

var health : int:
	set(value):
		var old_health = health
		health = value
		var new_health = health
		_update(new_health - old_health)

func _ready() -> void:
	
	Events.turn_start.connect(_on_turn_start)
	
	if !health: #If we didn't set health manually
		health = max_health
	_update(0)

## Private

func _on_turn_start() -> void:
	_reset_armor_block()

## For calcs
func get_current_ratio() -> float:
	return float(health)/float(max_health)

## Local and global emission of health changed event
func _update(amt : int) -> void:
	health_changed.emit(amt)
	Events.entity_health_changed.emit(owner,amt)

func _reset_armor_block() -> void:
	block_armor = 0

func _on_dying(result : Array) -> void:
	owner.state_chart.send_event("on_dying")

func _on_hurt() -> void:
	## If already in hurt state
	#if owner.state_chart.get_current_state() == "Hurt":
		#owner.animations.tree.set_state("Hurt")
	#else:
		#owner.state_chart.send_event("on_hurt")
		
	owner.state_chart.send_event("on_hurt")

## Public

func revive():
	
	Glossary.create_text_particle_queue(owner.animations.selector_center,str("Revived!"),"text_float_away",Color.GREEN_YELLOW,0.4)
	
	#Events.battle_entity_revived.emit(owner)
	health = max_health

## Permanent armor
func change_armor(amt : int) -> void:
	armor = max(0,armor + amt)

## Will stay until damage is dealt, then it is negated
func change_armor_temporary(amt : int) -> void:
	temporary_armor = max(0,temporary_armor + amt)

func change_armor_block(amt : int) -> void:
	block_armor = max(0,block_armor + amt)

# Abstract calculation function
func _calculate_health_change(amt: int) -> Dictionary:
	# Store old health for reference
	var old_health = health
	
	# Calculate post-mitigation values
	var amt_post_mitigation = amt
	var temporary_armor_used = 0
	
	if amt < 0:
		var amt_post_armor = min(0, amt + armor + block_armor)
		amt_post_mitigation = min(0, amt_post_armor + temporary_armor)
		temporary_armor_used = amt_post_armor - amt_post_mitigation
	
	# Clamp health to valid range
	var new_health = clamp(health + amt_post_mitigation, 0, max_health)
	var amt_changed = new_health - old_health
	
	# Return relevant data as a dictionary
	return {
		"old_health": old_health,
		"new_health": new_health,
		"amt_changed": amt_changed,
		"amt_post_mitigation": amt_post_mitigation,
		"temporary_armor_used": temporary_armor_used
	}

# Main change function
func change(amt: int, from_tether: bool = false, display: bool = true):
	# Perform the health calculation
	var calc = _calculate_health_change(amt)
	
	# Update health and temporary armor
	health = calc["new_health"]
	if amt < 0:
		change_armor_temporary(calc["temporary_armor_used"])
	
	# Debugging output
	Debug.message([
		calc["old_health"], " HP -> ", health, " HP  Pre-mitigation: ", amt, 
		" Post-mitigation: ", calc["amt_post_mitigation"]
	], Debug.msg_category.BATTLE)
	
	### --- Consequences --- ###
	
	# Healing
	if calc["amt_changed"] > 0:
		if display:
			Glossary.create_text_particle(owner.animations.selector_center, str(abs(calc["amt_changed"])), "text_float_heart")
	
	# No damage (e.g. fully blocked)
	elif calc["amt_changed"] == 0:
		if display:
			Glossary.create_fx_particle_custom(owner, "star_explosion", true, 10, 180, 4, Vector3.ZERO, Color.WHITE)
	
	# Taking damage
	elif calc["amt_changed"] < 0:
		if display:
			Glossary.create_text_particle(owner.animations.selector_center, str(abs(calc["amt_changed"])), "text_float_star")
			Glossary.create_fx_particle_custom(owner.animations.selector_center, "star_explosion", true, 10, 180, 3, Vector3.ZERO, Global.palette["Icterine"])
			Camera.shake()
		
		# Avoid recursion
		if !from_tether:
			Events.battle_entity_damaged.emit(owner, calc["amt_changed"])
		
		# Check for death
		if health == 0:
			var death_protection_result = owner.my_component_ability.my_status.status_event("on_death_protection", [calc["amt_post_mitigation"], from_tether], true)
			if death_protection_result.is_empty():
				Glossary.create_icon_particle(owner.animations.selector_center,"status_death","icon_float_away",Color.WHEAT,1,true,Vector3.ZERO,3)
				Glossary.create_fx_particle_custom(owner.animations.selector_center, "star_explosion", true, 10, 180, 5, Vector3.ZERO, Global.palette["Icterine"])
				_on_dying(death_protection_result)
			else:
				Glossary.create_text_particle_queue(owner.animations.selector_center, "Death Protection!")
				Debug.message("Death Protection Activated!", Debug.msg_category.BATTLE)
		else:
			_on_hurt()
