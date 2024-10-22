class_name component_ability
extends Node

@onready var caster : Node = owner
@onready var cast_queue : Object = null

#We will not assign spells this way, might need to fix tho, hard to set em up without all the vars right in front of you FIXME
@onready var my_abilities : Array = [ability_tackle.new(caster),ability.new(caster),ability.new(caster),ability.new(caster)]

#------------------------------------------------------------------------------
#DONT use name or owner, already taken
#HACK _init is where you store stuff you'd only need before battle, like damage, vis cost, etc
#HACK Don't store anything you can already access with the caster like target, health, etc

class ability:
	var caster : Node
	var title : String = "---"
	var skillcheck_modifier : float = 1.0
	var damage : int = 2
	var valid_targets : Array = ["foes","friends"] #who we can target
	var target : Node
	
	func _init(caster : Node) -> void:
		self.caster = caster
		
	func validate(): #run validations, check vis, health, etc
		var result = true
		return result
	
	func validate_failed():
		print_debug("Reason for failing goes here")
		#You can execute code here, run a Dialogic event to show them they can't use that, etc
	
	func skillcheck(result):
		skillcheck_modifier = result
		print_debug("Result of skillcheck is ",result)
	
	func cast():
		print_debug(caster.name," Stood there, menacingly")
		print_debug("It did ", round(skillcheck_modifier*damage), " damage!")
		
	func finished(): #are we done casting? Usually would be checking for animation_finished
		var result = true
		return result

class ability_tackle:
	extends ability
	
	func _init(caster : Node) -> void:
		self.caster = caster
		title = "Tackle"
		
	func cast():
		#TODO setup animations
		print_debug(caster.name, " Tackled ", target.name,"!")
		print_debug("It did ", round(skillcheck_modifier*damage), " damage!")
		if target.my_component_health:
			target.my_component_health.damage(damage)
		
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
