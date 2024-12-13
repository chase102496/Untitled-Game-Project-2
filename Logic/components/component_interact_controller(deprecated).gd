#class_name component_interact
extends Node

## Distance the target can be interacted with
@export_range(0,30,0.5) var interact_distance : float = 1.5

@onready var interact_sprite : Sprite3D = %Animations/interact_sprite
@onready var interact_player : AnimationPlayer = %Animations/interact_player

func _ready():
	name = str(name," ",randi())
	%StateChart/Main/World.state_physics_processing.connect(_on_state_physics_processing_explore)
	%StateChart/Main/World.state_exited.connect(_on_state_exited_explore)

func _on_state_physics_processing_explore(_delta: float) -> void:
	if owner.position.distance_to(Global.player.position) <= interact_distance:
		interact_sprite.show()
		if Input.is_action_just_pressed("interact"):
			#This is where things change up
			owner.on_interact.emit()
			
	else:
		interact_sprite.hide()

func _on_state_exited_explore() -> void:
	interact_sprite.hide()
