class_name component_impulse_reciever_cooldown
extends component_impulse_reciever

func _ready() -> void:
	super._ready()

func _on_activated() -> void:
	super._on_activated()
	
	if Global.player.my_component_world_ability.active:
		Global.player.my_component_world_ability.active._on_cooldown_timer_stop()
