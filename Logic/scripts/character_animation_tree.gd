extends AnimationTree

func _ready() -> void:
	active = true

func _on_animation_finished(anim_name: StringName) -> void:
	Events.animation_finished.emit(anim_name,owner)

func _on_animation_started(anim_name: StringName) -> void:
	Events.animation_started.emit(anim_name,owner)

func _on_attack_contact() -> void:
	if owner.my_component_ability.cast_queue.cast_validate(): #if we didn't miss
		Events.battle_entity_hit.emit(owner,owner.my_component_ability.cast_queue.targets,owner.my_component_ability.cast_queue)
	else:
		Events.battle_entity_missed.emit(owner,owner.my_component_ability.cast_queue.targets,owner.my_component_ability.cast_queue)
