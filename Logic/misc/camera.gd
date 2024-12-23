extends Node

@onready var camera_ray_cast : RayCast3D = get_parent().get_node("RayCast3D")
@onready var camera_ray_cast_default : RayCast3D = get_parent().get_node("RayCast3D2")

var obstacle : Node = null
var obstacles_exit : Array = []
var get_all_colliders : Array = []

func _ready() -> void:
	Global.camera_function = self
	Global.camera = owner
	Global.camera_object = $"../Camera3D"

func shot_transition(new_location):
#if Global.camera.follow_mode != 0:
		#Global.camera.follow_target = null
		#Global.camera.follow_mode = 0 #None
		#Global.camera.look_at_target = null
		#Global.camera.global_transform = get_parent().get_node("shot_waterfall").global_transform
#else:
	#Global.camera.follow_target = self
	#Global.camera.follow_mode = 2 #Simple
	#Global.camera.look_at_target = self
	# MAKE SURE YOU UNDERSTAND THE ORDER OF THE OBJECT IS THE ORDER THEY WILL TAKE TURNS IN LATER
	pass

func shot_rotate(dir : String):
	var tween = get_tree().create_tween()
	var def_y = owner.follow_offset.y
	match dir:
		"left":
			tween.tween_property(owner,"follow_offset",Vector3(3,def_y,0),0.5)
		"right":
			tween.tween_property(owner,"follow_offset",Vector3(-3,def_y,0),0.5)
		"back":
			tween.tween_property(owner,"follow_offset",Vector3(0,def_y,3),0.5)
		"front":
			tween.tween_property(owner,"follow_offset",Vector3(0,def_y,-3),0.5)

func camera_los_player_check():
	
	if camera_ray_cast_default.is_colliding(): #we are NOT in direct LOS of player
		if camera_ray_cast.get_collider(): #if we're still iterating through the list of colliders
			var current_obstacle = camera_ray_cast.get_collider()
			get_all_colliders.append(current_obstacle) #add to list of current collisions
			camera_ray_cast.add_exception(current_obstacle) #ignore it now
		else: #we finished adding all collisions
			return get_all_colliders
	else: #if we are in direct LOS of player
		if get_all_colliders: #if we have a list to clear
			get_all_colliders.clear()
			camera_ray_cast.clear_exceptions()
			return get_all_colliders

func camera_los_ghosting():
	var obstacles = camera_los_player_check()
	if obstacles:
		for i in len(obstacles):
			if "my_component_ghosting" in obstacles[i].owner: #if they have custom ghosting component
				obstacles[i].owner.my_component_ghosting.set_ghost(true)
			else: #apply generic transparency
				obstacles[i].get_parent().transparency = 0.5
				
			obstacles_exit.append(obstacles[i]) #exit list to un-ghost
				
	elif obstacles_exit:
		for i in len(obstacles_exit):
			if "my_component_ghosting" in obstacles_exit[i].owner: #if they have custom ghosting component
				obstacles_exit[i].owner.my_component_ghosting.set_ghost(false)
			else:
				obstacles_exit[i].get_parent().transparency = 0
				
		obstacles_exit.clear() #finalize and clear exit list

func _physics_process(_delta: float) -> void:
	camera_los_ghosting()
