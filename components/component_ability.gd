class_name component_ability
extends Node

@onready var caster : Node = owner
@onready var cast_queue : Object = null

#We will not assign spells this way, might need to fix tho, hard to set em up without all the vars right in front of you 
@onready var my_abilities : Array = [ability_tackle.new(caster),ability.new(caster),ability.new(caster),ability.new(caster)]# FIXME starts blank
@onready var max_ability_count : int = 4

#------------------------------------------------------------------------------
#DONT use name or owner, already taken
#HACK _init is where you store stuff you'd only need way before battle, like damage, vis cost, etc
#HACK Don't store anything you can already access with the caster like target, health, etc
class ability:

	#These will be enums
	#Type of ability: Damage/Status/Utility(Heal, recover, cleanse)
	#valid_targets: Self/Foes/Friends/All/No target

	var skillcheck_modifier : int = 1
	var caster : Node
	var target : Node = null
	var valid_targets : Array = ["foes","friends"] #who we can target, can be foes, friends, self, or none. Let's make it an enum later
	
	var title : String = "---"
	
	var damage : int = 1
	
	var status_effect : bool = false
	
	func _init(caster : Node) -> void:
		self.caster = caster
	
	func select_validate(): #run validations, check vis, health, etc
		var result = false #default so we cannot use this move
		return result
	
	func select_validate_failed():
		print_debug("Not a valid move")
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
		print_debug(caster.name," Stood there, menacingly")
		print_debug("It did ", round(skillcheck_modifier*damage), " damage!")
	
	func cast_status():
		pass
	
	func animation():
		caster.anim_tree.get("parameters/playback").travel("Attack")
	
	#Put status effect in here, and when we cast, we add our spell to their status_effects array based on conditions (only one status at a time, if it's used we send a message saying they're immune)
	#They run their normal course, but are "infected" with our functions. Now the empty method calls 
	#when they were healthy will reference any calls in our spell's vocab and we don't have to do anything on character-side
	#E.g. Poison spell
	#Has function status_effect_on_start

class ability_spook:
	extends ability
	
	func _init(caster : Node) -> void:
		self.caster = caster
		title = "Spook"
	
	func select_validate():
		var result = true
		return result
	
	func cast_main():
		
		#TODO setup animations
		print_debug(caster.name, " tried to spook ", target.name,"!")
		print_debug("It was ", round(skillcheck_modifier*damage), " damage!")
		if target.my_component_health:
			target.my_component_health.damage(skillcheck_modifier*damage)
		
class ability_tackle:
	extends ability
	
	func _init(caster : Node) -> void:
		self.caster = caster
		title = "Tackle"
	
	func select_validate():
		var result = true
		return result
	
	func cast_main():
		#TODO setup animations
		print_debug(caster.name, " Tackled ", target.name,"!")
		print_debug("It did ", round(skillcheck_modifier*damage), " damage!")
		if target.my_component_health:
			target.my_component_health.damage(skillcheck_modifier*damage)
		
		#how do I handle damage? call the target's function here? or...?
	#
	#TODO put spell here, grab owner's multipliers for POWER or whatever and put FIXED damage inside here under a var. Don't add it as a passthrough. Only passthrough should be target in the instantiation of the class
	#TODO make vis system where we check to make sure we have enough vis in the CAST function of the spell! Then we can start integrating the state chart system and how it will interact with the abilities.
	#var target : Object
	#var damage : int
	#
	#func cast(target, damage):
		#print(caster.desc," used Tackle for ",damage," damage!")
		#if target.my_component_health:
			#target.my_component_health.damage(damage)
