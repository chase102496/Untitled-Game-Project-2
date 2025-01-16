class_name component_health
extends component_node

signal health_changed(amt : int)

@export var max_health : int = 24
@export var status_hud : Node3D
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
		health = value
		_update(value)

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
	
	Glossary.create_text_particle_queue(owner.animations.selector_anchor,str("Revived!"),"text_float_away",Color.GREEN_YELLOW,0.4)
	
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

func change(amt : int, from_tether : bool = false, display : bool = true):
	
	## Calculation
	var old_health = health
	
	var amt_post_mitigation = amt
	if amt < 0:
		var amt_post_armor = min(0, amt + armor + block_armor)
		amt_post_mitigation = min(0, amt_post_armor + temporary_armor)
		var temporary_armor_used = amt_post_armor - amt_post_mitigation
		change_armor_temporary(temporary_armor_used)
	
	health = clamp(health + amt_post_mitigation,0,max_health)
	
	var amt_changed = health - old_health
	
	Debug.message([old_health," HP -> ",health," HP  Pre-mitigation: ",amt," Post-mitigation: ",amt_post_mitigation],Debug.msg_category.BATTLE)
	
	## Healing
	if amt_changed > 0:
		if display: #TBD Need to make an icon for this too
			Glossary.create_text_particle(owner.animations.selector_anchor,str(abs(amt_changed)),"text_float_heart")
			# Some health particle fx
	
	## Damage
	elif amt_changed == 0:
		if display:
			Glossary.create_fx_particle_custom(owner,"star_explosion",true,10,180,4,180,Color.WHITE)
	
	elif amt_changed < 0:
		if display:
			Glossary.create_text_particle(owner.animations.selector_anchor,str(abs(amt_changed)),"text_float_star")
			Glossary.create_fx_particle_custom(owner.animations.selector_anchor,"star_explosion",true,10,180,3,180,Color.YELLOW)
			Camera.shake()
		#To protect recursive when using heartsurge
		if !from_tether:
			Events.battle_entity_damaged.emit(owner,amt_changed)

		## We are dying
		if health == 0: #If we're dying
			var death_protection_result = owner.my_component_ability.my_status.status_event("on_death_protection",[amt_post_mitigation,from_tether],true)
			if death_protection_result.is_empty():
				Glossary.create_text_particle_queue(owner.animations.selector_anchor,"KO!")
				Glossary.create_fx_particle_custom(owner.animations.selector_anchor,"star_explosion",true,10,180,5,180,Color.YELLOW)
				_on_dying(death_protection_result)
			## This means the code will be handled in status effect preventing death or modifying it in some way
			else:
				Glossary.create_text_particle_queue(owner.animations.selector_anchor,"Death Protection!")
				Debug.message("Death Protection Activated!",Debug.msg_category.BATTLE)
		## We are getting hurt by something
		else:
			_on_hurt()
	
	## Updates the actual health change
	_update(amt_changed)
