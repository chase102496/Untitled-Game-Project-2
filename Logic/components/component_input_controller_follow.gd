class_name component_input_controller_follow
extends component_input_controller_default

@onready var player = Global.player

func _ready() -> void:
	%StateChart/Main/World.state_physics_processing.connect(_on_state_physics_processing_world)
	%StateChart/Main/World.state_exited.connect(_on_state_exited_world)

func _on_state_physics_processing_world(_delta: float) -> void:
	#Direction
	if player:
		#Less stutter when following with snapped()
		var distance_to_player = owner.global_position.distance_to(player.global_position)
		if snapped(distance_to_player,0.1) > 1.2:
			var from = Vector2(owner.global_position.x,owner.global_position.z)
			var to = Vector2(player.global_position.x,player.global_position.z)
			var result_dir = from.direction_to(to).normalized()
			direction = Vector2(snapped(result_dir.x,0.25),snapped(result_dir.y,0.25)) #less jitter
			raw_direction = direction.rotated(Global.camera.global_rotation.y)
		else:
			raw_direction = Vector2.ZERO
			direction = Vector2.ZERO

func _on_state_exited_world():
	direction = Vector2.ZERO
