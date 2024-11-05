extends AnimationTree

func _on_animation_finished(anim_name: StringName) -> void:
	Events.animation_finished.emit(anim_name,owner)

func _on_animation_started(anim_name: StringName) -> void:
	Events.animation_started.emit(anim_name,owner)

func _on_attack_contact() -> void:
	Events.battle_entity_hit.emit(owner,owner.my_component_ability.cast_queue.target,owner.my_component_ability.cast_queue)
