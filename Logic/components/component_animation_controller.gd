class_name component_animation_controller
extends component_node

@export var my_component_input_controller : Node
@export var animations : component_animation

## Utility Functions

func camera_billboard() -> void:
	owner.rotation.y = Global.camera.rotation.y

func animation_update(dir : Vector2 = Vector2(0,0)) -> void:
	
	if dir.x > 0:
		animations.rotation.y = PI
	elif dir.x < 0:
		animations.rotation.y = 0
	else:
		pass #Keep current direction if we didn't change it
	
	if dir.y != 0:
		animations.tree.set_blend_group(dir,["Idle","Walk"])
		#animations.tree.set_blend(dir) TODO CHANGE THIS WHEN WE GET BACK SIDE OF WALK
	
	#animations.tree.set_blend(dir)
	
	#animations.tree.set_blend_2d(dir,"Idle")
	#animations.tree.set_blend_2d(dir,"Walk")
