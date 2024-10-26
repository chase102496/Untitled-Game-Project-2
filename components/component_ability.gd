class_name component_ability
extends Node

@onready var cast_queue : Object = null
@onready var current_status_effect : Object = null

#We will not assign spells this way, might need to fix tho, hard to set em up without all the vars right in front of you 
@onready var my_abilities : Array = [ability_tackle.new(owner),ability.new(owner),ability.new(owner),ability.new(owner)]# FIXME starts blank
@onready var max_ability_count : int = 4
@onready var skillcheck_difficulty : float = 1.0

#------------------------------------------------------------------------------
#DONT use name or owner, already taken
#HACK _init is where you store stuff you'd only need way before battle, like damage, vis cost, etc

# - Functions - #
func add_status_effect(effect):
	if !current_status_effect:
		print_debug("!status added!")
		current_status_effect = effect
		effect.fx_add()
	else:
		print_debug("!already existing status effect!")

func remove_status_effect():
	if current_status_effect:
		print_debug("!status removed!")
		current_status_effect.fx_remove()
		current_status_effect = null
	else:
		print_debug("!no status effect to remove!")

# - Status Effects - #
class status:
	var host : Node #The owner of the status effect. Who to apply it to
	var duration : int
	var title : String
	var fx : Node
	
	func _init(host : Node) -> void:
		self.host = host
		self.title = "---"
	
	func on_duration():
		if duration > 0:
			duration -= 1
		else:
			on_remove()
			host.my_component_ability.remove_status_effect()
	
	func on_start(): #runs on start of turn
		pass
	
	func on_skillcheck(): #runs right before skillcheck
		pass
	
	func on_end(): #runs on end of turn
		pass
	
	func on_remove(): #runs when status effect expires
		print_debug(title," wore off for ",host.name,"!")
	
	func fx_add():
		pass
	
	func fx_remove():
		pass

class status_fear:
	extends status
	
	func _init(host : Node,duration : int) -> void:
		self.host = host
		self.duration = duration
		self.title = "Fear"
	
	func on_start():
		host.my_component_ability.skillcheck_difficulty += 1
	
	func fx_add():
		fx = Glossary.particle.fear.instantiate()
		host.sprite.add_child(fx)
		fx.global_position = host.sprite.global_position
	
	func fx_remove():
		fx.queue_free()
		fx = null

# - Abilities -

class ability:

	#These will be enums
	#Type of ability: Damage/Status/Utility(Heal, recover, cleanse)
	#valid_targets: Self/Foes/Friends/All/No target

	var skillcheck_modifier : int = 1
	var caster : Node
	var target : Node = null
	var valid_targets : Array = [Global.alignment.FRIENDS,Global.alignment.FOES] #who we can target, can be my team, enemy team, self, or none.
	
	var title : String = "---"
	var type : Dictionary = Global.type.EMPTY
	
	var damage : int = 0
	var vis_cost : int = 0
	
	var status_effect : bool = false
	
	func _init(caster : Node) -> void:
		self.caster = caster
	
	func select_validate(): #run validations, check vis, health, etc
		var result = false #default so we cannot use this move
		return result
	
	func select_validate_failed():
		print_debug("Can't do that")
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

class ability_spook:
	extends ability
	
	func _init(caster : Node) -> void:
		self.caster = caster
		self.type = Global.type.VOID
		title = "Spook"
		vis_cost = 2
	
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
	
	func select_validate():
		if caster.my_component_vis.vis >= vis_cost:
			return true
		else:
			return false
	
	func cast_main():
		print_debug(caster.name, " tried to spook ", target.name,"!")
		if skillcheck_modifier > 0:
			print_debug("It was successful!")
			caster.my_component_vis.siphon(vis_cost)
			target.my_component_ability.add_status_effect(status_fear.new(target,skillcheck_modifier*2)) #duration is 2x of modifier
			target.anim_tree.get("parameters/playback").travel("Hurt")
		else:
			print_debug("It failed!")
			
	func animation():
		caster.anim_tree.get("parameters/playback").travel("default_attack_spook")

class ability_tackle:
	extends ability
	
	func _init(caster : Node) -> void:
		self.caster = caster
		self.damage = 1
		self.type = Global.type.NEUTRAL
		title = "Tackle"
	
	func select_validate():
		if caster.my_component_vis.vis >= vis_cost:
			return true
		else:
			return false
	
	func select_validate_failed():
		print_debug("Not enough vis!")
	
	func cast_main():
		#TODO setup animations
		print_debug(caster.name, " Tackled ", target.name,"!")
		print_debug("It did ", round(skillcheck_modifier*damage), " damage!")
		target.my_component_health.damage(skillcheck_modifier*damage)
		caster.my_component_vis.siphon(vis_cost)
		
		#how do I handle damage? call the target's function here? or...?
	#
	#TODO put spell here, grab owner's multipliers for POWER or whatever and put FIXED damage inside here under a var. Don't add it as a passthrough. Only passthrough should be target in the instantiation of the class
	#TODO make vis system where we check to make sure we have enough vis in the CAST function of the spell! Then we can start integrating the state chart system and how it will interact with the abilities.
