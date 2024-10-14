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
var grounded := false
var jumping := false
var jump_start := false
var jump_damper := 1

func _process(_delta: float) -> void:
	#Animations placeholder - https://www.youtube.com/watch?v=LkbEu4yxUNw
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://turn_arena.tscn")
	
	pass

func _physics_process(delta: float) -> void:
	
	move_and_slide()
	
	#Checking for inputs
	jump_start = Input.is_action_just_pressed("move_jump")
	jumping = Input.is_action_pressed("move_jump")
	direction = Input.get_vector("move_right","move_left","move_forward","move_backward")
	
	#Applying jump
	if jump_start:

		if is_on_floor():
			velocity.y = jump_force
	
	if !jumping and !is_on_floor() and velocity.y > 0: #make state machine later for in-air phase so we can apply physics and shit
		velocity.y -= move_toward(0,velocity.y,jump_damper)
		#get_tree().change_scene_to_file("res://turn_arena.tscn")
	
	#Applying movement
	velocity.x = move_toward(velocity.x, max_run * -direction.x, run_accel * delta)
	velocity.z = move_toward(velocity.z, max_run * direction.y, run_accel * delta)
	velocity.y = move_toward(velocity.y, max_grav, grav * delta)
