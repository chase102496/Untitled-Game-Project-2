extends Node
class_name component_state_controller

@export var my_component_input_controller : component_input_controller
@export var my_component_ability: component_ability

@onready var direction := Vector2.ZERO

func _ready() -> void:
	Events.turn_start.connect(_on_turn_start)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	#Explore
	owner.get_node("StateChart/Main/Explore/Walking").state_physics_processing.connect(_on_state_physics_processing_explore_walking)
	owner.get_node("StateChart/Main/Explore").state_physics_processing.connect(_on_state_physics_processing_explore)
	owner.get_node("StateChart/Main/Explore/Idle").state_physics_processing.connect(_on_state_physics_processing_explore_idle)
	#Battle
	
	owner.get_node("StateChart/Main/Battle/Waiting").state_physics_processing.connect(_on_state_physics_processing_battle_waiting)
	owner.get_node("StateChart/Main/Battle/Start").state_entered.connect(_on_state_entered_battle_start)
	owner.get_node("StateChart/Main/Battle/Choose").state_entered.connect(_on_state_entered_battle_choose)
	owner.get_node("StateChart/Main/Battle/Choose").state_exited.connect(_on_state_exited_battle_choose)
	owner.get_node("StateChart/Main/Battle/Skillcheck").state_entered.connect(_on_state_entered_battle_skillcheck)
	owner.get_node("StateChart/Main/Battle/Execution").state_entered.connect(_on_state_entered_battle_execution)
	owner.get_node("StateChart/Main/Battle/Execution").state_physics_processing.connect(_on_state_physics_processing_battle_execution)
	owner.get_node("StateChart/Main/Battle/End").state_physics_processing.connect(_on_state_physics_processing_battle_end)
	#Death
	owner.get_node("StateChart/Main/Death").state_entered.connect(_on_state_entered_death)
	
func _physics_process(_delta: float) -> void:
	if my_component_input_controller:
		direction = my_component_input_controller.direction
	
	#FIXME bandaid
	if owner.state_init_override:
		owner.state_chart.send_event(owner.state_init_override)
		owner.state_init_override = null

#Explore
func _on_state_physics_processing_explore(_delta: float) -> void:
		
	if Input.is_action_just_pressed("interact"):
		Dialogic.start("timeline")
	
	# MAKE SURE YOU UNDERSTAND THE ORDER OF THE OBJECT IS THE ORDER THEY WILL TAKE TURNS IN LATER
	if Input.is_action_just_pressed("ui_cancel"):
		Battle.battle_initialize([owner,owner,owner,owner],[{"test":123},{"ababab":60000000},{"alignment":"foes"},{"alignment":"foes"}],owner.get_tree(),"res://scenes/turn_arena.tscn")
func _on_state_physics_processing_explore_idle(_delta: float) -> void:
	if direction != Vector2.ZERO:
		owner.state_chart.send_event("on_walking")
func _on_state_physics_processing_explore_walking(_delta: float) -> void:
	if direction == Vector2.ZERO:
		owner.state_chart.send_event("on_idle")

#Battle

func _on_turn_start():
	if Battle.active_character == owner:
		print_debug(owner.name,": It's my turn")
		owner.state_chart.send_event("on_start")
		owner.state_init_override = "on_start" #FUCK this state machine sometimes
	else:
		owner.state_chart.send_event("on_waiting")

func _on_state_physics_processing_battle_waiting(_delta: float) -> void:
	pass

func _on_state_entered_battle_start():
	#TODO check if it's our turn, and if it is, run start conditions like
	# setting stats or whatever if we have a boost like certain pokemon
	# If this is the first round of turns (we will check and keep track with var), skip choose and skillcheck
	if !owner.sprite.attack_contact.is_connected(_on_attack_contact):
		owner.sprite.attack_contact.connect(_on_attack_contact) #For informing us when to hit target with cast()
	owner.state_chart.send_event("on_choose") #TODO Add something here later for initializing battle
	
func _on_state_entered_battle_choose():
	owner.my_battle_gui.state_chart.send_event("on_gui_main")
func _on_state_exited_battle_choose():
	owner.my_battle_gui.state_chart.send_event("on_gui_disabled") #TODO maybe add a transition to skillcheck in the gui here
	
func _on_state_entered_battle_skillcheck():
	var result = randf_range(0,1) #TODO Add skillcheck GUI thing, that will also handle going to execution
	owner.my_component_ability.cast_queue.skillcheck(result)
	owner.state_chart.send_event("on_execution")
	
func _on_state_entered_battle_execution():
	owner.my_component_ability.cast_queue.animation()
func _on_state_physics_processing_battle_execution(_delta: float) -> void:
	await owner.anim_tree.animation_finished
	owner.state_chart.send_event("on_end")

func _on_state_physics_processing_battle_end(_delta: float) -> void:
	if Battle.battle_list_ready:
		owner.state_chart.send_event("on_waiting")
		Events.turn_end.emit()
	
	# setting stats or whatever if we have a boost like certain pokemon after attacking
	# can also be checking for things that affect us when we hit enemy

#Contact
func _on_attack_contact():
	owner.my_component_ability.cast_queue.cast()

#Death
func _on_state_entered_death():
	Battle.battle_list_ready = false
	await owner.anim_tree.animation_finished
	Battle.battle_list_ready = true
	
	Battle.battle_list.pop_at(Battle.battle_list.find(owner,0)) #remove us from queue
	
	#Check if we are the last one
	if len(Battle.get_team("foes")) == 0: #TODO Make an end battle screen? Nah actually
		Events.battle_finished.emit("Win")
	elif len(Battle.get_team("friends")) == 0:
		Events.battle_finished.emit("Lose")
	elif Battle.active_character == owner:
		Events.turn_end.emit() #FIXME EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
	
	owner.queue_free()

#Dialogic signals
func _on_dialogic_signal(arg : String) -> void:
	#pass on the string from dialogue signal to state machine
	owner.state_chart.send_event(arg)
