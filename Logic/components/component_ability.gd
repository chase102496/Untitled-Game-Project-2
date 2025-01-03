class_name component_ability
extends Node

## For picking abilities and holding onto them for a bit
var cast_queue : ability = null

## Abilities
var my_abilities : Array = []
var max_ability_count : int = 4

## Status Effects
var my_status : status_manager = status_manager.new()

## Stats
var my_stats : stats_manager = stats_manager.new()

## Misc
var skillcheck_difficulty : float = 1.0 #DEPRECATED SOON

#------------------------------------------------------------------------------
#DONT use name or owner, already taken
#HACK _init is where you store stuff you'd only need way before battle, like damage, vis cost, etc

# - Classes - #

class stats_manager:
	var damage_multiplier : float = 1.0
	var damage_multiplier_base : float = 1.0
	var skillcheck_difficulty : float = 1.0
	
	func set_damage_multiplier_temp(ratio : float):
		damage_multiplier = ratio
	
	func reset_damage_multiplier_temp():
		damage_multiplier = damage_multiplier_base

class status_manager:

	var NORMAL #they can overwrite eachother based on priority. Only one at a time
	var TETHER #Primarily for Lumia's stitch mechanic
	var PASSIVE : Array = [] #Primarily for semi-permanent status effects that start at battle initialize and don't interact with NORMAL and TETHER
	
	func search_title(title_query : String): #Returns first result matching the title of the input, or null if no result TODO BROKEN
		if NORMAL and NORMAL.title == title_query:
			return NORMAL
		elif TETHER and TETHER.title == title_query:
			return TETHER
		elif len(PASSIVE) > 0:
			for i in len(PASSIVE):
				if PASSIVE[i].title == title_query:
					return PASSIVE
		else:
			return null
	
	func add_passive(effect : Object):
		PASSIVE.append(effect)
		effect.fx_add()
		Debug.message(["!passive added! - ",effect.title],Debug.msg_category.BATTLE)
		return PASSIVE[PASSIVE.find(effect)]
		
	func remove_passive(effect : Object) -> void:
		PASSIVE.pop_at(PASSIVE.find(effect))
		effect.fx_remove()
		Debug.message(["!passive removed! - ",effect.title],Debug.msg_category.BATTLE)
	
	#Normal add for NORMAL and TETHER
	func add(effect : Object, ignore_priorities : bool = false) -> Object:
		var effect_str = effect.category #NORMAL or TETHER
		var current_effect = get(effect_str)
		
		if !current_effect: #if there's no status effect
			set(effect_str,effect)
			effect.fx_add()
			Debug.message(["!status added! - ",effect.title],Debug.msg_category.BATTLE)
		elif current_effect.title == effect.title: #if they're the same status effect
				Debug.message(["!target status is equal to applied status! - ",effect.title],Debug.msg_category.BATTLE)
				match effect.behavior:
					Battle.status_behavior.STACK:
						current_effect.duration += effect.duration
						Debug.message(["!status duration increased! - ",effect.title],Debug.msg_category.BATTLE)
					Battle.status_behavior.RESET:
						remove(current_effect)
						set(effect_str,effect)
						effect.fx_add()
						Debug.message(["!status reapplied! - ",effect.title],Debug.msg_category.BATTLE)
					Battle.status_behavior.RESIST:
						Debug.message(["!status ignored! - ",effect.title],Debug.msg_category.BATTLE)
					_:
						push_error("ERROR, status behavior not found: ",effect.behavior,effect.title)
		elif ignore_priorities or current_effect.priority < effect.priority: #if our new status effect has higher priority or ignores prio
			remove(current_effect)
			set(effect_str,effect)
			effect.fx_add()
			Debug.message(["!status overwritten! - ",effect.title],Debug.msg_category.BATTLE)
			Debug.message(["ignore_priorities = ",ignore_priorities],Debug.msg_category.BATTLE)
		else:
			Debug.message(["!cannot overwrite current status effect! - ",effect.title],Debug.msg_category.BATTLE)
		
		return get(effect_str)
			
	#Normal remove for non-lists
	func remove(effect : Object) -> void:
		var effect_str = effect.category
		var current_effect = get(effect_str)
		
		if current_effect:
			effect.fx_remove()
			set(effect_str,null)
			Debug.message(["!status removed! - ",effect.title],Debug.msg_category.BATTLE)
		else:
			Debug.message(["!no status effect to remove! - ",effect.title],Debug.msg_category.BATTLE)

	func clear(clear_passive : bool = false) -> void:
		Debug.message(["!removed all status effects! - ",NORMAL,TETHER],Debug.msg_category.BATTLE)
		if NORMAL:
			remove(NORMAL)
		if TETHER:
			remove(TETHER)
		if clear_passive:
			for i in PASSIVE.size():
				remove_passive(PASSIVE[i])
	
	func status_event(event : String, args : Array = [], value_return : bool = false):
		var result_total : Array = []
		
		if NORMAL and NORMAL.has_method(event): #if it exists and has the method
			var result = Callable(NORMAL,event).callv(args) #call it, store the return
			if value_return and result: #if we want to return something, and it returns something
				result_total.append(result) #add it to the return list
		if TETHER and TETHER.has_method(event):
			var result = Callable(TETHER,event).callv(args)
			if value_return and result:
				result_total.append(result)
		for i in len(PASSIVE):
			if PASSIVE[i] and PASSIVE[i].has_method(event):
				var result = Callable(PASSIVE[i],event).callv(args)
				if value_return and result:
					result_total.append(result)
		
		return result_total #return any results

# - Status Effects - #
class status:
	var id : String
	var host : Node #The owner of the status effect. Who to apply it to
	var behavior : String = Battle.status_behavior.RESIST #How overwriting status fx works
	var category : String = Battle.status_category.NORMAL #NORMAL, TETHER, or PASSIVE
	var duration : int = 0 #How many turns it lasts
	var title : String = "---"
	var description : String = ""
	var fx : Node #Visual fx
	var priority : int = 0 #Whether a buff can overwrite it. Higher means it can
	var new_turn : bool #Whether we ran this once per turn already

	func set_data(new_metadata : Dictionary):
		for key in new_metadata:
			var value = new_metadata[key]
			set(key,value)
	
	func get_data_default():
		return {
			"id" : id,
			"title" : title,
			"category" : category,
			"behavior" : behavior,
			"duration" : duration,
			"description" : description
		}
	
	func get_data():
		return {}

	## If we only wanna run this once per turn. Used if we modify state of host somehow, so it doesn't forget it already ran us
	func once_per_turn():
		if new_turn:
			new_turn = false
			return true
		else:
			return false
	
	func _init(host : Node) -> void:
		self.host = host
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		return false #false means we don't fuck with mitigation for this status effect
	
	func on_start(): #runs on start of turn
		new_turn = true
	
	func on_skillcheck(): #runs right before skillcheck
		pass
	
	func on_end(): #runs on end of turn
		pass
	
	func on_expire(): #runs when status effect expires
		pass
	
	func on_death():
		pass
	
	func fx_add():
		pass
	
	func fx_remove():
		pass
# ---

class status_template_default:
	extends status
	
	func on_duration():
		duration -= 1
		if duration <= 0:
			on_expire()

	func on_expire():
		Debug.message([title," wore off for ",host.name,"!"],Debug.msg_category.BATTLE)
		host.my_component_ability.my_status.remove(self)
	
	func fx_add():
		host.animations.sprite.add_child(fx)
		fx.global_position = host.animations.sprite.global_position
	
	func fx_remove():
		fx.queue_free()
		fx = null

# NORMAL
class status_fear:
	extends status_template_default
	
	func get_data():
		return {}
	
	func _init(host : Node,duration : int = 2) -> void:
		#Defaults
		id = "status_fear"
		title = "Fear"
		description = "Causes the target to lose accuracy on attacks"
		self.host = host
		self.duration = duration
		fx = Glossary.particle.fear.instantiate()
	
	func on_skillcheck():
		host.my_component_ability.skillcheck_difficulty += 1

class status_burn:
	extends status_template_default
	
	func get_data():
		return {
		"damage" : damage,
		}
	
	var damage : int
	
	func _init(host : Node, duration : int = 2, damage : int = 1) -> void:
		#Defaults
		id = "status_burn"
		title = "Burn"
		description = "Inflicts damage on the target at the end of their turn"
		self.host = host
		self.duration = duration
		self.damage = damage
		fx = Glossary.particle.burn.instantiate()
	
	func on_end():
		if once_per_turn(): #If this is the first time applying this turn
			host.my_component_health.change(-damage)
			Debug.message(["Burn did ",damage," damage!"],Debug.msg_category.BATTLE)

class status_freeze:
	extends status_template_default
	
	func get_data():
		return {
		"siphon_amount" : siphon_amount,
		}
	
	var siphon_amount : int
	
	func _init(host : Node, duration : int = 2, siphon_amount : int = 1) -> void:
		#Defaults
		id = "status_freeze"
		title = "Freeze"
		description = "Creates a chasm of frost inside the target, sapping vis at the end of their turn"
		self.host = host
		self.duration = duration
		self.siphon_amount = siphon_amount
		fx = Glossary.particle.freeze.instantiate()
	
	func on_end():
		if once_per_turn(): #If this is the first time applying this turn
			host.my_component_vis.change(-siphon_amount)
			Debug.message([host," lost ",siphon_amount," vis from freeze!"],Debug.msg_category.BATTLE)

class status_disabled: #Disabled, unable to act, and immune to damage. Essentially dead but still on the battle field
	extends status_template_default
	
	func get_data():
		return {}
	
	func _init(host : Node, duration : int = 2) -> void:
		id = "status_disabled"
		title = "Disabled"
		description = "Completely disables the target, preventing them from getting attacked and also from attacking"
		self.host = host
		self.duration = duration
		priority = 999 #Nothing should overwrite us
		fx = Glossary.particle.disabled.instantiate()
	
	func on_start():
		host.state_chart.send_event("on_end") #skip our turn
		Debug.message([host.name," is disabled this turn"],Debug.msg_category.BATTLE)
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		Debug.message([entity_target.name," is immune to ",ability.title,"!"],Debug.msg_category.BATTLE)
		Glossary.create_text_particle(entity_target.animations.selector_anchor,str("Immune!"),"float_away")
		return Battle.mitigation_type.IMMUNE
	
	func on_expire():
		Debug.message([host.name," is no longer disabled!"],Debug.msg_category.BATTLE)
		host.my_component_ability.my_status.remove(self)
		Events.battle_entity_disabled_expire.emit(host) #Tell everyone our disable expired

# TETHER

class status_heartlink:
	extends status_template_default
	
	var partners : Array
	
	func _init(host : Node,partners : Array,duration : int) -> void:
		id = "status_heartlink"
		title = "Heartlink"
		description = "This target is sharing damage with another"
		self.host = host #who is the initial target of the link
		self.partners = partners #who is paired to the host
		self.duration = duration
		behavior = Battle.status_behavior.RESET
		category = Battle.status_category.TETHER
	
	func on_battle_entity_damaged(entity,amount): #the bread n butta of heartlink
		if entity == host and len(partners) > 1: #if person hurt was our host, and partners aint all ded
			for i in len(partners):
				if partners[i] != host and partners[i] in Battle.battle_list: #if it's not me and it's alive
					partners[i].my_component_health.change(amount,true)
					Debug.message([partners[i].name," took ",amount," points of mirror damage!"],Debug.msg_category.BATTLE)
	
	func fx_add():
		fx = Glossary.ui.heartlink.instantiate()
		host.animations.status_hud.grid.add_child(fx)
	
	func fx_remove():
		fx.queue_free()
		fx = null

# PASSIVE
#Basically the same thing but PRIORITY here works differently. It runs through them when checking things that stack like ability mitigation.
#the highest prio is checked first and if it finds something of interest it will handle it

class status_ethereal: #Immune to everything but one type
	extends status
	
	func get_data():
		return {
		"title" : title,
		"weakness" : weakness,
		}
	
	var weakness : Dictionary
	
	func _init(host : Node, weakness : Dictionary = Battle.type.CHAOS) -> void:
		id = "status_ethereal"
		title = "Ethereal"
		description = "This target is immune to all types of damage except one"
		self.host = host
		self.weakness = weakness
		category = Battle.status_category.PASSIVE
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		if ability.type != weakness:
			Debug.message([entity_target.name," is immune to ",ability.title,"!"],Debug.msg_category.BATTLE)
			Glossary.create_text_particle(entity_target.animations.selector_anchor,str("Immune!"),"float_away")
			return Battle.mitigation_type.IMMUNE #here we add a message saying we mitigated everything
		else: #battle mitigation ALWAYS needs an else statement to handle the ability normally
			return Battle.mitigation_type.PASS #here we add a message saying we didn't mitigate anything

class status_thorns:
	extends status
	
	func get_data():
		return {
		"title" : title,
		"damage" : damage,
		}
	
	var damage : int
	var reflect_target : Object = null
	
	func _init(host : Node,damage : int = 1) -> void:
		id = "status_thorns"
		title = "Thorns"
		description = "This target will reflect damage back to the attacker"
		self.host = host
		self.damage = damage
		category = Battle.status_category.PASSIVE
	
	func on_battle_entity_hit(entity_caster : Node, entity_targets : Array, ability : Object):
		if host in entity_targets and ability.primary_target == host: #If we're the primary target and but we're being attacked
			reflect_target = entity_caster
	
	func on_battle_entity_turn_end(entity : Node):
		if reflect_target:
			reflect_target.my_component_health.change(-damage)
			Debug.message([host.name," reflected ",damage," damage back to ",reflect_target.name,"!"],Debug.msg_category.BATTLE)
			reflect_target = null

class status_regrowth:
	extends status
	
	func get_data():
		return {
		}
	
	var death_protection_enabled : bool = false
	
	func _init(host : Node) -> void:
		id = "status_regrowth"
		title = "Regrowth"
		description = "This target will only die if all of its kind are killed alongside it"
		self.host = host
		category = Battle.status_category.PASSIVE
	
	func on_battle_entity_disabled_expire(entity : Node):
		if entity == host: #If we just got out of a disable
			if death_protection_enabled: #If we have death protection on
					host.my_component_health.revive() #Revive us
					death_protection_enabled = false
	
	func on_dying(): #We started the dying animation
		var paired_teammates = Battle.search_glossary_name(host.glossary,Battle.get_team(host.alignment),false) #pull all similar characters with our glossary name
		for i in len(paired_teammates):
			paired_teammates[i].my_component_ability.my_status.clear() #Clear status fx
			paired_teammates[i].animations.tree.get("parameters/playback").travel("Death") #Begin their death anim
	
	func on_death_protection(amt : int, mirror_damage : bool = false, type : Dictionary = Battle.type.BALANCE):
		var paired_teammates = Battle.search_glossary_name(host.glossary,Battle.get_team(host.alignment),false) #pull all similar characters with our glossary name
		var living_teammates = false
		
		for i in len(paired_teammates): #If we find a single teammate about 0 HP
			if paired_teammates[i].my_component_health.health > 0:
				living_teammates = true
		
		if living_teammates: #If we find ANY other matching teammate glossaries of us that are alive and not in disabled mode
			
			#if status_disabled not in host.my_component_ability.my_status.PASSIVE:
				#print("EEE") TODO
			
			if !death_protection_enabled: #If it hasn't already been triggered this death
				host.my_component_ability.my_status.clear() #Clear status fx first
				host.my_component_ability.my_status.add(status_disabled.new(host,2),true) #Then disable us
				death_protection_enabled = true #We are now in "incapacitated" mode
			return true #Always return true for letting health know we aren't dead yet

class status_immunity: #Creates a specific immunity where if it's matching the type, they are immune
	extends status
	
	func get_data():
		return {
		"immunity" : immunity
		}
	
	var immunity : Dictionary
	
	func _init(host : Node, immunity : Dictionary = Battle.type.BALANCE) -> void:
		id = "status_immunity"
		title = "Immunity"
		description = "This target is immune to an aspect"
		self.host = host
		self.immunity = immunity
		category = Battle.status_category.PASSIVE
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		if ability.type == immunity:
			Debug.message([entity_target.name," is immune to ",ability.title,"!"],Debug.msg_category.BATTLE)
			Glossary.create_text_particle(entity_target.animations.selector_anchor,str("Immune!"),"float_away")
			return Battle.mitigation_type.IMMUNE #here we add a message saying we mitigated everything
		else: #battle mitigation ALWAYS needs an else statement to handle the ability normally
			return Battle.mitigation_type.PASS #here we add a message saying we didn't mitigate anything

class status_weakness: #Creates a specific type that we look for to do bonus things when hit
	extends status
	
	func get_data():
		return {
		"weakness" : weakness
		}
	
	var weakness : Dictionary
	
	func _init(host : Node, weakness : Dictionary = Battle.type.BALANCE) -> void:
		id = "status_weakness"
		title = "Weakness"
		description = "This target is weak to an aspect"
		self.host = host
		self.weakness = weakness
		category = Battle.status_category.PASSIVE
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		if ability.type == weakness:
			Debug.message([entity_target.name," is weak to ",ability.title,"!"],Debug.msg_category.BATTLE)
			entity_caster.my_component_ability.cast_queue.cast_pre_mitigation_bonus(entity_caster,host)
			Glossary.create_text_particle(entity_target.animations.selector_anchor,str("Weakness!"),"float_away",Color.PURPLE,0.3)
			return Battle.mitigation_type.WEAK
		else:
			return Battle.mitigation_type.PASS

class status_swarm: #Adds a percent to our damage based on how many of us are on the field (besides us)
	extends status
	
	func get_data():
		return {
		"mult_percent" : mult_percent
		}
	
	var mult_total : float
	var mult_percent : float #This adds to host's damage multiplier so 0.1 would be 10% increased for every one of them on the field
	
	func _init(host : Node, mult_percent : int = 1) -> void:
		id = "status_swarm"
		title = "Swarm"
		description = "This target is doing damage based on how many of it are on the field"
		self.host = host
		self.mult_percent = mult_percent
		category = Battle.status_category.PASSIVE
	
	func on_start():
		var paired_teammates = Battle.search_glossary_name(host.glossary,Battle.get_team(host.alignment),false)
		mult_total = (len(paired_teammates) - 1)*mult_percent #teammates + mult percent for one teammate
		host.my_component_ability.my_stats.set_damage_multiplier_temp(mult_total)
	
	func on_end():
		host.my_component_ability.my_stats.reset_damage_multiplier_temp()

### --- Abilities --- ###

class ability:
	extends Node
	
	var id : String ##ID should match the class name
	var skillcheck_modifier : int = 1
	var caster : Node
	var primary_target : Node
	var targets : Array = []
	#Change this to a function (Callable type) that returns a list of whatever you want. Make the function in Battle
	var target_type : String = Battle.target_type.EVERYONE #Who we can target on the field
	var target_selector : Dictionary = Battle.target_selector.SINGLE #How many targets we select
	
	var title : String = "---"
	var type : Dictionary = Battle.type.EMPTY
	
	var damage : int = 0 #Base damage
	var vis_cost : int = 0
	var chance : float = 1.0 #Chance of something happening, kinda a placeholder
	var description : String = ""
	
	func set_data(new_metadata : Dictionary):
		for key in new_metadata:
			var value = new_metadata[key]
			set(key,value)
	
	## Default data pulled for every item
	## Just here for removing some redundant code
	func get_data_default():
		return {
			"id" : id,
			"title" : title,
			"type" : type,
			"description" : description,
			"target_type" : target_type,
			"target_selector" : target_selector,
			#"skillcheck_modifier" : skillcheck_modifier,
			#"vis_cost" : vis_cost,
			#"damage" : damage,
		}
	
	## Any additional data we want to pull besides the defaults
	func get_data():
		return {}
	
	func select_validate(): #run validations, check vis, health, etc
		var result = false #default so we cannot use this move
		return result
	
	func select_validate_failed():
		Debug.message("Can't do that",Debug.msg_category.BATTLE)
		#You can execute code here, run a Dialogic event to show them they can't use that, etc
		#For example, if they don't have enough vis

	func apply_status_success():
		return randf_range(0,1) <= chance*skillcheck_modifier

	func skillcheck(result):
		pass
	
	func cast_validate():
		if skillcheck_modifier > 0:
			return true
		else:
			return false
			
	func cast_validate_failed():
		Debug.message("Missed!",Debug.msg_category.BATTLE)
		Glossary.create_text_particle(caster.animations.selector_anchor,str("Missed!"),"float_away",Color.WHITE)
	
	func cast_main(): #Main function, calls on hit
		pass
	
	func cast_pre_mitigation_bonus(caster : Node, target : Node): #Internal function, call when there is a bonus effect
		cast_pre_mitigation(caster,target)
	
	func cast_pre_mitigation(caster : Node, target : Node): #Internal function, call in the body of each target
		pass
	
	func animation():
		caster.animations.tree.get("parameters/playback").travel("default_attack")
	
	#Put status effect in here, and when we cast, we add our spell to their status_effects array based on conditions (only one status at a time, if it's used we send a message saying they're immune)
	#They run their normal course, but are "infected" with our functions. Now the empty method calls 
	#when they were healthy will reference any calls in our spell's vocab and we don't have to do anything on character-side
	#E.g. Poison spell
	#Has function status_effect_on_start

### --- Interfaces --- ###

# Abilities

func find_ability(ability : component_ability.ability) -> component_ability.ability:
	var index = get_abilities().find(ability)
	return get_abilities()[index]

func clear_abilities() -> void:
	my_abilities.clear()

func is_room_for_abilities() -> bool:
	if get_abilities().size() < max_ability_count:
		return true
	else:
		return false

func get_abilities() -> Array:
	return my_abilities

func set_abilities(ability_array : Array) -> void:
	clear_abilities()
	for abil in ability_array:
		add_ability(abil)

func add_ability(ability : component_ability.ability) -> void:
	if is_room_for_abilities():
		ability.caster = owner
		my_abilities.append(ability)
	else:
		Debug.message("Cannot add ability, max count reached!")

func remove_ability(ability : component_ability.ability) -> void:
	my_abilities.erase(ability)

### --- Serialization --- ###

# Abilities

##Returns all get_data() functions on status effects to store in a data list for a save file
func get_data_status_all() -> Dictionary:
	var result : Dictionary = {}
	
	##NORMAL
	var normal_status_unit : Dictionary = {} #Reset it
	if my_status.NORMAL: #Check if we have effects to add
		normal_status_unit = my_status.NORMAL.get_data_default()
		normal_status_unit.merge(my_status.NORMAL.get_data(),true)
	result["NORMAL"] = normal_status_unit
	##PASSIVES
	var passive_status_list : Array = [] #Reset it
	for i in my_status.PASSIVE.size(): #Check if we have effects and iterate thru it
		var passive_unit : Dictionary = {}
		passive_unit = my_status.PASSIVE[i].get_data_default() #Set default vars
		passive_unit.merge(my_status.PASSIVE[i].get_data(),true) #Include and overwrite any defaults like id, etc
		passive_status_list.append(passive_unit) #Append this merged data to our entry in the array
	result["PASSIVE"] = passive_status_list
	
	#print_debug("Retrieved data for ",owner," ",result)
	return result

#Creates new statuses and sets their params based on data file
func set_data_status_all(host : Node, status_data : Dictionary):
	##NORMAL
	if my_status.NORMAL: #Remove any current NORMAL status
		my_status.remove(my_status.NORMAL)
	if !status_data["NORMAL"].is_empty(): #Check if NORMAL data is empty
		var normal_eff = my_status.add(Glossary.status_class[status_data["NORMAL"]["id"]].new(host),true) #Create the normal status and overwrite old status
		normal_eff.set_data(status_data["NORMAL"]) #Send the status our data for all its variables to change to
		
		#print_debug("set data for ",status_data["NORMAL"]["id"])
	##PASSIVE
	for i in my_status.PASSIVE.size(): #Remove any previous passives first
		my_status.remove_passive(my_status.PASSIVE[i])
	for i in status_data["PASSIVE"].size(): #Check if PASSIVE data is empty and also iterate thru array of dictionaries in PASSIVE
		var passive_eff = my_status.add_passive(Glossary.status_class[status_data["PASSIVE"][i]["id"]].new(host)) #Create the passive
		passive_eff.set_data(status_data["PASSIVE"][i]) #Send the indexed status our data for all its variables to change to
		
		#print_debug("set data for ",owner," ",status_data["PASSIVE"])

##Returns all get_data() functions on abilities to store in a data list for a save file
func get_data_ability_all():
	var result : Array = []
	for ability in get_abilities():
		var sub_result : Dictionary = {}
		sub_result = ability.get_data_default() #Set default vars
		sub_result.merge(ability.get_data(),true) #Include and overwrite any defaults like id, etc
		result.append(sub_result) #Append this merged data to our entry in the array
	return result

##Creates new abilties and sets their params based on data file
func set_data_ability_all(caster : Node, ability_data_list : Array):
	clear_abilities()
	for i in ability_data_list.size(): #iterate thru list
		var inst = Glossary.ability_class[ability_data_list[i]["id"]].new() #search glossary for the name we found in metadata
		inst.set_data(ability_data_list[i])
		add_ability(inst)

#
class ability_template_default: #Standard ability with vis cost and skillcheck
	extends ability
	
	func _init() -> void:
		target_type = Battle.target_type.OPPONENTS
	
	func select_validate():
		return true #HACK now vis does damage to us if it's at 0 instead of removing this stat
		#if caster.my_component_vis.vis >= vis_cost:
			#return true
		#else:
			#print_debug("Not enough Vis!")
			#return false
	
	func skillcheck(result):
		if result == "Miss":
			skillcheck_modifier = 0
		elif result == "Good":
			skillcheck_modifier = 1
		elif result == "Great":
			skillcheck_modifier = 2
		elif result == "Excellent":
			skillcheck_modifier = 3
		else:
			push_error("ERROR: Skillcheck result unhandled exception: ",result)
		
		Debug.message(["Result of skillcheck is ",result],Debug.msg_category.BATTLE)

class ability_spook:
	extends ability_template_default
	
	func get_data():
		return {
		"damage" : damage,
		"chance" : chance,
		"vis_cost" : vis_cost
		}
	
	func _init(damage : int = 1, chance : float = 0.3, vis_cost : int = 1) -> void:
		#Default changes
		
		id = "ability_spook"
		title = "Spook"
		description = "Unleashes an unsettling aura that disrupts the target's focus.\nHas a chance to fear target."
		self.damage = damage
		self.chance = chance
		self.vis_cost = vis_cost
		type = Battle.type.VOID
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS

	func cast_main():
		caster.my_component_vis.change(-vis_cost)
	
	func cast_pre_mitigation(caster : Node, target : Node):
		Debug.message([caster.name, " tried to spook ", target.name,"!"],Debug.msg_category.BATTLE)
		target.my_component_health.change(-skillcheck_modifier*damage)
		if apply_status_success():
			target.my_component_ability.my_status.add(status_fear.new(target,skillcheck_modifier*2))
	
	func animation():
		caster.animations.tree.get("parameters/playback").travel("default_attack_spook")

class ability_solar_flare:
	extends ability_template_default
	
	func get_data():
		return {
		"damage" : damage,
		"chance" : chance,
		"vis_cost" : vis_cost
		}
	
	func _init(damage : int = 1, chance : float = 0.3, vis_cost : int = 1) -> void:
		#Default changes
		id = "ability_solar_flare"
		title = "Solar Flare"
		description = "Summons a dazzling burst of radiant energy that coats the target in molten flame.\nHas a chance to burn target."
		self.damage = damage
		self.chance = chance
		self.vis_cost = vis_cost
		type = Battle.type.CHAOS
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
		
	func cast_pre_mitigation_bonus(caster : Node, target : Node): #Does bonus damage, bonus burn damage, and 100% chance to proc burn
		Debug.message([caster.name, " scorched ", target.name," for double damage!"],Debug.msg_category.BATTLE)
		target.my_component_ability.my_status.add(status_burn.new(target,skillcheck_modifier*2,damage*2))
		target.my_component_health.change(-damage*2)
		
	
	func cast_main(): #now runs all the excess that isn't affecting a specific target
		caster.my_component_vis.change(-vis_cost)
	
	func cast_pre_mitigation(caster : Node, target : Node): #this it the spell run from the target's POV. It is run from the hit signal
		Debug.message([caster.name, " ignited ", target.name,"!"],Debug.msg_category.BATTLE)
		if apply_status_success():
			target.my_component_ability.my_status.add(status_burn.new(target,skillcheck_modifier*2,damage))
		target.my_component_health.change(-damage)
		
	func animation():
		caster.animations.tree.get("parameters/playback").travel("default_attack") #TODO make solar flare animation or FX

class ability_frigid_core:
	extends ability_template_default
	
	func get_data():
		return {
		"damage" : damage,
		"chance" : chance,
		"vis_cost" : vis_cost
		}
	
	func _init(damage : int = 1, chance : float = 0.3, vis_cost : int = 1) -> void:
		#Default changes
		id = "ability_solar_flare"
		title = "Frigid Core"
		description = "Summons a chilling pulse of frozen energy inside the target.\nHas a chance to freeze."
		self.damage = damage
		self.chance = chance
		self.vis_cost = vis_cost
		type = Battle.type.VOID
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
		
	func cast_main():
		pass
		#TODO add vis removal here
	
	func cast_pre_mitigation(caster : Node, target : Node):
		Debug.message([caster.name, " froze ", target.name,"!"],Debug.msg_category.BATTLE)
		Debug.message(["It did ", round(skillcheck_modifier*damage), " damage!"],Debug.msg_category.BATTLE)
		target.my_component_health.change(-damage)
		target.my_component_ability.my_status.add(status_freeze.new(target,skillcheck_modifier*1,1))

class ability_tackle: #Scales with skillcheck
	extends ability_template_default
	
	##What gets exported between scenes and games
	func get_data():
		return {
		"damage" : damage
		}
	
	func _init(damage : int = 1) -> void:
		#Default changes
		id = "ability_tackle"
		title = "Tackle"
		description = "A forceful rush at the target, dealing damage"
		self.damage = damage
		type = Battle.type.BALANCE
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
	
	func cast_pre_mitigation(caster : Node, target : Node):
		Debug.message([caster.name, " Tackled ", target.name,"!"],Debug.msg_category.BATTLE)
		Debug.message(["It did ", round(skillcheck_modifier*damage), " damage!"],Debug.msg_category.BATTLE)
		target.my_component_health.change(-skillcheck_modifier*damage)

class ability_headbutt: #Scales with damage multiplier
	extends ability_template_default
	
	func get_data():
		return {
		"damage" : damage
		}
	
	func _init(damage : int = 1) -> void:
		#Default changes
		id = "ability_headbutt"
		title = "Headbutt"
		description = "Charges the target, dealing damage"
		self.damage = damage
		type = Battle.type.BALANCE
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
	
	func cast_pre_mitigation(caster : Node, target : Node):
		var mult = caster.my_component_ability.my_stats.damage_multiplier
		var calc_damage = damage+(damage*mult)
		Debug.message([caster.name, " Charged ", target.name,"!"],Debug.msg_category.BATTLE)
		Debug.message(["It did ", calc_damage, " damage!"],Debug.msg_category.BATTLE)
		target.my_component_health.change(-calc_damage)

class ability_heartlink:
	extends ability_template_default
	
	func get_data():
		return {}
	
	var old_targets : Array = []

	func _init() -> void:
		#Default changes
		id = "ability_heartlink"
		title = "Heartlink"
		description = "Binds the life essence of two targets together, causing them to share all health changes for a limited time"
		target_selector = Battle.target_selector.SINGLE_RIGHT
		target_type = Battle.target_type.OPPONENTS
		type = Battle.type.TETHER
		damage = 1
		vis_cost = 1
	
	func cast_main():
		caster.my_component_vis.change(-vis_cost)
		
		for i in len(old_targets): #remove instances from old targets
			if old_targets[i] not in targets and is_instance_valid(old_targets[i]) and old_targets[i]: #if old target is alive and not in current targets
				var teth = old_targets[i].my_component_ability.my_status.TETHER
				if teth and teth is status_heartlink: #If we find they still have our old buff
					old_targets[i].my_component_ability.my_status.remove(old_targets[i].my_component_ability.my_status.TETHER)
		old_targets = targets
	
	func cast_pre_mitigation(caster : Node, target : Node):
		##Make sure we're in the targets, idk why this is here tbh
		if target in targets:
			Debug.message([caster.name, " tried to stitch ", target.name,"!"],Debug.msg_category.BATTLE)
			target.my_component_health.change(-damage,true)
			
			##Verification for needing actual stitch
			if targets.size() >= 2:
				target.my_component_ability.my_status.add(status_heartlink.new(target,targets,skillcheck_modifier*2))
			else:
				Debug.message(["No valid target to stitch to - ",targets],Debug.msg_category.BATTLE)
	
	func animation():
		caster.animations.tree.get("parameters/playback").travel("default_attack") #TODO

class ability_switchstitch:
	extends ability_template_default
	
	func get_data():
		return {}
	
	func _init() -> void:
		#Default changes
		id = "ability_switchstitch"
		title = "Switch-stitch"
		description = "Forces two targeted enemies to swap positions"
		target_selector = Battle.target_selector.SINGLE_RIGHT
		target_type = Battle.target_type.OPPONENTS
		type = Battle.type.FLOW
		damage = 1
		vis_cost = 1
	
	func cast_main():
		caster.my_component_vis.change(-vis_cost)
	
	func cast_pre_mitigation(caster : Node, target : Node):
		if target == primary_target:
			var index_start = Battle.battle_list.find(targets.front())
			var index_end = Battle.battle_list.find(targets.back())
			Battle.mirror_section(index_start,index_end)
			
			for i in len(targets): #Only damages if the primary target tanks the damage
				targets[i].my_component_health.change(-damage)
			
			Battle.update_positions()
