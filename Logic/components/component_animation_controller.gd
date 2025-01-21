class_name component_animation_controller
extends component_node

@export var my_component_input_controller : Node
@export var animations : component_animation

## Utility Functions

func camera_billboard() -> void:
	owner.rotation.y = Global.camera.rotation.y

var result_dir : Vector3 = Vector3.ZERO

func animation_update(vel : Vector3 = owner.velocity) -> void:
	
	## X Movement (Left/Right)
	if vel.x > 0:
		animations.rotation.y = PI
		result_dir.x = vel.x
	elif vel.x < 0:
		animations.rotation.y = 0
		result_dir.x = vel.x
	else:
		pass #Keep current direction if we didn't change it
	
	## Y Movement (Up/Down)
	if vel.y != 0:
		result_dir.y = vel.y
	
	## Z Movement (Front facing/Back facing)
	if vel.z != 0:
		result_dir.z = vel.z
	
	animations.tree.set_blend_group(Vector2(result_dir.y,result_dir.z),["Idle","Walk","Walk 2","Air"])
