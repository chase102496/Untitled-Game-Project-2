extends Label3D

@export var my_component_state_controller_world : component_state_controller_world
@export var my_component_health : component_health
@export var my_component_vis : component_vis
@export var my_component_party : component_party

@onready var prev = "init"
@onready var history = "history"
@onready var state_subchart_battle

func _ready() -> void:
	state_subchart_battle = owner.get_node("StateChart/Main/Battle")
	#position.y += randf_range(0,0.6)
	modulate = Color(randf_range(0.5,1),randf_range(0.5,1),randf_range(0.5,1))

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug"):
		if visible:
			hide()
			owner.animations.status_hud.hide()
		else:
			show()
			owner.animations.status_hud.show()
	
	var state = str(state_subchart_battle._active_state)
	
	if prev != state:
		history = prev
		prev = state
	
	
	text = str(
	owner.name,
	"\n",
	"Now: ", state.rsplit(":")[0],
	"\n",
	"Prev: ", history.rsplit(":")[0])
