class_name component_equipment
extends Node3D

@export var gloam_manager : Node3D

@export var active_interact_area : component_interact_controller

@onready var dreamstitch : ability_dreamstitch = ability_heartlink.new(owner)
@onready var loomlight : ability_loomlight = ability_loomlight.new(owner)
@onready var active : ability = dreamstitch

var active_interact_area_memory : Area3D

func _ready() -> void:
	active_interact_area.area_entered.connect(_on_active_interact_area_entered)
	active_interact_area.area_exited.connect(_on_active_interact_area_exited)

## --- Events --- ##

func _on_active_interact_area_entered(area : Area3D) -> void:
	active_interact_area_memory = area
	ability_event(active,"on_area_entered",[area])

func _on_active_interact_area_exited(area : Area3D) -> void:
	active_interact_area_memory = area
	ability_event(active,"on_area_exited",[area])

func refresh_equipment_interact_areas(old_ability : ability, new_ability : ability) -> void:
	#if we have memory of a collision and if we overlap our most recent area still
	if active_interact_area_memory and active_interact_area.overlaps_area(active_interact_area_memory):
		ability_event(old_ability,"on_area_exited",[active_interact_area_memory])
		ability_event(new_ability,"on_area_entered",[active_interact_area_memory])

func ability_use() -> void:
	ability_event(active,"on_use")

## --- Utility Functions --- ###

## Let our current ability know this event is being called.
## It doesn't have to do something, but we check just in case it exists
## For example, running code when walking, near a certain object, press a certain button, etc.
## Can use "my_component_equipment.active" or dreamstitch or loomlight for new_ability
func ability_event(new_ability : ability, method : String, args : Array = []) -> Variant:
	if new_ability:
		if new_ability.has_method(method):
			return new_ability.callv(method,args)
		else:
			#print_debug("Ability ignoring event : ",new_ability," ",method) #This will happen sometimes, not an error
			return false
	else:
		#print_debug("Ability is null, no event triggered : ",new_ability," ",method) #This happens if we have no equipment to use, also not an error
		return false

func ability_unequip_active() -> void:
	if active:
		if active.verify_unequip():
			active.on_unequip()
			refresh_equipment_interact_areas(active,null)
			active = null
		else:
			print_debug("Unable to unequip ",active)
	else:
		print_debug("Nothing to unequip")

## Swaps from dreamstitch to loomlight, or vice versa
func ability_switch_active_toggle() -> void:
	if active == dreamstitch:
		ability_switch_active(loomlight)
	elif active == loomlight:
		ability_switch_active(dreamstitch)
	elif !active:
		if loomlight:
			ability_switch_active(loomlight)
		elif dreamstitch:
			ability_switch_active(dreamstitch)
		else:
			print_debug("No equipment available to swap to or from!")
	else:
		print_debug("Invalid or old active equipment, not sure what to swap to: ",active)
		

func ability_switch_active(new_ability : ability) -> void:
	if new_ability:
		if new_ability != active: #If we have a new ability, and if we're not swapping to something we already have equipped
			
			if !active or active.verify_unequip(): #If we have no active equipment, or we have an active equipment and it is verified to unequip
					if new_ability.verify_equip(): #If we can equip our new equipment
						if new_ability in [loomlight,dreamstitch]: #If it's in our active equipment
							ability_event(active,"on_unequip") #Unequip current
							ability_event(new_ability,"on_equip") #Equip new
							#If we overlap an interact area, refresh our old and new equipment to run exit on old and enter on new
							refresh_equipment_interact_areas(active,new_ability)
							active = new_ability #Update var
						else:
							push_error("Ability not in equipment! ",new_ability)
					else:
						print_debug("Unable to equip new ability, verification failed! ",new_ability)
		else:
			print_debug("Ability already equipped! ",new_ability)
	else:
		ability_unequip_active() #We are swapping to an empty slot, so just unequip active

## --- Ability Classes --- ##

## What we form the basis of all of our world abilities off of.
class ability:
	
	var title : String = "Empty Ability"
	var caster : Node
	var interact_groups : Array
	var my_interact_area : Area3D
	var my_interact_area_shape : CollisionShape3D
	
	var fx_instance : GPUParticles3D
	
	var current_interaction_areas : Array = []
	
	func _init(caster : Node) -> void:
		self.caster = caster
		my_interact_area = caster.my_component_equipment.active_interact_area
		my_interact_area_shape = caster.my_component_equipment.active_interact_area.shape
	
	## --- FX --- ##
	
	func fx_interactable() -> void:
		fx_clear()
		#fx_instance = instantiate()
		pass
	
	func fx_use() -> void:
		fx_clear()
		#fx_instance = instantiate()
		pass
	
	func fx_clear() -> void:
		if fx_instance:
			fx_instance.queue_free()
	
	## --- Interaction --- ##
	
	# Checks if it should be interactable with our current ability
	func verify_area(area : Area3D) -> bool:
		if Global.inner_join(area.get_groups(),interact_groups).size() > 0:
			return true
		return false
	
	func on_area_entered(area : Area3D) -> void:
		if verify_area(area):
			if area.has_signal("enter"):
				area.enter.emit(caster) #Let it know we entered
				current_interaction_areas.append(area) #Add it to our collider list
				#print_debug("EQUIPMENT EVENT: ",title," entered ",area.name)
	
	func on_area_exited(area : Area3D) -> void:
		if verify_area(area):
			if area.has_signal("exit"):
				area.exit.emit(caster) #Let it know we exited
				current_interaction_areas.pop_at(current_interaction_areas.find(area))
				#print_debug("EQUIPMENT EVENT: ",title," exited ",area.name)
	
	## --- Use --- ##
	
	# Checks if we can actually use our ability, now that there is a matching area to use it on
	# Can check internal conditionals like vis, etc
	func verify_use() -> bool:
		return true
	
	func on_use() -> void:
		if verify_use():
			for area in current_interaction_areas:
				if area.has_signal("interact"):
					area.interact.emit(caster)
					#print_debug("EQUIPMENT EVENT: ",title," interacted with ",area.name)
		else:
			print_debug("Use verification failed for ",title)
	
	## --- Equip --- ##
	
	func verify_equip() -> bool:
		#conditions when checking if we can equip this (as in swapped to being in our hand)
		return true
	
	func verify_unequip() -> bool:
		#conditions when checking if we can unequip this (as in swapped to being out of our hand)
		return true
	
	func on_equip():
		pass
		
	func on_unequip():
		pass

## Template super for all dreamstitch abilities
class ability_dreamstitch:
	extends ability
	
	func _init(caster : Node) -> void:
		super._init(caster)
		title = "Empty Dreamstitch Ability"
		interact_groups.append("interact_ability_dreamstitch")

## Template super for all loomlight abilities
class ability_loomlight:
	extends ability
	
	var color : Color = Color("ffebdb") #Determines color of lantern
	var size : float = 2.2 #Determines size of gloam cleared with lantern and also range of light in lantern
	var light_strength : float = 1 #Determines brightness of lantern
	
	var tween_light_strength : Tween
	var tween_size : Tween
		
		#We can directly connect to signals just like the _ready() function!!!
		#And define the function to call on signaling here!!
	
	func _init(caster : Node) -> void:
		super._init(caster)
		title = "Empty Loomlight Ability"
		interact_groups.append("interact_ability_loomlight")
	
	func tween_init() -> void:
		if tween_light_strength:
			tween_light_strength.kill()
		if tween_size:
			tween_size.kill()
		tween_light_strength = caster.gloam_manager.create_tween()
		tween_size = caster.gloam_manager.create_tween()
	
	## - Equip events - ##
	
	func verify_unequip() -> bool:
		if caster.gloam_manager.is_inside_gloam:
			return false
		else:
			return true
	
	## When we request to equip
	func on_equip():
		caster.gloam_manager.light.light_color = color #Update color
		caster.gloam_manager.light.omni_range = size*2 #Update range
		
		tween_init()
		tween_light_strength.tween_property(caster.gloam_manager.light,"light_energy",light_strength,1) #Visual light tween
		tween_size.tween_property(caster.gloam_manager.my_fog,"size",Vector3(size,size,size),1) #Visual gleam tween
		
		caster.set_collision_layer_value(3,false) #Allows traversal through gloam
		caster.set_collision_mask_value(3,false) #Allows traversal through gloam
	
	## When we request to unequip
	func on_unequip():
		tween_init()
		tween_light_strength.tween_property(caster.gloam_manager.light,"light_energy",0,0.5) #Visual light tween
		tween_size.tween_property(caster.gloam_manager.my_fog,"size",Vector3.ZERO,1) #Visual gleam tween
		
		caster.set_collision_layer_value(3,true) #Disallows traversal through gloam
		caster.set_collision_mask_value(3,true) #Disallows traversal through gloam

## --- Equipment Abilties --- ##

# Loomlight

class ability_purge: # TBD
	extends ability_loomlight
	
	func _init(caster : Node) -> void:
		super._init(caster)
		interact_groups.append("interact_ability_purge")
		#color = Color("ff0004")
		title = "Purge"
		
	## - Equip events - ##
	
	## - Active events - ##
	
	#Used for abilities that require a specific condition
	#Check here to see if we're in range to affect something with purge, if we are, return true
	#We can also show an effect or prompt here to indicate you can use this ability
	
	func on_usable_fx(target : Node = null) -> void:
		pass
	
	#Just fx for when we use the ability
	func on_use_fx(target : Node) -> void:
		pass

# Dreamstitch

class ability_heartlink:
	extends ability_dreamstitch
	
	var heartlink_max : int = 2
	
	func _init(caster : Node) -> void:
		super._init(caster)
		title = "Dreamstitch"
		interact_groups.append("interact_ability_heartlink")
	
	func verify_use() -> bool:
		## If we can still add heartlinks
		if caster.get_tree().get_nodes_in_group("interact_ability_heartlink_active").size() < heartlink_max and current_interaction_areas.size() > 0:
			return true
		else:
			return false
		
	func on_use() -> void:
		## If we're trying to link a controller
		if verify_use():
			for area in current_interaction_areas: #Runs through all verified areas in "interact_ability_heartlink"
				## Add first one we find to our heartlink active group
				if !area.my_component_impulse_controller.is_in_group("interact_ability_heartlink_active"):
					#emit heartlink signal to add it
					area.my_component_impulse_controller.add_to_group("interact_ability_heartlink_active")
					return
		## If we are trying to clear our heartlink actives
		else:
			for controller in caster.get_tree().get_nodes_in_group("interact_ability_heartlink_active"):
				controller.remove_from_group("interact_ability_heartlink_active")

class ability_gustbloom: #TBD
	extends ability_dreamstitch
	
	func _init(caster : Node) -> void:
		super._init(caster)
		title = "Gustbloom"
		interact_groups.append("interact_ability_gustbloom")
