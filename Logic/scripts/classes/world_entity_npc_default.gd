class_name world_entity_npc_default
extends world_entity_default

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_follow

func _ready():
	name = str(name," ",randi())
	%StateChart/Main/Explore.state_physics_processing.connect(_on_state_physics_processing_explore)
	%StateChart/Main/Explore.state_exited.connect(_on_state_exited_explore)



func _on_state_physics_processing_explore(delta: float) -> void:
	if position.distance_to(Global.player.position) <= 1.5:
		$Animations/interact_sprite.show()
		if Input.is_action_just_pressed("interact"):
			Dialogic.start("timeline")
	else:
		$Animations/interact_sprite.hide()

func _on_state_exited_explore() -> void:
	$Animations/interact_sprite.hide()
