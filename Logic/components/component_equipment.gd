class_name component_equipment
extends component_node_3d

@export var gloam_manager : Node3D

@export var active_interact_area : component_interact_controller

@onready var dreamstitch : ability_dreamstitch = ability_soulstitch.new(owner)
@onready var loomlight : ability_loomlight = ability_loomlight.new(owner)
@onready var active : ability = dreamstitch

var active_interact_area_memory : Area3D

func _ready() -> void:
	active_interact_area.area_entered.connect(_on_active_interact_area_entered)
	active_interact_area.area_exited.connect(_on_active_interact_area_exited)

## --- Events --- ##

## When entering a interaction reciever with our interaction controller
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

## Lets our current ability know this event is being called.
## It doesn't have to do something, but we check just in case it exists
## For example, running code when walking, near a certain object, press a certain button, etc.
## Can use "my_component_equipment.active", "my_component_equipment.dreamstitch", or "my_component_equipment.loomlight" for new_ability
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
func toggle_active() -> void:
	if active == dreamstitch:
		switch_active(loomlight)
	elif active == loomlight:
		switch_active(dreamstitch)
	elif !active:
		if loomlight:
			switch_active(loomlight)
		elif dreamstitch:
			switch_active(dreamstitch)
		else:
			print_debug("No equipment available to swap to or from!")
	else:
		print_debug("Invalid or old active equipment, not sure what to swap to: ",active)

func switch_active(new_ability : ability) -> void:
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
		if caster.gloam_manager.is_inside_gloam():
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

class ability_soulstitch:
	extends ability_dreamstitch
	
	var is_mark_placed : bool = false
	var mark_location : Vector3
	var recall_time : float = 0.5
	var recall_tween : Tween
	
	## Direction of recall
	var recall_direction : Vector3
	## Velocity right before reaching destination
	var recall_magnitude : float
	## This is just the direction and magnitude
	var recall_velocity : Vector3
	## Position when starting recall
	var recall_start : Vector3
	## Position right before reaching destination
	var recall_frame : Vector3
	## Time elapsed in recall the frame before reaching destination
	var recall_frame_time : float
	## Position when reached recall
	var recall_end : Vector3
	
	var particle_character : Node
	var particle_recall : Node
	
	func _init(caster : Node) -> void:
		super._init(caster)
		title = "Soulstitch"
		interact_groups.append("interact_ability_soulstitch")
	
	func _set_mark() -> void:
		mark_location = caster.global_position
		_fx_set_mark()
	
	func _return_to_mark() -> void:
		recall_tween = caster.create_tween()
		recall_tween.set_ease(Tween.EASE_IN)
		recall_tween.set_trans(Tween.TRANS_CUBIC)
		recall_start = caster.global_position
		recall_tween.tween_method(_tween_step,caster.global_position,mark_location,recall_time)
		
		caster.my_component_physics.disable()
		caster.state_chart.send_event("on_disabled")
		
		_fx_return_to_mark()
	
	## Set Lumia's fx when returning to the mark
	func _fx_return_to_mark() -> void:
		particle_character = Glossary.create_fx_particle(caster,"soulstitch_node_lumia")
		caster.animations.sprite.visible = false
	
	## Set the mark somewhere
	func _fx_set_mark() -> void:
		particle_recall = Glossary.create_fx_particle(caster.owner,"soulstitch_node_recall")
		particle_recall.global_position = caster.global_position
	
	func _fx_normal() -> void:
		var particle_clear = Glossary.create_fx_particle(caster.owner,"soulstitch_node_clear",true)
		particle_clear.global_position = caster.global_position
		particle_clear.amount = randi_range(40,60)
		particle_clear.process_material.spread = 180
		particle_clear.process_material.initial_velocity_max = 7
		particle_clear.process_material.initial_velocity_min = 7
	
	func _fx_slingshot() -> void:
		var particle_clear = Glossary.create_fx_particle(caster.owner,"soulstitch_node_clear",true)
		particle_clear.global_position = caster.global_position
		particle_clear.process_material.direction = recall_direction
		particle_clear.amount = randi_range(40,60)
		particle_clear.process_material.spread = 90
		particle_clear.process_material.initial_velocity_max = max(recall_magnitude,7)
		particle_clear.process_material.initial_velocity_min = 7#max(recall_magnitude,7)
	
	## Clear both Lumia's fx and the mark's fx
	func _fx_clear() -> void:
		caster.animations.sprite.visible = true
		if particle_character:
			particle_character.queue_free()
		if particle_recall:
			particle_recall.queue_free()
	
	func _tween_step(pos : Vector3) -> void:
		
		caster.global_position = pos
		
		## Called at end of tween
		if recall_tween.get_total_elapsed_time() >= recall_time:
			
			recall_end = caster.global_position
			recall_direction = (recall_end - recall_start).normalized()
			recall_magnitude = ( (recall_end - recall_frame)/(recall_time - recall_frame_time) ).length()
			recall_velocity = recall_direction*recall_magnitude
			
			## If we are pressing the same ability button when we're at the end of the call
			if Input.is_action_pressed("equipment_use"):
				_fx_slingshot()
				recall_tween.stop()
				
				#if calc.length() > 20:
					#calc = calc.normalized()*20
				
				caster.velocity = recall_velocity
			else:
				_fx_normal()
			
			## Clear mark and Lumia's fx at end of tween regardless
			_fx_clear()
			
			caster.my_component_physics.enable()
			caster.state_chart.send_event("on_enabled")
			
		## Called before end of tween continuously
		else:
			recall_frame = caster.global_position
			recall_frame_time = recall_tween.get_total_elapsed_time()
	
	### --- Events --- ###
	
	func verify_use() -> bool:
		if true:
			return true
		else:
			return false
	
	func on_use() -> void:
		
		if verify_use():
			if is_mark_placed:
				_return_to_mark()
			else:
				_set_mark()
				
			is_mark_placed = !is_mark_placed
			Debug.message(["Mark placed = ",is_mark_placed],Debug.msg_category.WORLD)
	
	func on_cancel() -> void:
		if is_mark_placed:
			is_mark_placed = !is_mark_placed
			_fx_clear()

## NOT IN USE YET
#class ability_heartstitch:
	#extends ability_dreamstitch
	#
	#var soulstitch_max : int = 2
	#
	#func _init(caster : Node) -> void:
		#super._init(caster)
		#title = "Dreamstitch"
		#interact_groups.append("interact_ability_soulstitch")
	#
	#func verify_use() -> bool:
		### If we can still add soulstitchs
		#if caster.get_tree().get_nodes_in_group("interact_ability_soulstitch_active").size() < soulstitch_max and current_interaction_areas.size() > 0:
			#return true
		#else:
			#return false
		#
	#func on_use() -> void:
		### If we're trying to link a controller
		#if verify_use():
			#for area in current_interaction_areas: #Runs through all verified areas in "interact_ability_soulstitch"
				### Add first one we find to our soulstitch active group
				#if !area.my_component_impulse_controller.is_in_group("interact_ability_soulstitch_active"):
					##emit soulstitch signal to add it
					#area.my_component_impulse_controller.add_to_group("interact_ability_soulstitch_active")
					#return
		### If we are trying to clear our soulstitch actives
		#else:
			#for controller in caster.get_tree().get_nodes_in_group("interact_ability_soulstitch_active"):
				#controller.remove_from_group("interact_ability_soulstitch_active")

class ability_gustbloom: #TBD
	extends ability_dreamstitch
	
	func _init(caster : Node) -> void:
		super._init(caster)
		title = "Gustbloom"
		interact_groups.append("interact_ability_gustbloom")
