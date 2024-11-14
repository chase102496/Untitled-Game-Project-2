class_name component_ability
extends Node

@onready var cast_queue : Object = null

@onready var current_status_effects : Object = status_manager.new()

#We will not assign spells this way, might need to fix tho, hard to set em up without all the vars right in front of you 
@onready var my_abilities : Array = []
@onready var max_ability_count : int = 4
var skillcheck_difficulty : float = 1.0

#Stats for use in abilities
@export var stats : Dictionary = {
	"damage_multiplier" : 1.0
	}

func _ready() -> void:
	pass
#------------------------------------------------------------------------------
#DONT use name or owner, already taken
#HACK _init is where you store stuff you'd only need way before battle, like damage, vis cost, etc

# - Functions - #

class status_manager:

	var NORMAL #they can overwrite eachother based on priority. Only one at a time
	var TETHER #Primarily for Lumia's stitch mechanic
	var PASSIVE : Array = [] #Primarily for semi-permanent status effects that start at battle initialize and don't interact with NORMAL and TETHER
	
	func search_title(title_query : String): #Returns first result matching the title of the input, or null if no result TODO BROKEN
		if NORMAL and NORMAL.title == title_query:
			return NORMAL
		if TETHER and TETHER.title == title_query:
			return TETHER
		if len(PASSIVE) > 0:
			for i in len(PASSIVE):
				if PASSIVE[i].title == title_query:
					return PASSIVE
		return null
	
	func add_passive(effect : Object) -> void:
		PASSIVE.append(effect)
		effect.fx_add()
		print_debug("!passive added! - ",effect.title)
		
	func remove_passive(effect : Object) -> void:
		PASSIVE.pop_at(PASSIVE.find(effect))
		effect.fx_remove()
		print_debug("!passive removed! - ",effect.title)
	
	#Normal add for non-lists
	func add(effect : Object, ignore_priorities : bool = false) -> void:
		var effect_str = effect.category
		var current_effect = get(effect_str)
		
		if !current_effect: #if there's no status effect
			set(effect_str,effect)
			effect.fx_add()
			print_debug("!status added! - ",effect.title)
		elif current_effect.title == effect.title: #if they're the same status effect
				print_debug("!target status is equal to applied status! - ",effect.title)
				match effect.behavior:
					Battle.status_behavior.STACK:
						current_effect.duration += effect.duration
						print_debug("!status duration increased! - ",effect.title)
					Battle.status_behavior.RESET:
						remove(current_effect)
						set(effect_str,effect)
						effect.fx_add()
						print_debug("!status reapplied! - ",effect.title)
					Battle.status_behavior.RESIST:
						print_debug("!status ignored! - ",effect.title)
					_:
						push_error("ERROR, status behavior not found: ",effect.behavior,effect.title)
		elif ignore_priorities or current_effect.priority < effect.priority: #if our new status effect has higher priority or ignores prio
			remove(current_effect)
			set(effect_str,effect)
			effect.fx_add()
			print_debug("!status overwritten! - ",effect.title)
			print_debug("ignore_priorities = ",ignore_priorities)
		else:
			print_debug("!cannot overwrite current status effect! - ",effect.title)
			
	#Normal remove for non-lists
	func remove(effect : Object) -> void:
		var effect_str = effect.category
		var current_effect = get(effect_str)
		
		if current_effect:
			effect.fx_remove()
			set(effect_str,null)
			print_debug("!status removed! - ",effect.title)
		else:
			print_debug("!no status effect to remove! - ",effect.title)

	func clear() -> void:
		print_debug("!removed all status effects! - ",NORMAL,TETHER)
		if NORMAL:
			remove(NORMAL)
		if TETHER:
			remove(TETHER)

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
		

#need to make a tether class and then subclasses based on what to do with the tether
#one called tether_heart which shares damage between the two
#one called tether_undying which makes the target check if its partner is dead before truly dying, and if not, "revive" to full health
#	should play death animation and stay in it until the next start() and then revive and reset to full
#

# - Status Effects - #
class status:
	var host : Node #The owner of the status effect. Who to apply it to
	var behavior : String = Battle.status_behavior.RESIST
	var category : String = Battle.status_category.NORMAL
	var duration : int #How many turns it lasts
	var title : String = "---"
	var fx : Node #Visual fx
	var priority : int = 0 #Whether a buff can overwrite it. Higher means it can
	var new_turn : bool #Whether we ran this once per turn already
	
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
	
	func on_battle_entity_missed(entity_caster : Node, entity_targets : Array, ability : Object):
		pass
	
	func on_battle_entity_hit(entity_caster : Node, entity_targets : Array, ability : Object): #when someone gets hit (anyone)
		pass
	
	func on_battle_entity_damaged(entity,amount): #runs when the host of the status effect's health changes
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
		print_debug(title," wore off for ",host.name,"!")
		host.my_component_ability.current_status_effects.remove(self)
	
	func fx_add():
		host.animations.sprite.add_child(fx)
		fx.global_position = host.animations.sprite.global_position
	
	func fx_remove():
		fx.queue_free()
		fx = null

# NORMAL
class status_fear:
	extends status_template_default
	
	func _init(host : Node,duration : int) -> void:
		self.host = host
		self.duration = duration
		title = "Fear"
		fx = Glossary.particle.fear.instantiate()
	
	func on_skillcheck():
		host.my_component_ability.skillcheck_difficulty += 1

class status_burn:
	extends status_template_default
	
	var damage : int
	
	func _init(host : Node,duration : int,damage : int) -> void:
		self.host = host
		self.duration = duration
		self.damage = damage
		title = "Burn"
		fx = Glossary.particle.burn.instantiate()
	
	func on_end():
		if once_per_turn(): #If this is the first time applying this turn
			host.my_component_health.damage(damage)
			print_debug("Burn did ",damage," damage!")

class status_freeze:
	extends status_template_default
	
	var siphon_amount : int
	
	func _init(host : Node,duration : int,siphon_amount : int) -> void:
		self.host = host
		self.duration = duration
		self.siphon_amount = siphon_amount
		title = "Freeze"
		fx = Glossary.particle.freeze.instantiate()
	
	func on_end():
		if once_per_turn(): #If this is the first time applying this turn
			host.my_component_vis.siphon(siphon_amount)
			print_debug(host," lost ",siphon_amount," vis from freeze!")

class status_disabled: #Disabled, unable to act, and immune to damage. Essentially dead but still on the battle field
	extends status_template_default
	
	func _init(host : Node,duration : int) -> void:
		self.host = host
		self.duration = duration
		title = "Disabled"
		priority = 999 #Nothing should overwrite us
		fx = Glossary.particle.disabled.instantiate()
	
	func on_start():
		host.state_chart.send_event("on_end") #skip our turn
		print_debug(host.name," is disabled this turn")
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		print_debug(entity_target.name," is immune to ",ability.title,"!")
		Glossary.create_text_particle(entity_target,entity_target.animations.sprite.global_position,str("Immune!"),"float_away")
		return Battle.mitigation_type.IMMUNE
	
	func on_expire():
		print_debug(host.name," is no longer disabled!")
		host.my_component_ability.current_status_effects.remove(self)
		Events.battle_entity_disabled_expire.emit(host) #Tell everyone our disable expired

# TETHER

class status_heartstitch:
	extends status_template_default
	
	var partners : Array
	
	func _init(host : Node,partners : Array,duration : int) -> void:
		self.host = host #who is the initial target of the stitch
		self.partners = partners #who is paired to the host
		self.duration = duration
		behavior = Battle.status_behavior.RESET
		category = Battle.status_category.TETHER
		title = "Heartstitch"
	
	func on_battle_entity_damaged(entity,amount): #the bread n butta of heartstitch
		if entity == host and len(partners) > 1: #if person hurt was our host, and partners aint all ded
			for i in len(partners):
				if partners[i] != host and partners[i] in Battle.battle_list: #if it's not me and it's alive
					partners[i].my_component_health.damage(amount,true)
					print_debug(partners[i].name," took ",amount," points of mirror damage!")
	
	func fx_add():
		fx = Glossary.ui.heartstitch.instantiate()
		host.animations.status_hud.grid.add_child(fx)
	
	func fx_remove():
		fx.queue_free()
		fx = null

# PASSIVE
#Basically the same thing but PRIORITY here works differently. It runs through them when checking things that stack like ability mitigation.
#the highest prio is checked first and if it finds something of interest it will handle it

class status_ethereal: #Immune to everything but one type
	extends status
	
	var weakness : Dictionary
	
	func _init(host : Node,weakness : Dictionary) -> void:
		self.host = host
		self.weakness = weakness
		category = Battle.status_category.PASSIVE
		title = "Ethereal"
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		if ability.type != weakness:
			print_debug(entity_target.name," is immune to ",ability.title,"!")
			Glossary.create_text_particle(entity_target,entity_target.animations.sprite.global_position,str("Immune!"),"float_away")
			return Battle.mitigation_type.IMMUNE #here we add a message saying we mitigated everything
		else: #battle mitigation ALWAYS needs an else statement to handle the ability normally
			return Battle.mitigation_type.PASS #here we add a message saying we didn't mitigate anything

class status_thorns:
	extends status
	
	var damage : int
	var reflect_target : Object = null
	
	func _init(host : Node,damage : int) -> void:
		self.host = host
		self.damage = damage
		category = Battle.status_category.PASSIVE
		title = "Thorns"
	
	func on_battle_entity_hit(entity_caster : Node, entity_targets : Array, ability : Object):
		if host in entity_targets and ability.primary_target == host: #If we're the primary target and but we're being attacked
			reflect_target = entity_caster
	
	func on_battle_entity_turn_end(entity : Node):
		if reflect_target:
			reflect_target.my_component_health.damage(damage)
			print_debug(host.name," reflected ",damage," damage back to ",reflect_target.name,"!")
			reflect_target = null

class status_regrowth:
	extends status
	
	var death_protection_enabled : bool = false
	
	func _init(host : Node,) -> void:
		self.host = host
		category = Battle.status_category.PASSIVE
		title = "Regrowth"
	
	func on_battle_entity_disabled_expire(entity : Node):
		if entity == host: #If we just got out of a disable
			if death_protection_enabled: #If we have death protection on
					host.my_component_health.revive() #Revive us
					death_protection_enabled = false
	
	func on_dying(): #We started the dying animation
		var paired_teammates = Battle.search_glossary_name(host.stats.glossary,Battle.get_team(host.stats.alignment),false) #pull all similar characters with our glossary name
		for i in len(paired_teammates):
			paired_teammates[i].my_component_ability.current_status_effects.clear() #Clear status fx
			paired_teammates[i].animations.tree.get("parameters/playback").travel("Death") #Begin their death anim
	
	func on_death_protection(amt : int, mirror_damage : bool = false, type : Dictionary = Battle.type.BALANCE):
		var paired_teammates = Battle.search_glossary_name(host.stats.glossary,Battle.get_team(host.stats.alignment),false) #pull all similar characters with our glossary name
		var living_teammates = false
		
		for i in len(paired_teammates): #If we find a single teammate about 0 HP
			if paired_teammates[i].my_component_health.health > 0:
				living_teammates = true
		
		if living_teammates: #If we find ANY other matching teammate glossaries of us that are alive and not in disabled mode
			
			#if status_disabled not in host.my_component_ability.current_status_effects.PASSIVE:
				#print("EEE") TODO
			
			if !death_protection_enabled: #If it hasn't already been triggered this death
				host.my_component_ability.current_status_effects.clear() #Clear status fx first
				host.my_component_ability.current_status_effects.add(status_disabled.new(host,2),true) #Then disable us
				death_protection_enabled = true #We are now in "incapacitated" mode
			return true #Always return true for letting health know we aren't dead yet

class status_immunity: #Creates a specific immunity where if it's matching the type, they are immune
	extends status
	
	var immunity : Dictionary
	
	func _init(host : Node,immunity : Dictionary) -> void:
		self.host = host
		self.immunity = immunity
		category = Battle.status_category.PASSIVE
		title = "Immunity"
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		if ability.type == immunity:
			print_debug(entity_target.name," is immune to ",ability.title,"!")
			Glossary.create_text_particle(entity_target,entity_target.animations.sprite.global_position,str("Immune!"),"float_away")
			return Battle.mitigation_type.IMMUNE #here we add a message saying we mitigated everything
		else: #battle mitigation ALWAYS needs an else statement to handle the ability normally
			return Battle.mitigation_type.PASS #here we add a message saying we didn't mitigate anything

class status_weakness: #Creates a specific type that we look for to do bonus things when hit
	extends status
	
	var weakness : Dictionary
	
	func _init(host : Node,weakness : Dictionary) -> void:
		self.host = host
		self.weakness = weakness
		category = Battle.status_category.PASSIVE
		title = "Weakness"
	
	func on_ability_mitigation(entity_caster : Node, entity_target : Node, ability : Object):
		if ability.type == weakness:
			print_debug(entity_target.name," is weak to ",ability.title,"!")
			entity_caster.my_component_ability.cast_queue.cast_pre_mitigation_bonus(entity_caster,host)
			Glossary.create_text_particle(entity_target,entity_target.animations.sprite.global_position,str("Weakness!"),"float_away",Color.PURPLE,0.3)
			return Battle.mitigation_type.WEAK
		else:
			return Battle.mitigation_type.PASS

class status_swarm: #Adds a percent to our damage based on how many of us are on the field (besides us)
	extends status
	
	var mult_total : float
	var mult_percent : float
	
	func _init(host : Node,mult_percent : float = 1.0) -> void:
		self.host = host
		self.mult_percent = mult_percent #This adds to host's damage multiplier so 0.1 would be 10% increased for every enemy
		category = Battle.status_category.PASSIVE
		title = "Swarm"
	
	func on_start():
		var paired_teammates = Battle.search_glossary_name(host.stats.glossary,Battle.get_team(host.stats.alignment),false)
		mult_total = (len(paired_teammates) - 1)*mult_percent #teammates + mult percent for one teammate
		host.my_component_ability.stats.damage_multiplier += mult_total
	
	func on_end():
		host.my_component_ability.stats.damage_multiplier -= mult_total
	
# - Abilities - #
class ability:

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
	
	func _init(caster : Node) -> void:
		self.caster = caster
	
	func select_validate(): #run validations, check vis, health, etc
		var result = false #default so we cannot use this move
		return result
	
	func select_validate_failed():
		print_debug("Can't do that")
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
		print_debug("Missed!")
		Glossary.create_text_particle(caster,caster.animations.sprite.global_position,str("Missed!"),"float_away",Color.WHITE)
	
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
# ---

class ability_template_default: #Standard ability with vis cost and skillcheck
	extends ability
	
	func _init() -> void:
		target_type = Battle.target_type.OPPONENTS
		description = "Default ability description"
	
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
		
		print_debug("Result of skillcheck is ",result)

class ability_spook:
	extends ability_template_default
	
	func _init(caster : Node, damage : int = 1, chance : float = 0.3, vis_cost : int = 1) -> void:
		self.caster = caster
		self.damage = damage
		self.chance = chance
		self.vis_cost = vis_cost
		type = Battle.type.VOID
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
		title = "Spook"
		description = "Unleashes an unsettling aura that disrupts the target's focus.\nHas a chance to fear target."

	func cast_main():
		caster.my_component_vis.siphon(vis_cost)
	
	func cast_pre_mitigation(caster : Node, target : Node):
		print_debug(caster.name, " tried to spook ", target.name,"!")
		target.my_component_health.damage(skillcheck_modifier*damage)
		if apply_status_success():
			target.my_component_ability.current_status_effects.add(status_fear.new(target,skillcheck_modifier*2))
	
	func animation():
		caster.animations.tree.get("parameters/playback").travel("default_attack_spook")

class ability_solar_flare:
	extends ability_template_default
	
	func _init(caster : Node, damage : int = 1, chance : float = 0.3, vis_cost : int = 1) -> void:
		self.caster = caster
		self.damage = damage
		self.chance = chance
		self.vis_cost = vis_cost
		type = Battle.type.CHAOS
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
		title = "Solar Flare"
		description = "Summons a dazzling burst of radiant energy that coats the target in molten flame.\nHas a chance to burn target."
		
		
	func cast_pre_mitigation_bonus(caster : Node, target : Node): #Does bonus damage, bonus burn damage, and 100% chance to proc burn
		print_debug(caster.name, " scorched ", target.name," for double damage!")
		target.my_component_ability.current_status_effects.add(status_burn.new(target,skillcheck_modifier*2,damage*2))
		target.my_component_health.damage(damage*2)
		
	
	func cast_main(): #now runs all the excess that isn't affecting a specific target
		caster.my_component_vis.siphon(vis_cost)
	
	func cast_pre_mitigation(caster : Node, target : Node): #this it the spell run from the target's POV. It is run from the hit signal
		print_debug(caster.name, " ignited ", target.name,"!")
		if apply_status_success():
			target.my_component_ability.current_status_effects.add(status_burn.new(target,skillcheck_modifier*2,damage))
		target.my_component_health.damage(damage)
		
	func animation():
		caster.animations.tree.get("parameters/playback").travel("default_attack") #TODO make solar flare animation or FX

class ability_frigid_core:
	extends ability_template_default
	
	#TODO add status chance for this and solar flare
	
	func _init(caster : Node, damage : int = 1, chance : float = 0.3, vis_cost : int = 1) -> void:
		self.caster = caster
		self.damage = damage
		self.chance = chance
		self.vis_cost = vis_cost
		type = Battle.type.VOID
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
		title = "Frigid Core"
		description = "Summons a chilling pulse of frozen energy inside the target.\nHas a chance to freeze."
	
	func cast_main():
		pass
		#TODO add vis removal here
	
	func cast_pre_mitigation(caster : Node, target : Node):
		print_debug(caster.name, " froze ", target.name,"!")
		print_debug("It did ", round(skillcheck_modifier*damage), " damage!")
		target.my_component_health.damage(damage)
		target.my_component_ability.current_status_effects.add(status_freeze.new(target,skillcheck_modifier*1,1))
	
class ability_tackle: #Scales with skillcheck
	extends ability_template_default
	
	func _init(caster : Node, damage : int = 1) -> void:
		self.caster = caster
		self.damage = damage
		type = Battle.type.BALANCE
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
		title = "Tackle"
		description = "A forceful rush at the target, dealing damage"
	
	func cast_pre_mitigation(caster : Node, target : Node):
		print_debug(caster.name, " Tackled ", target.name,"!")
		print_debug("It did ", round(skillcheck_modifier*damage), " damage!")
		target.my_component_health.damage(skillcheck_modifier*damage)

class ability_headbutt: #Scales with damage multiplier
	extends ability_template_default
	
	func _init(caster : Node, damage : int = 1) -> void:
		self.caster = caster
		self.damage = damage
		type = Battle.type.BALANCE
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
		title = "Headbutt"
		description = "Charges the target, dealing damage"
	
	func cast_pre_mitigation(caster : Node, target : Node):
		var mult = caster.my_component_ability.stats.damage_multiplier
		print_debug(caster.name, " Charged ", target.name,"!")
		print_debug("It did ", round(damage*mult), " damage!")
		target.my_component_health.damage(damage*mult)

class ability_heartstitch:
	extends ability_template_default
	
	var old_targets : Array = []

	func _init(caster : Node) -> void:
		self.caster = caster
		target_selector = Battle.target_selector.SINGLE_RIGHT
		target_type = Battle.target_type.OPPONENTS
		type = Battle.type.TETHER
		title = "Heart-stitch"
		description = "Binds the life essence of two targets together, causing them to share all health changes for a limited time"
		damage = 1
		vis_cost = 1
	
	func cast_main():
		caster.my_component_vis.siphon(vis_cost)
		for i in len(old_targets): #remove instances from old targets
			if old_targets[i] not in targets and is_instance_valid(old_targets[i]) and old_targets[i]: #if old target is alive and not in current targets
				var teth = old_targets[i].my_component_ability.current_status_effects.TETHER
				if teth and teth is status_heartstitch: #If we find they still have our old buff
					old_targets[i].my_component_ability.current_status_effects.remove(old_targets[i].my_component_ability.current_status_effects.TETHER)
		old_targets = targets
	
	func cast_pre_mitigation(caster : Node, target : Node):
		if target in targets:
			print_debug(caster.name, " tried to stitch ", target.name,"!")
			target.my_component_health.damage(damage,true)
			target.my_component_ability.current_status_effects.add(status_heartstitch.new(target,targets,skillcheck_modifier*2))
	
	func animation():
		caster.animations.tree.get("parameters/playback").travel("default_attack") #TODO

class ability_switchstitch:
	extends ability_template_default
	
	func _init(caster : Node) -> void:
		self.caster = caster
		target_selector = Battle.target_selector.SINGLE_RIGHT
		target_type = Battle.target_type.OPPONENTS
		type = Battle.type.FLOW
		title = "Switch-stitch"
		description = "Forces two targeted enemies to swap positions"
		damage = 1
		vis_cost = 1
	
	func cast_main():
		caster.my_component_vis.siphon(vis_cost)
	
	func cast_pre_mitigation(caster : Node, target : Node):
		if target == primary_target:
			var index_start = Battle.battle_list.find(targets.front())
			var index_end = Battle.battle_list.find(targets.back())
			Battle.swap_section(index_start,index_end)
			
			for i in len(targets): #Only damages if the primary target tanks the damage
				targets[i].my_component_health.damage(damage)
			
			Battle.update_positions()
		
