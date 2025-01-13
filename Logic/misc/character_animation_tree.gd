extends AnimationTree

@export var animations : component_animation
@export var my_owner : Node

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

# Signals

func _on_animation_finished(anim_name: StringName) -> void:
	Events.animation_finished.emit(anim_name,owner)

func _on_animation_started(anim_name: StringName) -> void:
	Events.animation_started.emit(anim_name,owner)

## Called from animations with an attack in battle
func _on_attack_contact() -> void:
	if owner.my_component_ability.cast_queue.cast_validate(): #if we didn't miss
		Events.battle_entity_hit.emit(owner,owner.my_component_ability.cast_queue.targets,owner.my_component_ability.cast_queue)	
		
	else:
		Events.battle_entity_missed.emit(owner,owner.my_component_ability.cast_queue.targets,owner.my_component_ability.cast_queue)

## Means the system is looking for input at this moment
var is_attack_window_open : bool = false
## Size max that attack window can be. Should be half of total window
var attack_window_buffer_max : float = 0.05
## Size of the buffer on edges of the attack window
var attack_window_buffer : float = 0
## Amount of attacks we've success'd
var attack_count : int = 0
## 
var is_attack_final : bool = true

## This should start at the farthest point at the attack we accept input
## and will shrink as the attack repeats on both ends
## owner.animations.player.libraries[""].get_animation("default_attack").loop_mode = 1
## Sweet spot is about 0.1s
func start_skillcheck_window(time : float) -> void:
	
	## Initialize attack as final, changes if skillcheck lands
	is_attack_final = true
	
	attack_window_buffer_max = time/2
	
	Debug.message(["CURRENT ATTACK BUFFER EDGE: ",attack_window_buffer],Debug.msg_category.BATTLE)
	
	if attack_window_buffer:
		await get_tree().create_timer(attack_window_buffer).timeout
	
	is_attack_window_open = true

	await get_tree().create_timer(attack_window_buffer_max - attack_window_buffer).timeout
	
	is_attack_window_open = false

func _attack_count_change(amt : int) -> int:
	attack_count = clamp(attack_count + amt,0,3)
	return attack_count

func _skillcheck_buffer_change(amt : float) -> void:
	attack_window_buffer = clamp(attack_window_buffer + amt,0,attack_window_buffer_max)

func _skillcheck_success() -> void:
	## Set attack not as final, preventing turn end
	is_attack_final = false
	Glossary.create_fx_particle(owner.my_component_ability.cast_queue.targets,"heartsurge_node_clear",true)
	
	## Slice 20% off the total available attack window, making the next attack's skillcheck harder
	_skillcheck_buffer_change(attack_window_buffer_max*0.2)
	
	## Queue next attack
	await animation_finished
	set_state("default_attack")

func _input(event: InputEvent) -> void:
	if is_attack_window_open:
		if Input.is_action_just_pressed("ui_select"):
			_skillcheck_success()
