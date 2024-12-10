extends Label3D

@export var my_component_state_controller_world : component_state_controller_world
@export var my_component_health : component_health
@export var my_component_vis : component_vis
@export var my_component_party : component_party

@onready var prev = "init"
@onready var history = "history"
@onready var state_subchart


@onready var new_state_history

func _ready() -> void:
	state_subchart = str(owner.get_node("StateChart/Main/World")._active_state)
	
	new_state_history = str(owner.get_node("StateChart/Main/World/History").history)
	
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
	
	var abil = owner.my_component_ability.get_data_ability_all()
	var abil_names : Array = []
	
	for i in abil.size():
		abil_names.append(abil[i].title)
	
	var dreamkin_summons = Global.player.my_component_party.my_summons
	var dreamkin_party = Global.player.my_component_party.my_party
	
	var dreamkin_list = []
	
	for i in dreamkin_summons.size():
		dreamkin_list.append(dreamkin_summons[i].name)
	dreamkin_list.append(" / ")
	for i in dreamkin_party.size():
		dreamkin_list.append(dreamkin_party[i].name)
	
	var status_list = []
	if owner.my_component_ability.my_status.NORMAL:
		status_list.append(owner.my_component_ability.my_status.NORMAL.title)
	status_list.append(" / ")
	for i in owner.my_component_ability.my_status.PASSIVE.size():
		status_list.append(owner.my_component_ability.my_status.PASSIVE[i].title)
	
	if prev != state_subchart:
		history = prev
		prev = state_subchart
	
	text = str(
	owner.name,
	"\n",
	new_state_history,
	"\n",
	dreamkin_list,
	"\n",
	abil_names,
	"\n",
	status_list,
	"\n",
	"Now: ", state_subchart.rsplit(":")[0],
	"\n",
	"Prev: ", history.rsplit(":")[0])
