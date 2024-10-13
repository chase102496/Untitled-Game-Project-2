extends CharacterBody3D
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass

#Init Values

#Physics
var direction = Vector3.ZERO
var max_run := 8
var run_accel := 70
var grav := 40
var max_grav := -70
var jump_force := 13
var jump_hold_time := 0.1
var local_hold_time := 0
var grounded := false
var jumping := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Animations placeholder - https://www.youtube.com/watch?v=LkbEu4yxUNw
	pass
	

func _physics_process(delta: float) -> void:
	
	jumping = Input.is_action_just_pressed("move_jump")
	direction = Input.get_vector("move_right","move_left","move_forward","move_backward")
	
	move_and_slide()
	
	if is_on_floor():
		if jumping:
			velocity.y = jump_force
		#print("floor")
	
	#Getting direction
	
	velocity.x = move_toward(velocity.x, max_run * -direction.x, run_accel * delta)
	velocity.z = move_toward(velocity.z, max_run * direction.y, run_accel * delta)
	velocity.y = move_toward(velocity.y, max_grav, grav * delta)
	
func _on_area_3d_floor_box_area_entered(area: Area3D) -> void:
	print("test")
