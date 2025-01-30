class_name component_world_ability
extends component_node_3d

## If something new was set to our active equipment
signal equip_active(equipment : world_ability)
## If our current active equipment was taken out of active
signal equip_inactive(equipment: world_ability)
## If something changed in our equipment that needs to be looked at again
## For example, updating icons in HUD, or updating values stored elsewhere
signal equip_update(equipment : world_ability)

## If we brought something new into our equipment roster
signal equip_set(equipment : world_ability)
## If we took something out of our equipment roster
signal equip_unset(equipment : world_ability)


## If we used an ability
signal used_ability(equipment : world_ability)

@export var gloam_manager : Node3D

@export var active_interact_area : component_interact_controller

## Our equipment consists of two slots, a Dreamstitch and a Loomlight we can swap between
@onready var dreamstitch : world_ability_dreamstitch# = world_ability_soulstitch.new(owner)
@onready var loomlight : world_ability_loomlight# = world_ability_loomlight.new(owner)
## This will either be null, or one of the above 2 equipments
@onready var active : world_ability = dreamstitch

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

func ability_use() -> void:
	ability_event(active,"on_use")

### --- Private --- ###

func _refresh_equipment_interact_areas(old_ability : world_ability, new_ability : world_ability) -> void:
	#if we have memory of a collision and if we overlap our most recent area still
	if active_interact_area_memory and active_interact_area.overlaps_area(active_interact_area_memory):
		ability_event(old_ability,"on_area_exited",[active_interact_area_memory])
		ability_event(new_ability,"on_area_entered",[active_interact_area_memory])

## We ran all external checks and now we just need to see if we can change our active
func _verify_equip(ability : world_ability) -> bool:
	if _verify_unequip_active():
		if !ability or ability.verify_equip():
			return true
		else:
			Debug.message(["Unable to equip because new ability is not equippable ",ability],Debug.msg_category.WORLD)
			return false
	else:
		Debug.message(["Unable to equip because we could not unequip an ability ",ability],Debug.msg_category.WORLD)
		return false

## Checks if we can unequip our active equipment
func _verify_unequip_active() -> bool:
	if !active or active.verify_unequip():
		return true
	else:
		Debug.message(["Unable to unequip ability ",active],Debug.msg_category.WORLD)
		return false

## We ran all our checks, equip new ability
func _equip_active(new_ability : world_ability) -> void:
	ability_event(new_ability,"on_equip")
	## If we overlap an interact area, refresh our old and new equipment to run exit on old and enter on new
	_refresh_equipment_interact_areas(active,new_ability)
	## Set new var
	active = new_ability
	## Emit our signal
	equip_active.emit(new_ability)
	## Send event to new ability

## We ran all our checks, unequip current ability
func _unequip_active() -> void:
	ability_event(active,"on_unequip")
	_refresh_equipment_interact_areas(active,null)
	active = null
	equip_inactive.emit(null)

## We ran all our checks, and we're setting a new piece of equipment
func _set_equipment(new_ability : world_ability) -> world_ability:
	if new_ability is world_ability_loomlight:
		_set_loomlight(new_ability)
		return new_ability
	elif new_ability is world_ability_dreamstitch:
		_set_dreamstitch(new_ability)
		return new_ability
	else:
		push_error("Unknown ability for set_equipment: ",new_ability)
		return

func _unset_equipment(ability : world_ability) -> void:
	if ability is world_ability_dreamstitch:
		_set_dreamstitch(null)
		equip_unset.emit(ability)
	elif ability is world_ability_loomlight:
		_set_loomlight(null)
		equip_unset.emit(ability)
	else:
		push_error("Unknown equipment to unset: ",ability)

func _set_dreamstitch(ability : world_ability_dreamstitch) -> void:
	dreamstitch = ability

func _set_loomlight(ability : world_ability_loomlight) -> void:
	loomlight = ability

### --- Public --- ###

## Get

## Returns only valid equipment
func get_equipment() -> Array:
	var result : Array = []
	for equip in [dreamstitch,loomlight]:
		if equip:
			result.append(equip)
	return result

## Use

## Lets the current ability know this event is being called.
## It doesn't have to do something, but we check just in case it exists
## For example, running code when walking, near a certain object, press a certain button, etc.
## Can use "my_component_world_ability.active", "my_component_world_ability.dreamstitch", or "my_component_world_ability.loomlight" for new_ability
func ability_event(new_ability : world_ability, method : String, args : Array = []) -> Variant:
	if new_ability:
		if new_ability.has_method(method):
			return new_ability.callv(method,args)
		else:
			#print_debug("Ability ignoring event : ",new_ability," ",method) #This will happen sometimes, not an error
			return false
	else:
		#print_debug("Ability is null, no event triggered : ",new_ability," ",method) #This happens if we have no equipment to use, also not an error
		return false

## Set

## Set up some new equipment that was not in our equipment before
func set_equipment(new_ability : world_ability) -> world_ability:
	
	## If the type is currently being used we have to unequip
	if !active or new_ability.type == active.type:
		if _verify_equip(new_ability):
			_unequip_active()
			_equip_active(new_ability)
			return _set_equipment(new_ability)
		else:
			return
	## If the type is just a piece of data, replace it
	else:
		return _set_equipment(new_ability)

## Checks if the piece of equipment is equipped, and if it is, it 
func unset_equipment(ability : world_ability) -> void:
	## If it's currently equipped
	if ability in [loomlight, dreamstitch]:
		## If it's the active ability, we have to unequip it first
		if ability == active:
			## Verify we can unequip it
			if _verify_unequip_active():
				_unequip_active()
				_unset_equipment(ability)
		## If it's not the active, just clear it
		else:
			_unset_equipment(ability)
	else:
		push_error("Attempting to unequip something we don't have equipped: ",ability)

## Creation/Manipulation

## Sets an ability as our active. Can be new or existing, or even null
func set_active(new_ability : world_ability) -> void:
	## If it's already in our equipment
	if !new_ability:
		if _verify_unequip_active():
			_unequip_active()
	elif new_ability in [loomlight,dreamstitch]:
		if _verify_equip(new_ability) and _verify_unequip_active():
			_unequip_active()
			_equip_active(new_ability)
	## If it's totally new
	else:
		set_equipment(new_ability)

## Simply unequip to nothing.
func unset_active() -> void:
	if _verify_unequip_active():
		_unequip_active()

## Swaps from dreamstitch to loomlight, or vice versa
func toggle_active() -> void:
	if !active:
		if loomlight:
			set_active(loomlight)
		elif dreamstitch:
			set_active(dreamstitch)
		else:
			Debug.message("No equipment available to swap to or from!",Debug.msg_category.WORLD)
	elif active == dreamstitch:
		set_active(loomlight)
	elif active == loomlight:
		set_active(dreamstitch)
	else:
		Debug.message(["Invalid or old active equipment, not sure what to swap to: ",active],Debug.msg_category.WORLD)

## --- Ability Classes --- ##

## What we form the basis of all of our world abilities off of.
class world_ability:

	var caster : Node
	var interact_groups : Array
	var my_interact_area : Area3D
	var my_interact_area_shape : CollisionShape3D
	## This will either be world_ability_dreamstitch or world_ability_loomlight
	var type : RefCounted
	
	var title : String = "---"
	
	## Updates live to the gui if we're equipped
	var icon : PackedScene = Glossary.icon_random.pick_random():
		set(value):
			icon = value
			if is_equip_active():
				caster.my_component_world_ability.equip_update.emit(self)
				
	var flavor : String = ""
	var description : String = ""
	
	var fx_instance : GPUParticles3D
	
	var current_interaction_areas : Array = []
	
	## Cooldown timer
	var cooldown_timer : Timer = Timer.new()
	## Max cooldown
	var cooldown_timer_max : float = 2.0
	
	func _init(caster : Node) -> void:
		self.caster = caster
		cooldown_timer.one_shot = true
		cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	
	## Called when cooldown is over
	func _on_cooldown_timer_timeout() -> void:
		pass
	
	## Call to remove cooldown
	func _on_cooldown_timer_stop() -> void:
		cooldown_timer.stop()
	
	func _cooldown_timer_start() -> void:
		if !cooldown_timer.is_inside_tree():
			caster.add_child(cooldown_timer)
		cooldown_timer.stop()
		cooldown_timer.start(cooldown_timer_max)
	
	## Called when we want to know if we're on cooldown
	func _is_on_cooldown() -> bool:
		if cooldown_timer.time_left == 0:
			return false
		else:
			return true
	
	## TODO Need to make get and set data func, 4 of em
	
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
	
	func is_equip_active() -> bool:
		if caster.my_component_world_ability.active == self:
			return true
		else:
			return false
	
	func is_in_equipment() -> bool:
		if self in caster.my_component_world_ability.get_equipment():
			return true
		else:
			return false
	
	func verify_equip() -> bool:
		#conditions when checking if we can equip this (as in swapped to being in our hand)
		return true
	
	func verify_unequip() -> bool:
		#conditions when checking if we can unequip this (as in swapped to being out of our hand)
		return true
	
	func on_equip() -> void:
		my_interact_area = caster.my_component_world_ability.active_interact_area
		my_interact_area_shape = caster.my_component_world_ability.active_interact_area.shape
		
	func on_unequip() -> void:
		pass
	
	## When we are put into equipment
	func on_set() -> void:
		pass
	
	## When we are taken out of equipment
	func on_unset() -> void:
		pass

## Template super for all dreamstitch abilities
class world_ability_dreamstitch:
	extends world_ability
	
	func _init(caster : Node) -> void:
		super._init(caster)
		type = world_ability_dreamstitch
		title = "Empty Dreamstitch Ability"
		interact_groups.append("interact_ability_dreamstitch")
	
	func on_equip() -> void:
		super.on_equip()

## Template super for all loomlight abilities
class world_ability_loomlight:
	extends world_ability
	
	var color : Color = Color("ffebdb") #Determines color of lantern
	var size : float = 2.2 #Determines size of gloam cleared with lantern and also range of light in lantern
	var light_strength : float = 1 #Determines brightness of lantern
	
	var tween_light_strength : Tween
	var tween_size : Tween
		
		#We can directly connect to signals just like the _ready() function!!!
		#And define the function to call on signaling here!!
	
	func _init(caster : Node) -> void:
		super._init(caster)
		icon = Glossary.icon_scene["lantern"]
		type = world_ability_loomlight
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
		super.on_equip()
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

# Dreamstitch

class world_ability_soulstitch:
	extends world_ability_dreamstitch
	
	var is_mark_placed : bool = false
	var mark_location : Vector3
	var recall_time : float = 0.5
	var recall_tween : Tween
	## Max range we are able to recall to the mark
	var recall_range_max : float = 10
	
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
		icon = Glossary.icon_scene["soulstitch_mark"]
		title = "Soulstitch"
		interact_groups.append("interact_ability_soulstitch")
		cooldown_timer_max = 2.0
	
	### --- Private --- ###
	
	func _cooldown_timer_start() -> void:
		super._cooldown_timer_start()
		icon = Glossary.icon_scene["soulstitch_cooldown"]
	
	func _on_cooldown_timer_timeout() -> void:
		super._on_cooldown_timer_timeout()
		icon = Glossary.icon_scene["soulstitch_mark"]
	
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
				_return_slingshot()
			else:
				_return_normal()
			
			caster.my_component_physics.enable()
			caster.state_chart.send_event("on_enabled")
			
		## Called before end of tween continuously
		else:
			recall_frame = caster.global_position
			recall_frame_time = recall_tween.get_total_elapsed_time()
	
	func _return_normal() -> void:
		_fx_clear()
		_fx_normal()
	
	func _return_slingshot() -> void:
		caster.velocity = recall_velocity
		_fx_clear()
		_fx_slingshot()
		recall_tween.stop()
	
	#_on_cooldown_timer_stop() to reset cooldown
	func _on_reset() -> void:
		_cooldown_timer_start()
		if is_mark_placed:
			is_mark_placed = !is_mark_placed
			_fx_clear()
	
	### --- Visuals --- ###
	
	## We start traveling back to the mark
	func _fx_return_to_mark() -> void:
		particle_character = Glossary.create_fx_particle(caster.animations.selector_center,"soulstitch_node_lumia")
		caster.animations.sprite.visible = false
	
	## We just set the mark, put a node down
	func _fx_set_mark() -> void:
		particle_recall = Glossary.create_fx_particle(caster.owner,"soulstitch_node_recall")
		particle_recall.global_position = caster.animations.selector_center.global_position
		
		icon = Glossary.icon_scene["soulstitch_return"]
	
	## We RETURN normally to the mark
	func _fx_normal() -> void:
		var particle_clear = Glossary.create_fx_particle(caster.owner,"soulstitch_node_clear",true)
		
		##anim
		particle_clear.global_position = caster.global_position
		particle_clear.amount = randi_range(40,60)
		particle_clear.process_material.spread = 180
		particle_clear.process_material.initial_velocity_max = 7
		particle_clear.process_material.initial_velocity_min = 7
	
	## We RETURN with slingshot momentum to the mark
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
		if !caster.animations.sprite.visible:
			caster.animations.sprite.visible = true
		if particle_character:
			particle_character.queue_free()
			particle_character = null
		if particle_recall:
			particle_recall.queue_free()
			particle_recall = null
	
	### --- Events --- ###
	
	func _is_out_of_range() -> bool:
		if caster.global_position.distance_to(mark_location) > recall_range_max:
			return true
		else:
			return false
	
	func verify_use() -> bool:
		if _is_on_cooldown() or (_is_out_of_range() and is_mark_placed):
			return false
		else:
			return true
	
	func on_unequip() -> void:
		super.on_unequip()
		_on_reset()
	
	func on_equip() -> void:
		super.on_equip()
		_on_reset()
	
	func on_use() -> void:
		if verify_use():
			if is_mark_placed:
				_return_to_mark()
				_cooldown_timer_start()
			else:
				_set_mark()
				
			is_mark_placed = !is_mark_placed
			Debug.message(["Mark placed = ",is_mark_placed],Debug.msg_category.WORLD)

## NOT IN USE YET TBD
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
