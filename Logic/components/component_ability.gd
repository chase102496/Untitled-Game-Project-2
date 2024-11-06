class_name component_ability
extends Node

@export var my_component_status : component_status

@onready var cast_queue : Object = null

@onready var current_status_effect : Object = status_manager.new()
#@onready var current_status_effect_2 : Object = status_manager.new()

#We will not assign spells this way, might need to fix tho, hard to set em up without all the vars right in front of you 
@onready var my_abilities : Array = [ability_tackle.new(owner),ability.new(owner),ability.new(owner),ability.new(owner)]# FIXME starts blank
@onready var max_ability_count : int = 4
@onready var skillcheck_difficulty : float = 1.0

func _ready() -> void:
	#current_status_effect_2.NORMAL = status.new(Global.player)
	#current_status_effect_2.status_event("test")
	pass
#------------------------------------------------------------------------------
#DONT use name or owner, already taken
#HACK _init is where you store stuff you'd only need way before battle, like damage, vis cost, etc

# - Functions - #
#Global.status_type.NORMAL, TETHER and SOULBOUND
#NORMAL is just normal status effects, they can overwrite eachother based on priority
#TETHER is an ability based binding, that ties one unit to another in some way
#SOULBOUND is a permanent version of TETHER that persists through battle

class status_manager:
	var NORMAL #Buffs, debuffs, DoT, etc.
	var TETHER #Primarily for Lumia's stitch mechanic
	var SOULBOUND #Primarily for permanent bonds that start at battle initialize
	
	func add(effect : Object):
		#check if they have a partner with the buff NAH
		match effect.category:
			"NORMAL":
				if !NORMAL:
					NORMAL = effect
					effect.fx_add()
					print_debug("!status added!")
				elif NORMAL.priority < effect.priority:
					remove(NORMAL)
					NORMAL = effect
					effect.fx_add()
					print_debug("!status overwritten!")
				else:
					print_debug("!cannot overwrite current status effect, it's too strong!")
			"TETHER":
				if !TETHER:
					TETHER = effect
					effect.fx_add()
					print_debug("!status added!")
				elif TETHER.priority < effect.priority:
					remove(TETHER)
					TETHER = effect
					effect.fx_add()
					print_debug("!status overwritten!")
				else:
					print_debug("!cannot overwrite current status effect, it's too strong!")
			"SOULBOUND":
				if !SOULBOUND:
					SOULBOUND = effect
					effect.fx_add()
					print_debug("!status added!")
				elif SOULBOUND.priority < effect.priority:
					remove(SOULBOUND)
					SOULBOUND = effect
					effect.fx_add()
					print_debug("!status overwritten!")
				else:
					print_debug("!cannot overwrite current status effect, it's too strong!")
			_:
				push_error("COULD NOT ADD ",effect," TO ",effect.category)
	
	func remove(effect : Object):
		match effect.category:
			"NORMAL":
				if NORMAL:
					print_debug("!status removed!")
					NORMAL.fx_remove()
					NORMAL = null
				else:
					print_debug("!no status effect to remove!")
			"TETHER":
				if TETHER:
					print_debug("!status removed!")
					TETHER.fx_remove()
					TETHER = null
				else:
					print_debug("!no status effect to remove!")
			"SOULBOUND":
				if SOULBOUND:
					print_debug("!status removed!")
					SOULBOUND.fx_remove()
					SOULBOUND = null
				else:
					print_debug("!no status effect to remove!")
			_:
				push_error("COULD NOT REMOVE ",effect," TO ",effect.category)

	func status_event(event : String, arg1 = null, arg2 = null, arg3 = null):
		if NORMAL and NORMAL.has_method(event):
			if arg3:
				Callable(NORMAL,event).call(arg1,arg2,arg3)
			elif arg2:
				Callable(NORMAL,event).call(arg1,arg2)
			elif arg1:
				Callable(NORMAL,event).call(arg1)
			else:
				Callable(NORMAL,event).call()
		if TETHER and TETHER.has_method(event):
			if arg3:
				Callable(TETHER,event).call(arg1,arg2,arg3)
			elif arg2:
				Callable(TETHER,event).call(arg1,arg2)
			elif arg1:
				Callable(TETHER,event).call(arg1)
			else:
				Callable(TETHER,event).call()
		if SOULBOUND and SOULBOUND.has_method(event):
			if arg3:
				Callable(SOULBOUND,event).call(arg1,arg2,arg3)
			elif arg2:
				Callable(SOULBOUND,event).call(arg1,arg2)
			elif arg1:
				Callable(SOULBOUND,event).call(arg1)
			else:
				Callable(SOULBOUND,event).call()

#need to make a tether class and then subclasses based on what to do with the tether
#one called tether_heart which shares damage between the two
#one called tether_undying which makes the target check if its partner is dead before truly dying, and if not, "revive" to full health
#	should play death animation and stay in it until the next start() and then revive and reset to full
#

# - Status Effects - #
class status:
	var host : Node #The owner of the status effect. Who to apply it to
	var category : String = "NORMAL"
	var duration : int #How many turns it lasts
	var title : String = "---"
	var fx : Node #Visual fx
	var priority : int = 0 #Whether a buff can overwrite it. Higher means it can
	
	func _init(host : Node) -> void:
		self.host = host
	
	func test():
		print("SUCCESS")
	
	func on_duration():
		if duration > 0:
			duration -= 1
		else:
			on_remove()
	
	func on_start(): #runs on start of turn
		pass
	
	func on_skillcheck(): #runs right before skillcheck
		pass
	
	func on_target_hit(): #runs right after we attack someone
		pass
	
	func on_host_health_change(entity,amount): #runs when the host of the status effect's health changes
		pass
	
	func on_end(): #runs on end of turn
		pass
	
	func on_remove(): #runs when status effect expires
		print_debug(title," wore off for ",host.name,"!")
		host.my_component_ability.current_status_effect.remove(self)
	
	func fx_add():
		pass
	
	func fx_remove():
		pass
# ---

# NORMAL
class status_fear:
	extends status
	
	func _init(host : Node,duration : int) -> void:
		self.host = host
		self.duration = duration
		self.title = "Fear"
		self.priority = 1
	
	func on_start():
		host.my_component_ability.skillcheck_difficulty += 1
	
	func fx_add():
		fx = Glossary.particle.fear.instantiate()
		host.sprite.add_child(fx)
		fx.global_position = host.sprite.global_position
	
	func fx_remove():
		fx.queue_free()
		fx = null

class status_burn:
	extends status
	
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
		host.sprite.add_child(fx)
		fx.global_position = host.sprite.global_position
	
	func fx_remove():
		fx.queue_free()
		fx = null

# TETHER

class status_tether_heart:
	extends status
	
	var partner : Node
	var fx2 : Node
	
	func _init(host : Node,partner : Node,duration : int) -> void:
		self.host = host #who is the initial target of the stitch
		self.partner = partner #who is paired to the host
		self.duration = duration
		self.category = "TETHER"
		self.title = "Heart Stitch"
	
	func on_host_health_change(entity,amount): #the bread n butta of heartstitch
		if entity == host: #if person hurt was our host
			partner.my_component_health.damage(amount,true) #TODO mirror damage to our partner
			print_debug(partner.name," took ",amount," points of mirror damage!")
		elif entity == partner: #if person was our partner
			host.my_component_health.damage(amount,true) #TODO mirror damage to our host
			print_debug(host.name," took ",amount," points of mirror damage!")
	
	func fx_add():
		fx = Glossary.particle.burn.instantiate() #TODO make particle
		fx2 = Glossary.particle.burn.instantiate()
		host.sprite.add_child(fx)
		partner.sprite.add_child(fx2)
		fx.global_position = host.sprite.global_position
		fx2.global_position = partner.sprite.global_position
	
	func fx_remove():
		fx.queue_free()
		fx2.queue_free()
		fx = null
		fx2 = null

# - Abilities - #
class ability:

	var skillcheck_modifier : int = 1
	var caster : Node
	var target : Node = null
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
		#print_debug("Can't do that")
		#You can execute code here, run a Dialogic event to show them they can't use that, etc
		pass
	
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
			skillcheck_modifier = 1
		
		print_debug("Result of skillcheck is ",result)
	
	func cast_validate():
		if skillcheck_modifier > 0:
			return true
		else:
			return false
			
	func cast_validate_failed():
		print_debug("Missed!")
	
	func cast_main(): #Main function, calls on hit
		pass
	
	func animation():
		caster.anim_tree.get("parameters/playback").travel("default_attack")
	
	#Put status effect in here, and when we cast, we add our spell to their status_effects array based on conditions (only one status at a time, if it's used we send a message saying they're immune)
	#They run their normal course, but are "infected" with our functions. Now the empty method calls 
	#when they were healthy will reference any calls in our spell's vocab and we don't have to do anything on character-side
	#E.g. Poison spell
	#Has function status_effect_on_start
# ---

class ability_template_default: #Standard ability with vis cost and skillcheck
	extends ability
	
	func select_validate():
		if caster.my_component_vis.vis >= vis_cost:
			return true
		else:
			print_debug("Not enough Vis!")
			return false
	
	func skillcheck(result): #TODO make categories of skillchecks to extend from
		if result == "Miss":
			skillcheck_modifier = 0
		elif result == "Good":
			skillcheck_modifier = 1
		elif result == "Great":
			skillcheck_modifier = 2
		elif result == "Excellent":
			skillcheck_modifier = 3
		else:
			skillcheck_modifier = 1

class ability_spook:
	extends ability_template_default
	
	func _init(caster : Node) -> void:
		self.caster = caster
		type = Battle.type.VOID
		title = "Spook"
		vis_cost = 2
		damage = 1

	func cast_main():
		print_debug(caster.name, " tried to spook ", target.name,"!")
		if skillcheck_modifier > 0:
			print_debug("It was successful!")
			caster.my_component_vis.siphon(vis_cost)
			target.my_component_health.damage(damage) #Flat damage
			target.my_component_ability.current_status_effect.add(status_fear.new(target,skillcheck_modifier*2)) #duration is 2x of modifier
		else:
			print_debug("It failed!")
			
	func animation():
		caster.anim_tree.get("parameters/playback").travel("default_attack_spook")

class ability_solar_flare:
	extends ability_template_default
	
	func _init(caster : Node) -> void:
		self.caster = caster
		type = Battle.type.NOVA
		title = "Solar Flare"
		vis_cost = 2
		damage = 1
	
	func cast_main():
		print_debug(caster.name, " tried to ignite ", target.name,"!")
		if skillcheck_modifier > 0:
			print_debug("It was successful!")
			caster.my_component_vis.siphon(vis_cost)
			target.my_component_health.damage(damage) #Flat damage
			target.my_component_ability.current_status_effect.add(status_burn.new(target,skillcheck_modifier*2,1))
			target.state_chart.send_event("on_hurt")
		else:
			print_debug("It failed!")
			
	func animation():
		caster.anim_tree.get("parameters/playback").travel("default_attack") #TODO make solar flare animation or FX

class ability_tackle:
	extends ability_template_default
	
	func _init(caster : Node) -> void:
		self.caster = caster
		self.damage = 1
		self.type = Battle.type.NEUTRAL
		title = "Tackle"
	
	func cast_main():
		#TODO setup animations
		print_debug(caster.name, " Tackled ", target.name,"!")
		print_debug("It did ", round(skillcheck_modifier*damage), " damage!")
		target.my_component_health.damage(skillcheck_modifier*damage)
		caster.my_component_vis.siphon(vis_cost)

class ability_heart_stitch:
	extends ability_template_default
	
	func _init(caster : Node) -> void:
		self.caster = caster
		type = Battle.type.VOID
		title = "Heartstitch"
		vis_cost = 2
		damage = 1
	
	func cast_main():
		print_debug(caster.name, " tried to stitch ", target.name,"!") #TODO
		if skillcheck_modifier > 0:
			print_debug("It was successful!")
			caster.my_component_vis.siphon(vis_cost)
			target.my_component_health.damage(damage) #Flat damage
			target.my_component_ability.current_status_effect.add(status_tether_heart.new(target,caster,skillcheck_modifier*1))
			target.state_chart.send_event("on_hurt")
		else:
			print_debug("It failed!")
			
	func animation():
		caster.anim_tree.get("parameters/playback").travel("default_attack") #TODO
