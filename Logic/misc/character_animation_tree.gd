extends AnimationTree

@export var animations : component_animation
@export var my_owner : Node

##Total time of the attack window left
var attack_timer : SceneTreeTimer

## Means the system is looking for input at this moment
var is_attack_window_open : bool = false
## Size of the buffer on edges of the attack window
var attack_window_open_time : float = 0
## Size max that attack window can be. Should be half of total window
var attack_window_close_time : float
## Total time to play with
var attack_window_total_time : float
## How much is given to open and taken from closed each combo
var attack_window_modifier : float = 0.5
## How many seconds the window can cut down to. If 0, the player cannot land an attack
var attack_window_minimum_window : float = 0.1
## Amount of attacks we've success'd
var attack_combo : int = 0
## 
var is_attack_final : bool = true
##
var is_attack_blocked : bool = false

func _ready() -> void:
	
	animation_finished.connect(_on_animation_finished)
	animation_started.connect(_on_animation_started)
	Events.battle_entity_dying.connect(_on_battle_entity_dying)
	
	active = true
	
	##Override for owner
	if my_owner:
		owner = my_owner
	else:
		my_owner = owner

### --- Signals --- ###

func _input(event: InputEvent) -> void:
	if is_attack_window_open:
		if Input.is_action_just_pressed("ui_select"):
			if owner.alignment == Battle.alignment.FRIENDS:
				is_attack_final = false
			elif owner.alignment == Battle.alignment.FOES:
				is_attack_blocked = true
			else:
				push_error("Could not find alignment to calculate attack window ",owner.alignment)

func _on_animation_finished(anim_name: StringName) -> void:
	Events.animation_finished.emit(anim_name,owner)
	
	if is_attack_final:
		_skillcheck_end()
	else:
		set_state("default_attack")

func _on_animation_started(anim_name: StringName) -> void:
	Events.animation_started.emit(anim_name,owner)

## Runs when an animation has a skillcheck
## Before attack_contact
func start_skillcheck_window(time : float) -> void:
	
	attack_timer = get_tree().create_timer(time)
	attack_window_total_time = time
	
	## Initialize attack as final, changes if skillcheck lands
	is_attack_final = true
	
	## Calculating timing window
	attack_window_open_time = min(attack_window_total_time - (attack_window_total_time*attack_window_minimum_window), ((attack_combo*attack_window_modifier) * attack_window_total_time)/2)
	attack_window_close_time = max(attack_window_total_time*attack_window_minimum_window, attack_window_total_time - attack_window_open_time)
	
	## Creates the start buffer, which starts at 0 and grows as the buffer does
	if attack_window_open_time > 0:
		await get_tree().create_timer(attack_window_open_time).timeout
	
	is_attack_window_open = true
	
	## Creates the end buffer, which starts at the full length
	await get_tree().create_timer(attack_window_close_time).timeout
	
	is_attack_window_open = false
	
	## If we missed the attack window
	if is_attack_final:
		_skillcheck_end()

func _on_battle_entity_dying(entity : Node) -> void:
	var cast_queue = owner.my_component_ability.cast_queue
	if cast_queue and cast_queue.primary_target and entity == cast_queue.primary_target:
		_skillcheck_end()

## Called when an attack lands
func _on_attack_contact() -> void:
	
	## If landing a successful attack,
	if owner.my_component_ability.cast_queue.cast_validate():
		
		await get_tree().create_timer(attack_timer.time_left).timeout
		
		if is_attack_blocked:
			_skillcheck_success_defense()
		
		if !is_attack_final:
			_skillcheck_success_offense()
		
		Events.battle_entity_hit.emit(owner,owner.my_component_ability.cast_queue.targets,owner.my_component_ability.cast_queue)
	## Cast failed
	else:
		Events.battle_entity_missed.emit(owner,owner.my_component_ability.cast_queue.targets,owner.my_component_ability.cast_queue)

	## Reset attack blocked status
	is_attack_blocked = false

func _on_footstep() -> void:
	Glossary.create_fx_particle_custom(owner.animations.selector_feet,"dust",true,8,-1,-1,-my_owner.velocity.normalized(),Global.palette["Oxford Blue"])

### --- Skillcheck Calc --- ###

## Skillcheck callable when landing offense window
func _skillcheck_success_offense() -> void:
	## Raise attack combo
	_attack_combo_change(1)
	## Signal to others we landed a combo
	Events.battle_entity_combo.emit(owner,attack_combo)

## Skillcheck callable when landing defense window
func _skillcheck_success_defense() -> void:
	for tgt in owner.my_component_ability.cast_queue.targets:
		
		Glossary.create_icon_particle(tgt.animations.selector_center,"status_defense","icon_pop_fly")
		tgt.my_component_health.change_armor_block(tgt.my_component_health.block_power)
		Events.battle_entity_blocked.emit(tgt)

func _attack_window_clear() -> void:
	is_attack_window_open = false
	attack_window_open_time = 0

func _attack_combo_clear() -> void:
	attack_combo = 0

func _attack_combo_change(amt : int) -> int:
	attack_combo += amt
	match attack_combo:
		1:
			Glossary.reset_particle_queue()
			Glossary.create_text_particle_queue(owner.my_component_ability.cast_queue.primary_target.animations.selector_center,"Nice!","text_float_away",Global.palette["Apricot"])
			Glossary.create_fx_particle_custom(owner.my_component_ability.cast_queue.primary_target.animations.selector_center,"star_explosion",true,10,-1,-1,Vector3.ZERO,Global.palette["Apricot Saturated"])
		2:
			Glossary.reset_particle_queue()
			Glossary.create_text_particle_queue(owner.my_component_ability.cast_queue.primary_target.animations.selector_center,"Great!","text_float_away",Global.palette["Light Coral"])
			Glossary.create_fx_particle_custom(owner.my_component_ability.cast_queue.primary_target.animations.selector_center,"star_explosion",true,10,-1,5,Vector3.ZERO,Global.palette["Light Coral Saturated"])
		_:
			Glossary.reset_particle_queue()
			Glossary.create_text_particle_queue(owner.my_component_ability.cast_queue.primary_target.animations.selector_center,"Excellent!","text_float_away",Global.palette["Magenta Haze"])
			Glossary.create_fx_particle_custom(owner.my_component_ability.cast_queue.primary_target.animations.selector_center,"star_explosion",true,10,-1,5,Vector3.ZERO,Global.palette["Magenta Haze Saturated"])
	
	return attack_combo

func _skillcheck_end() -> void:
	is_attack_final = true
	_attack_window_clear()
	_attack_combo_clear()

### --- General Utility --- ###

func _playback() -> AnimationNodeStateMachinePlayback:
	return get("parameters/playback")

## Will resume and reflect any changes that happened when paused or unpaused
func resume() -> void:
	active = true

## Will still accept config changes, but doesn't reflect them on screen
func pause() -> void:
	active = false

func get_state():
	return _playback().get_current_node()

func set_state(state : String, interrupt : bool = false) -> void:
	if interrupt:
		_playback().start(state)
	else:
		_playback().travel(state)

func set_blend_group(dir : Vector2, states : PackedStringArray) -> void:
	for state in states:
		set_blend(dir,state)

func set_blend(dir : Vector2, state : String = get_state()) -> void:
	set("parameters/"+state+"/BlendSpace2D/blend_position",dir)
