extends component_impulse_reciever

@export var restore_all : bool = false
@export var health_changed : int = 0
@export var vis_changed : int = 0

func _on_activated() -> void:
	if restore_all:
		Interface.restore_all()
	else:
		Global.player.my_component_health.change(health_changed)
		Global.player.my_component_vis.change(vis_changed)
