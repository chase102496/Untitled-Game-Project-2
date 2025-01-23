class_name component_animation_controller
extends component_node

@export var my_component_input_controller : Node
@export var my_component_physics : component_physics
@export var animations : component_animation

## Utility Functions

func camera_billboard() -> void:
	owner.rotation.y = Global.camera.rotation.y

var result_dir : Vector3 = Vector3.ZERO
var result_rotation : float = 0

## Updates our animations, meant to be ran every frame/tick
## Defaults to our velocity, but rotated to adjust for its position relative to the camera
func animation_update(vel : Vector3 = owner.velocity) -> void:
	
	## X Movement (Left/Right)
	if vel.x > 0.1:
		result_rotation = PI
		result_dir.x = vel.x
	elif vel.x < -0.1:
		result_rotation = 0
		result_dir.x = vel.x
	
	## Y Movement (Up/Down)
	if vel.y != 0:
		result_dir.y = vel.y
	
	## Z Movement (Front facing/Back facing)
	if vel.z > 0:
		result_dir.z = vel.z
	elif vel.z < 0:
		result_dir.z = vel.z
	
	animations.rotation.y = result_rotation
	animations.tree.set_blend_group(Vector2(result_dir.y,result_dir.z),["Idle","Walk","Walk 2","Air"])
