extends AnimationTree

@export var animations : component_animation
@export var my_owner : Node

## Means the system is looking for input at this moment
var is_attack_window_open : bool = false
## Size max that attack window can be. Should be half of total window
var attack_window_buffer_max : float = 0.05
## Size of the buffer on edges of the attack window
var attack_window_buffer : float = 0
## Amount of attacks we've success'd
var attack_combo : int = 0
## 
var is_attack_final : bool = true
##
var is_attack_blocked : bool = false

func _ready() -> void:
	
	animation_finished.connect(_on_animation_finished)
	animation_started.connect(_on_animation_started)
	
	active = true
	
	##Override for owner
	if my_owner:
		owner = my_owner

# Utility

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

### --- Signals --- ###

func _on_animation_finished(anim_name: StringName) -> void:
	Events.animation_finished.emit(anim_name,owner)

func _on_animation_started(anim_name: StringName) -> void:
	Events.animation_started.emit(anim_name,owner)

### --- Skillcheck --- ###

## Runs when an animation has a skillcheck
func start_skillcheck_window(time : float) -> void:
	## Initialize attack as final, changes if skillcheck lands
	is_attack_final = true
	
	attack_window_buffer_max = time/2
	
	Debug.message(["CURRENT ATTACK BUFFER EDGE: ",attack_window_buffer],Debug.msg_category.BATTLE)
	
	if attack_window_buffer:
		await get_tree().create_timer(attack_window_buffer).timeout
	
	is_attack_window_open = true

	await get_tree().create_timer(attack_window_buffer_max - attack_window_buffer).timeout
	
	## If we missed the attack window
	if !is_attack_final:
		_attack_combo_clear()
	
	is_attack_window_open = false

## Checking for skillcheck input
func _input(event: InputEvent) -> void:
	if is_attack_window_open:
		if Input.is_action_just_pressed("ui_select"):
			if owner.alignment == Battle.alignment.FRIENDS:
				_skillcheck_success_offense()
			elif owner.alignment == Battle.alignment.FOES:
				_skillcheck_success_defense()
			else:
				push_error("Could not find alignment to calculate attack window ",owner.alignment)

## Skillcheck callable for offense
func _skillcheck_success_offense() -> void:
	## Set attack not as final, preventing turn end
	is_attack_final = false
	## Raise attack combo
	_attack_combo_change(1)
	## Effects
	Glossary.create_fx_particle(owner.my_component_ability.cast_queue.targets,"heartsurge_node_clear",true)
	## Signal to others we landed a combo
	Events.battle_entity_combo.emit(owner,attack_combo)
	## Debug msg
	Debug.message("Successful Combo!",Debug.msg_category.BATTLE)
	
	## Slice 20% off the total available attack window, making the next attack's skillcheck harder
	_skillcheck_buffer_change(attack_window_buffer_max*0.2)
	
	## Queue next attack
	await animation_finished
	set_state("default_attack")

## Skillcheck callable for defense
func _skillcheck_success_defense() -> void:
	is_attack_blocked = true

## Called when an attack lands
func _on_attack_contact() -> void:

	if owner.my_component_ability.cast_queue.cast_validate(): #if we didn't miss
		
		if is_attack_blocked:
			for tgt in owner.my_component_ability.cast_queue.targets:
				tgt.my_component_health.change_armor_block(tgt.my_component_health.block_power)
				Events.battle_entity_blocked.emit(tgt)
				is_attack_blocked = false
				Debug.message("Successful Block!",Debug.msg_category.BATTLE)
		
		Events.battle_entity_hit.emit(owner,owner.my_component_ability.cast_queue.targets,owner.my_component_ability.cast_queue)
	else:
		Events.battle_entity_missed.emit(owner,owner.my_component_ability.cast_queue.targets,owner.my_component_ability.cast_queue)

## Misc

func _attack_combo_clear() -> void:
	attack_combo = 0

func _attack_combo_change(amt : int) -> int:
	return attack_combo

func _skillcheck_buffer_change(amt : float) -> void:
	attack_window_buffer = clamp(attack_window_buffer + amt,0,attack_window_buffer_max)
