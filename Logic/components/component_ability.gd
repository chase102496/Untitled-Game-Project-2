class_name component_ability
extends component_node

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
	
	## Returns current status effects matching the id arg
	## Type determines if we should only check one status effect category
	## Defaults to checking all of them
	func find_all(id : String, types : Array = [Battle.status_category.NORMAL,Battle.status_category.TETHER,Battle.status_category.PASSIVE]):
		
		var result : Array = []
		
		for my_status_cat in types:
			var my_status = get(my_status_cat)
			## If it exists
			if my_status:
				if my_status is Array:
					for my_status_inst in my_status:
						if my_status.id == id:
							result.append(my_status)
				else:
					if my_status.id == id:
						result.append(my_status)
		
		if result.is_empty():
			return null
		else:
			return result
	
	
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
	func add(effect : Object, ignore_priorities : bool = false, is_silent : bool = false) -> Object:
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
			effect.fx_add(is_silent)
			Debug.message(["!status overwritten! - ",effect.title],Debug.msg_category.BATTLE)
			Debug.message(["ignore_priorities = ",ignore_priorities],Debug.msg_category.BATTLE)
		else:
			Debug.message(["!cannot overwrite current status effect! - ",effect.title],Debug.msg_category.BATTLE)
		
		return get(effect_str)
			
	#Normal remove for non-lists
	func remove(effect : Object, is_silent : bool = false) -> void:
		var effect_str = effect.category
		var current_effect = get(effect_str)
		
		if current_effect:
			effect.fx_remove(is_silent)
			set(effect_str,null)
			Debug.message(["!status removed! - ",effect.title],Debug.msg_category.BATTLE)
		else:
			Debug.message(["!no status effect to remove! - ",effect.title],Debug.msg_category.BATTLE)

	func clear(clear_passive : bool = false) -> void:
		Debug.message(["!removed all status effects! - ",NORMAL,TETHER],Debug.msg_category.BATTLE)
		if NORMAL:
			remove(NORMAL,true)
		if TETHER:
			remove(TETHER,true)
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
	var type : Dictionary = Battle.type.EMPTY
	var duration : int = 0 #How many turns it lasts
	var title : String = "---"
	var title_notification : String = "?"
	var description : String = ""
	var priority : int = 0 #Whether a buff can overwrite it. Higher means it can
	var new_turn : bool #Whether we ran this once per turn already
	
	var fx_visual : Node
	var fx_icon# : TextureRect TODO DISABLED TEMPORARILY
	
	func _init(host : Node) -> void:
		self.host = host
	
	### --- Serialization --- ###
	
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
	
	### --- Internal --- ###
	
	## If we only wanna run this once per turn. Used if we modify state of host somehow, so it doesn't forget it already ran us
	func _once_per_turn():
		if new_turn:
			new_turn = false
			return true
		else:
			return false
	
	### --- Events --- ###
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		return false #false means we don't fuck with mitigation for this status effect
	
	func on_start(): #runs on start of turn
		new_turn = true
	
	func on_skillcheck(): #runs right before skillcheck
		pass
	
	func on_end(): #runs on end of turn
		pass
	
	func on_duration():
		pass
	
	func on_expire(): #runs when status effect expires
		pass
	
	func on_death():
		pass
	
	### --- Feedback --- ###
	
	## Add our fx using our id as the identifier for this fx
	func fx_add(is_silent : bool = false):
		
		if !is_silent:
			Glossary.create_icon_particle_queue(host.animations.selector_anchor,id)
			
		if !fx_visual and Glossary.particle.get(id):
			fx_visual = Glossary.create_fx_particle(host.animations.selector_anchor,id)
		if !fx_icon and Glossary.status_icon.get(id):
			fx_icon = Glossary.create_status_icon(host.animations.status_hud.grid,id)
	
	func fx_remove(is_silent : bool = false):
		
		if !is_silent:
			pass
		
		if fx_visual:
			fx_visual.queue_free()
			fx_visual = null
		if fx_icon:
			fx_icon.queue_free()
			fx_icon = null
# ---

class status_template_normal:
	extends status
	
	func on_duration() -> void:
		super.on_duration()
		
		duration = max(duration - 1,0)
		if duration <= 0:
			on_expire()

	func on_expire() -> void:
		super.on_expire()
		
		host.my_component_ability.my_status.remove(self)

class status_template_passive:
	extends status
	
	func fx_add(is_silent : bool = true) -> void:
		super.fx_add(is_silent)

# NORMAL
class status_fear:
	extends status_template_normal
	
	func get_data():
		return {}
	
	func _init(host : Node,duration : int = 2) -> void:
		#Defaults
		id = "status_fear"
		title = "Fear"
		description = "Causes the target to lose accuracy on attacks"
		self.host = host
		self.duration = duration
	
	func on_skillcheck():
		host.my_component_ability.skillcheck_difficulty += 1

class status_burn:
	extends status_template_normal
	
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
	
	func on_end():
		if _once_per_turn(): #If this is the first time applying this turn
			host.my_component_health.change(-damage)
			Debug.message(["Burn did ",damage," damage!"],Debug.msg_category.BATTLE)

class status_freeze:
	extends status_template_normal
	
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
	
	func on_end():
		if _once_per_turn(): #If this is the first time applying this turn
			host.my_component_vis.change(-siphon_amount)
			Debug.message([host," lost ",siphon_amount," vis from freeze!"],Debug.msg_category.BATTLE)

#Unable to act or be acted upon. Essentially dead but still on the battle field.
class status_disable:
	extends status_template_normal
	
	func get_data():
		return {}
	
	func _init(host : Node, duration : int = 2) -> void:
		id = "status_disable"
		title = "Disabled"
		description = "Completely disables the target, preventing them from getting attacked and also from attacking"
		self.host = host
		self.duration = duration
		priority = 999 #Nothing should overwrite us
	
	func on_start():
		host.state_chart.send_event("on_end") #skip our turn
		Debug.message([host.name," is disabled this turn"],Debug.msg_category.BATTLE)
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		Debug.message([entity_target.name," is immune to ",ability.title,"!"],Debug.msg_category.BATTLE)
		Glossary.create_text_particle_queue(entity_target.animations.selector_anchor,str("Immune!"),"text_float_away")
		return Battle.mitigation_type.IMMUNE
	
	func on_expire():
		Debug.message([host.name," is no longer disabled!"],Debug.msg_category.BATTLE)
		host.my_component_ability.my_status.remove(self)
		Events.battle_entity_disabled_expire.emit(host) #Tell everyone our disable expired

# TETHER

class status_heartsurge:
	extends status_template_normal
	
	var partners : Array
	
	func _init(host : Node,partners : Array,duration : int) -> void:
		id = "status_heartsurge"
		title = "heartsurge"
		description = "This target is sharing damage with another"
		self.host = host #who is the initial target of the link
		self.partners = partners #who is paired to the host
		self.duration = duration
		behavior = Battle.status_behavior.STACK
		category = Battle.status_category.TETHER
	
	func _verify_partners() -> Array:
		var verified_partners : Array = []
		for inst in partners:
			if inst:
				verified_partners.append(inst)
		return verified_partners
	
	func on_duration() -> void:
		super.on_duration()
		if _verify_partners().size() < 2:
			print("EE")
			on_expire()
	
	func on_battle_entity_damaged(entity,amount): #the bread n butta of heartsurge
		if entity == host and partners.size() > 1: #if person hurt was our host, and partners aint all ded
			for i in partners.size():
				if partners[i] != host and partners[i] in Battle.battle_list: #if it's not me and it's alive
					partners[i].my_component_health.change(amount,true)
					Debug.message([partners[i].name," took ",amount," points of mirror damage!"],Debug.msg_category.BATTLE)

# PASSIVE
#Basically the same thing but PRIORITY here works differently. It runs through them when checking things that stack like ability mitigation.
#the highest prio is checked first and if it finds something of interest it will handle it

## Weak to one aspect
class status_weakness:
	extends status_template_passive
	
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
			Glossary.create_text_particle_queue(entity_target.animations.selector_anchor,str("Weakness!"),"text_float_away",Color.PURPLE)
			return Battle.mitigation_type.WEAK
		else:
			return Battle.mitigation_type.PASS

## Immune to one aspect
class status_immunity: #Creates a specific immunity where if it's matching the type, they are immune
	extends status_template_passive
	
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
			Glossary.create_text_particle_queue(entity_target.animations.selector_anchor,str("Immune!"),"text_float_away")
			return Battle.mitigation_type.IMMUNE #here we add a message saying we mitigated everything
		else: #battle mitigation ALWAYS needs an else statement to handle the ability normally
			return Battle.mitigation_type.PASS #here we add a message saying we didn't mitigate anything

## Immune to all aspects except one
class status_ethereal: #Immune to everything but one type
	extends status_template_passive
	
	func get_data():
		return {
		"title" : title,
		"weakness" : weakness,
		}
	
	var weakness : Dictionary
	
	func _init(host : Node, weakness : Dictionary = Battle.type.CHAOS) -> void:
		id = "status_ethereal"
		title = "Ethereal"
		description = "This target is immune to all aspects except one"
		self.host = host
		self.weakness = weakness
		category = Battle.status_category.PASSIVE
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		if ability.type != weakness:
			Debug.message([entity_target.name," is immune to ",ability.title,"!"],Debug.msg_category.BATTLE)
			Glossary.create_text_particle_queue(entity_target.animations.selector_anchor,str("Immune!"),"text_float_away")
			return Battle.mitigation_type.IMMUNE #here we add a message saying we mitigated everything
		else: #battle mitigation ALWAYS needs an else statement to handle the ability normally
			return Battle.mitigation_type.PASS #here we add a message saying we didn't mitigate anything

## Deals damage to attacker on-hit
class status_thorns:
	extends status_template_passive
	
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

## Resurrects when others with this passive are still alive
class status_regrowth:
	extends status_template_passive
	
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
	
	## We started the dying animation
	func on_dying():
		var paired_teammates = Battle.search_glossary_name(host.glossary,Battle.get_team(host.alignment),false) #pull all similar characters with our glossary name
		for i in len(paired_teammates):
			paired_teammates[i].my_component_ability.my_status.clear() #Clear status fx
			paired_teammates[i].animations.tree.get("parameters/playback").travel("Death") #Begin their death anim
	
	## Out health reaches 0
	func on_death_protection(amt : int, mirror_damage : bool = false):
		
		var living_teammates : Array = []
		
		for teammate in Battle.my_team(host):
			## If we query this teammate and find anything
			if teammate.my_component_ability.status_manager.find_all(id):
				## If the teammate's health is above 0
				if teammate.my_component_health.health > 0:
					living_teammates.append(teammate)
		
		if !living_teammates.is_empty():
			if !death_protection_enabled: #If it hasn't already been triggered this death
				host.my_component_ability.my_status.clear() #Clear status fx first
				host.my_component_ability.my_status.add(status_disable.new(host,2),true) #Then disable us
				death_protection_enabled = true #We are now in "incapacitated" mode
			return true #Always return true for letting health know we aren't dead yet

class status_swarm: #Adds a percent to our damage based on how many of us are on the field (besides us)
	extends status_template_passive
	
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

class status_stealth: #Cannot be targeted directly by attacks and echoes (needs AoE or heartsurge)
	extends status_template_passive

### --- Abilities --- ###

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

# Abilities

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
	
	## Base Damage
	var damage : int = 0
	## Cost for ability
	var vis_cost : int = 0
	## Chance of applying status or whatever additional effect we want
	var chance : float = 1.0
	var description : String = ""
	
	func _init() -> void:
		pass
	
	### --- Serialization --- ###
	
	## For Deserialization
	## Sets all vars that match the keys in the metadata to the values in the metadata
	func set_data(new_metadata : Dictionary):
		for key in new_metadata:
			var value = new_metadata[key]
			set(key,value)
	
	## For Serialization
	## Default data pulled for every item
	## Just here for removing some redundant code
	func get_data_default() -> Dictionary:
		return {
			"id" : id,
			"title" : title,
			"type" : type,
			"description" : description,
			"target_type" : target_type,
			"target_selector" : target_selector,
		}
	
	## For Serialization
	## Any additional data we want to pull besides the defaults
	func get_data() -> Dictionary:
		return {}
	
	### --- Validations --- ###
	
	## Checks, when we make contact and the attack has already been selected, if we can succeeded
	func cast_validate():
		pass
	
	## Checks, when we select an ability, if we can use it
	## Should return a bool
	func select_validate():
		pass
	
	## If we try to select this ability, but we can't use it (no vis, etc)
	func _select_validate_failed() -> void:
		pass
	
	## If our skillcheck fails, or we don't meet conditions when attack lands
	func cast_validate_failed() -> void:
		pass
	
	### --- Skillcheck --- ###
	
	## Calculations done to pull the skillcheck result for our ability
	func skillcheck(result) -> void:
		pass
	
	### --- Casting --- ###
	
	## Called when we make contact, on caster-side
	func cast_main() -> void:
		pass
	
	## Damage run on target-side
	func cast_pre_mitigation(caster : Node, target : Node):
		pass
	
	## Damage run on target-side, they are weak to this ability
	func cast_pre_mitigation_bonus(caster : Node, target : Node) -> void:
		pass
	
	## If we successfully apply a status effect associated with this ability
	func apply_status_success():
		pass

	### --- Feedback --- ###
	
	## Called when we make contact, on targets-side. One for each
	func fx_cast_main() -> void:
		pass
	
	## Animation we call when using this ability
	func animation():
		pass

class ability_template_standard: #Standard ability with vis cost and skillcheck
	extends ability
	
	func _init() -> void:
		super._init()
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
	
	### --- Private --- ###
	
	func _select_validate_failed() -> void:
		super._select_validate_failed()
		
		Debug.message("Can't do that",Debug.msg_category.BATTLE)
	
	### --- Validation --- ###
	
	func select_validate() -> bool:
		super.select_validate()
		
		if caster.my_component_vis.vis >= vis_cost:
			return true
		else:
			_select_validate_failed()
			return false
	
	func cast_validate() -> bool:
		if skillcheck_modifier > 0:
			return true
		else:
			return false
	
	func cast_validate_failed() -> void:
		super.cast_validate_failed()
		
		Debug.message("Missed!",Debug.msg_category.BATTLE)
		Glossary.create_text_particle_queue(caster.animations.selector_anchor,str("Missed!"),"text_float_away",Color.WHITE)
	
	### --- Skillcheck --- ###
	
	func skillcheck(result) -> void:
		super.skillcheck(result)
		
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
	
	### --- Casting --- ###
	
	## When on_contact is called, caster-side
	func cast_main() -> void:
		super.cast_main()
		
		caster.my_component_vis.change(-vis_cost,false)
	
	func cast_pre_mitigation_bonus(caster : Node, target : Node) -> void:
		super.cast_pre_mitigation_bonus(caster,target)
		
		cast_pre_mitigation(caster,target)
	
	func apply_status_success() -> float:
		super.apply_status_success()
		
		return randf_range(0,1) <= chance*skillcheck_modifier
	
	### --- Feedback --- ###
	
	func animation() -> void:
		caster.animations.tree.get("parameters/playback").travel("default_attack")

class ability_spook:
	extends ability_template_standard
	
	func get_data():
		return {
		"damage" : damage,
		"chance" : chance,
		"vis_cost" : vis_cost
		}
	
	func _init(damage : int = 1, chance : float = 0.3, vis_cost : int = 1) -> void:
		super._init()
		self.damage = damage
		self.chance = chance
		self.vis_cost = vis_cost
		id = "ability_spook"
		title = "Spook"
		description = "Unleashes an unsettling aura that disrupts the target's focus.\nHas a chance to fear target."
		type = Battle.type.VOID
	
	func cast_pre_mitigation(caster : Node, target : Node):
		Debug.message([caster.name, " tried to spook ", target.name,"!"],Debug.msg_category.BATTLE)
		target.my_component_health.change(-skillcheck_modifier*damage)
		if apply_status_success():
			target.my_component_ability.my_status.add(status_fear.new(target,skillcheck_modifier*2))
	
	func animation():
		caster.animations.tree.set_state("default_attack")

class ability_solar_flare:
	extends ability_template_standard
	
	func get_data():
		return {
		"damage" : damage,
		"chance" : chance,
		"vis_cost" : vis_cost
		}
	
	func _init(damage : int = 1, chance : float = 1.0, vis_cost : int = 1) -> void:
		super._init()
		id = "ability_solar_flare"
		title = "Solar Flare"
		description = "Summons a dazzling burst of radiant energy that coats the target in molten flame.\nHas a chance to burn target."
		self.damage = damage
		self.chance = chance
		self.vis_cost = vis_cost
		type = Battle.type.CHAOS
		
	func cast_pre_mitigation_bonus(caster : Node, target : Node): #Does bonus damage, bonus burn damage, and 100% chance to proc burn
		Debug.message([caster.name, " scorched ", target.name," for double damage!"],Debug.msg_category.BATTLE)
		target.my_component_ability.my_status.add(status_burn.new(target,skillcheck_modifier*2,damage*2))
		target.my_component_health.change(-damage*2)
	
	func cast_pre_mitigation(caster : Node, target : Node): #this it the spell run from the target's POV. It is run from the hit signal
		Debug.message([caster.name, " ignited ", target.name,"!"],Debug.msg_category.BATTLE)
		if apply_status_success():
			target.my_component_ability.my_status.add(status_burn.new(target,skillcheck_modifier*2,damage))
		target.my_component_health.change(-damage)
		
	func animation():
		caster.animations.tree.set_state("default_attack") #TODO make solar flare animation or FX

class ability_frigid_core:
	extends ability_template_standard
	
	func get_data():
		return {
		"damage" : damage,
		"chance" : chance,
		"vis_cost" : vis_cost
		}
	
	func _init(damage : int = 1, chance : float = 0.3, vis_cost : int = 1) -> void:
		super._init()
		id = "ability_solar_flare"
		title = "Frigid Core"
		description = "Summons a chilling pulse of frozen energy inside the target.\nHas a chance to freeze."
		self.damage = damage
		self.chance = chance
		self.vis_cost = vis_cost
		type = Battle.type.VOID
		
	func cast_main():
		pass
		#TODO add vis removal here
	
	func cast_pre_mitigation(caster : Node, target : Node):
		Debug.message([caster.name, " froze ", target.name,"!"],Debug.msg_category.BATTLE)
		Debug.message(["It did ", round(skillcheck_modifier*damage), " damage!"],Debug.msg_category.BATTLE)
		target.my_component_health.change(-damage)
		target.my_component_ability.my_status.add(status_freeze.new(target,skillcheck_modifier*1,1))

class ability_tackle: #Scales with skillcheck
	extends ability_template_standard
	
	##What gets exported between scenes and games
	func get_data():
		return {
		"damage" : damage
		}
	
	func _init(damage : int = 1) -> void:
		super._init()
		id = "ability_tackle"
		title = "Tackle"
		description = "A forceful rush at the target, dealing damage"
		self.damage = damage
		type = Battle.type.BALANCE
	
	func cast_pre_mitigation(caster : Node, target : Node):
		Debug.message([caster.name, " Tackled ", target.name,"!"],Debug.msg_category.BATTLE)
		Debug.message(["It did ", round(skillcheck_modifier*damage), " damage!"],Debug.msg_category.BATTLE)
		target.my_component_health.change(-skillcheck_modifier*damage)

class ability_headbutt: #Scales with damage multiplier
	extends ability_template_standard
	
	func get_data():
		return {
		"damage" : damage
		}
	
	func _init(damage : int = 1) -> void:
		super._init()
		self.damage = damage
		id = "ability_headbutt"
		title = "Headbutt"
		description = "Charges the target, dealing damage"
		type = Battle.type.BALANCE
	
	func cast_pre_mitigation(caster : Node, target : Node):
		var mult = caster.my_component_ability.my_stats.damage_multiplier
		var calc_damage = damage+(damage*mult)
		Debug.message([caster.name, " Charged ", target.name,"!"],Debug.msg_category.BATTLE)
		Debug.message(["It did ", calc_damage, " damage!"],Debug.msg_category.BATTLE)
		target.my_component_health.change(-calc_damage)

class ability_heartsurge:
	extends ability_template_standard
	
	func get_data():
		return {}
	
	var old_targets : Array = []

	func _init(damage : int = 1, vis_cost : int = 1) -> void:
		super._init()
		self.damage = damage
		self.vis_cost = vis_cost
		id = "ability_heartsurge"
		title = "Soulstitch"
		description = "Binds the life essence of two targets together, causing them to share all health changes for a limited time"
		target_selector = Battle.target_selector.SINGLE_RIGHT
		type = Battle.type.TETHER
	
	
	
	func cast_main():
		super.cast_main()
		
		if old_targets != targets:
			for inst in old_targets: #remove instances from old targets
				if inst and is_instance_valid(inst): #if old target is alive and not in current targets
					var teth = inst.my_component_ability.my_status.TETHER
					if teth and teth is status_heartsurge: #If we find they still have our old buff
						inst.my_component_ability.my_status.remove(inst.my_component_ability.my_status.TETHER)
		
		old_targets = targets
	
	func cast_pre_mitigation(caster : Node, target : Node):
		##Make sure we're in the targets, idk why this is here tbh
		if target in targets:
			Debug.message([caster.name, " tried to stitch ", target.name,"!"],Debug.msg_category.BATTLE)
			target.my_component_health.change(-damage,true)
			
			##Verification for needing actual stitch
			if targets.size() >= 2:
				target.my_component_ability.my_status.add(status_heartsurge.new(target,targets,skillcheck_modifier*2))
			else:
				Debug.message(["No valid target to stitch to - ",targets],Debug.msg_category.BATTLE)
	
	func animation():
		caster.animations.tree.get("parameters/playback").travel("default_attack") #TODO

class ability_switchstitch:
	extends ability_template_standard
	
	func get_data():
		return {}
	
	func _init(damage : int = 1) -> void:
		super._init()
		
		self.damage = damage
		id = "ability_switchstitch"
		title = "Switch-stitch"
		description = "Forces two targeted enemies to swap positions"
		target_selector = Battle.target_selector.SINGLE_RIGHT
		type = Battle.type.FLOW
	
	func cast_pre_mitigation(caster : Node, target : Node):
		if target == primary_target:
			var index_start = Battle.battle_list.find(targets.front())
			var index_end = Battle.battle_list.find(targets.back())
			Battle.mirror_section(index_start,index_end)
			
			for i in len(targets): #Only damages if the primary target tanks the damage
				targets[i].my_component_health.change(-damage)
			
			Battle.update_positions()
