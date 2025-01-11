extends AnimationTree

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

func get_blend_2d() -> Vector2:
	return Vector2.ZERO

func set_blend_2d(dir : Vector2, state : String = get_state()) -> void:
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

		owner.animations.player.libraries[""].get_animation("default_attack").loop_mode = 1
		
	else:
		Events.battle_entity_missed.emit(owner,owner.my_component_ability.cast_queue.targets,owner.my_component_ability.cast_queue)
