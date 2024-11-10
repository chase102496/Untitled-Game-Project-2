class_name component_ability
extends Node

@export var my_component_status : component_status

@onready var cast_queue : Object = null

@onready var current_status_effects : Object = status_manager.new()

#We will not assign spells this way, might need to fix tho, hard to set em up without all the vars right in front of you 
@onready var my_abilities : Array = [ability_tackle.new(owner),ability.new(owner),ability.new(owner),ability.new(owner)]# FIXME starts blank
@onready var max_ability_count : int = 4
var skillcheck_difficulty : float = 1.0

func _ready() -> void:
	pass
#------------------------------------------------------------------------------
#DONT use name or owner, already taken
#HACK _init is where you store stuff you'd only need way before battle, like damage, vis cost, etc

# - Functions - #

class status_manager:

	var NORMAL #they can overwrite eachother based on priority
	var TETHER #Primarily for Lumia's stitch mechanic
	var PASSIVE : Array = [] #Primarily for semi-permanent status effects that start at battle initialize and don't interact with NORMAL and TETHER
	
	func add_passive(effect : Object) -> void:
		PASSIVE.append(effect)
		effect.fx_add()
		print_debug("!passive added!")
		
	func remove_passive(effect : Object) -> void:
		PASSIVE.pop_at(PASSIVE.find(effect))
		effect.fx_remove()
		print_debug("!passive removed!")
	
	#Normal add for non-lists
	func add(effect : Object, ignore_priorities : bool = false) -> void:
		var effect_str = effect.category
		var current_effect = get(effect_str)
		
		if !current_effect: #if there's no status effect
			set(effect_str,effect)
			effect.fx_add()
			print_debug("!status added!")
		elif current_effect.title == effect.title: #if they're the same status effect
				print_debug("!target status is equal to applied status!")
				match effect.behavior:
					Battle.status_behavior.STACK:
						current_effect.duration += effect.duration
						print_debug("!status duration increased!")
					Battle.status_behavior.RESET:
						remove(current_effect)
						set(effect_str,effect)
						effect.fx_add()
						print_debug("!status reapplied!")
					Battle.status_behavior.RESIST:
						print_debug("!status ignored!")
					_:
						push_error("ERROR, status behavior not found: ",effect.behavior)
		elif current_effect.priority < effect.priority or ignore_priorities: #if our new status effect has higher priority or ignores prio
			remove(current_effect)
			set(effect_str,effect)
			effect.fx_add()
			print_debug("!status overwritten!")
			print_debug("ignore_priorities = ",ignore_priorities)
		else:
			print_debug("!cannot overwrite current status effect!")
			
	#Normal remove for non-lists
	func remove(effect : Object) -> void:
		var effect_str = effect.category
		var current_effect = get(effect_str)

		if current_effect:
			effect.fx_remove()
			set(effect_str,null)
			print_debug("!status removed!")
		else:
			print_debug("!no status effect to remove!")

	func clear() -> void:
		print_debug("!removed all status effects!")
		if NORMAL:
			remove(NORMAL)
		if TETHER:
			remove(TETHER)

	func status_event(event : String, args : Array = []) -> void:
		if NORMAL and NORMAL.has_method(event):
			Callable(NORMAL,event).callv(args)
		if TETHER and TETHER.has_method(event):
			Callable(TETHER,event).callv(args)
		for i in len(PASSIVE):
			if PASSIVE[i] and PASSIVE[i].has_method(event):
				Callable(PASSIVE[i],event).callv(args)

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
	
	func _init(host : Node) -> void:
		self.host = host
	
	func on_start(): #runs on start of turn
		pass
	
	func on_skillcheck(): #runs right before skillcheck
		pass
	
	func on_battle_entity_hit(entity_caster : Node, entity_target : Node, ability : Object): #when someone gets hit (anyone)
		pass
	
	func on_host_health_change(entity,amount): #runs when the host of the status effect's health changes
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
		if duration > 0:
			duration -= 1
		else:
			on_expire()
	
	func on_expire():
		print_debug(title," wore off for ",host.name,"!")
		host.my_component_ability.current_status_effects.remove(self)

# NORMAL
class status_fear:
	extends status_template_default
	
	func _init(host : Node,duration : int) -> void:
		self.host = host
		self.duration = duration
		self.title = "Fear"
		self.priority = 1
	
	func on_start():
		host.my_component_ability.skillcheck_difficulty += 1
	
	func fx_add():
		fx = Glossary.particle.fear.instantiate()
		host.animations.sprite.add_child(fx)
		fx.global_position = host.animations.sprite.global_position
	
	func fx_remove():
		fx.queue_free()
		fx = null

class status_burn:
	extends status_template_default
	
	var damage : int
	
	func _init(host : Node,duration : int,damage : int) -> void:
		self.host = host
		self.duration = duration
		self.damage = damage
		self.title = "Burn"
	
	func on_end():
		host.my_component_health.damage(damage)
	
	func fx_add():
		fx = Glossary.particle.burn.instantiate()
		host.animations.sprite.add_child(fx)
		fx.global_position = host.animations.sprite.global_position
	
	func fx_remove():
		fx.queue_free()
		fx = null

# TETHER

class status_heartstitch:
	extends status_template_default
	
	var partners : Array
	#var fx2 : Node
	
	func _init(host : Node,partners : Array,duration : int) -> void:
		self.host = host #who is the initial target of the stitch
		self.partners = partners #who is paired to the host
		self.duration = duration
		behavior = Battle.status_behavior.RESET
		category = Battle.status_category.TETHER
		title = "Heartstitch"
	
	func on_host_health_change(entity,amount): #the bread n butta of heartstitch
		if entity == host and len(partners) > 1: #if person hurt was our host, and partners aint all ded
			for i in len(partners):
				if partners[i] != host and partners[i] in Battle.battle_list: #if it's not me and it's alive
					partners[i].my_component_health.damage(amount,true)
					print_debug(partners[i].name," took ",amount," points of mirror damage!")
	
	func on_death():
		pass
		#for i in len(partners):
			#if partners[i] != host: #remove us from all partners links except ours
				#var inst = partners[i].my_component_ability.current_status_effects.TETHER.partners
				#inst.pop_at(inst.find(host))
	
	func fx_add():
		fx = Glossary.ui.heartstitch.instantiate()
		host.status_hud.grid.add_child(fx)
	
	func fx_remove():
		fx.queue_free()
		fx = null

# PASSIVE

class status_thorns:
	extends status
	
	var damage : int
	
	func on_duration(): #overwrite duration, this doesn't expire
		pass
	
	func _init(host : Node,damage : int) -> void:
		self.host = host
		self.damage = damage
		category = Battle.status_category.PASSIVE
		title = "Thorns"
	
	func on_battle_entity_hit(entity_caster : Node, entity_target : Node, ability : Object):
		if entity_target == host:
			entity_caster.my_component_health.damage(damage)
			print_debug(host.name," reflected ",damage," damage back to ",entity_caster.name,"!")

# - Abilities - #
class ability:

	var skillcheck_modifier : int = 1
	var caster : Node
	var target : Node = null #TODO remove
	var targets : Array = []
	#Change this to a function (Callable type) that returns a list of whatever you want. Make the function in Battle
	var target_type : String = Battle.target_type.EVERYONE #Who we can target on the field
	var target_selector : String = Battle.target_selector.SINGLE #How many targets we select
	
	var title : String = "---"
	var type : Dictionary = Battle.type.EMPTY
	
	var damage : int = 0
	var vis_cost : int = 0
	
	func _init(caster : Node) -> void:
		self.caster = caster
	
	func select_validate(): #run validations, check vis, health, etc
		var result = false #default so we cannot use this move
		return result
	
	func select_validate_failed():
		print_debug("Can't do that")
		#You can execute code here, run a Dialogic event to show them they can't use that, etc
		#For example, if they don't have enough vis
	
	func skillcheck(result):
		pass
	
	func cast_validate():
		if skillcheck_modifier > 0:
			return true
		else:
			return false
			
	func cast_validate_failed():
		print_debug("Missed!")
		Glossary.create_text_particle(caster,caster.animations.sprite.global_position,str("Miss!"),"float_away",Color.WHITE)
	
	func cast_main(): #Main function, calls on hit
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
	
	func select_validate():
		if caster.my_component_vis.vis >= vis_cost:
			return true
		else:
			print_debug("Not enough Vis!")
			return false
	
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
	
	func _init(caster : Node) -> void:
		self.caster = caster
		type = Battle.type.VOID
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
		title = "Spook"
		vis_cost = 2
		damage = 1

	func cast_main():
		if skillcheck_modifier > 0:
			print_debug("It was successful!")
			caster.my_component_vis.siphon(vis_cost)
			for i in len(targets):
				print_debug(caster.name, " tried to spook ", targets[i].name,"!")
				targets[i].my_component_health.damage(damage) #Flat damage
				targets[i].my_component_ability.current_status_effects.add(status_fear.new(targets[i],skillcheck_modifier*2)) #duration is 2x of modifier
		else:
			cast_validate_failed()
			
	func animation():
		caster.animations.tree.get("parameters/playback").travel("default_attack_spook")

class ability_solar_flare:
	extends ability_template_default
	
	func _init(caster : Node) -> void:
		self.caster = caster
		type = Battle.type.NOVA
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
		title = "Solar Flare"
		vis_cost = 2
		damage = 1
	
	func cast_main():
		if skillcheck_modifier > 0:
			caster.my_component_vis.siphon(vis_cost)
			for i in len(targets):
				print_debug(caster.name, " ignited ", targets[i].name,"!")
				targets[i].my_component_health.damage(damage) #Flat damage
				targets[i].my_component_ability.current_status_effects.add(status_burn.new(targets[i],skillcheck_modifier*2,1))
		else:
			cast_validate_failed()
			
	func animation():
		caster.animations.tree.get("parameters/playback").travel("default_attack") #TODO make solar flare animation or FX

class ability_tackle:
	extends ability_template_default
	
	func _init(caster : Node) -> void:
		self.caster = caster
		damage = 1
		type = Battle.type.NEUTRAL
		target_selector = Battle.target_selector.SINGLE
		target_type = Battle.target_type.OPPONENTS
		title = "Tackle"
	
	func cast_main():
		if skillcheck_modifier > 0:
			caster.my_component_vis.siphon(vis_cost)
			for i in len(targets):
				print_debug(caster.name, " Tackled ", targets[i].name,"!")
				print_debug("It did ", round(skillcheck_modifier*damage), " damage!")
				targets[i].my_component_health.damage(skillcheck_modifier*damage)
		else:
			cast_validate_failed()

class ability_heartstitch:
	extends ability_template_default
	
	var old_targets : Array = []

	func _init(caster : Node) -> void:
		self.caster = caster
		target_selector = Battle.target_selector.SINGLE_RIGHT
		target_type = Battle.target_type.OPPONENTS
		type = Battle.type.VOID
		title = "Heartstitch"
		vis_cost = 2
		damage = 1
	
	func cast_main():
		print_debug(caster.name, " tried to stitch ", targets[0].name,"!")
		if skillcheck_modifier > 0:
			print_debug("It was successful!")
			caster.my_component_vis.siphon(vis_cost)
			
			for i in len(targets):
				targets[i].my_component_health.damage(damage) #Flat damage
				
				var effect = targets[i].my_component_ability.current_status_effects #status manager for target
				effect.add(status_heartstitch.new(targets[i],targets,skillcheck_modifier*1)) #attempt to add status
			#
			for i in len(old_targets): #remove instances from old targets
				if is_instance_valid(old_targets[i]) and old_targets[i] not in targets: #if old target is alive and not in current targets
					if old_targets[i].my_component_ability.current_status_effects.TETHER.title == title: #If we find they still have our old buff
						old_targets[i].my_component_ability.current_status_effects.remove(old_targets[i].my_component_ability.current_status_effects.TETHER) #remove
			
			old_targets = targets
		else:
			print_debug("It failed!")
	
	func animation():
		caster.animations.tree.get("parameters/playback").travel("default_attack") #TODO
