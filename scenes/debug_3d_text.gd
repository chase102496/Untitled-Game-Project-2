extends Label3D

var prev = "init"
var history = ""

func _ready() -> void:
	
	Debug.debug_disabled.connect(_on_debug_disabled)
	Debug.debug_enabled.connect(_on_debug_enabled)
	
	if Debug.enabled:
		_on_debug_enabled()
	else:
		_on_debug_disabled()
	
	#position.y += randf_range(0,0.6)
	modulate = Color(randf_range(0.5,1),randf_range(0.5,1),randf_range(0.5,1))

func _on_debug_disabled() -> void:
	hide()
	owner.animations.status_hud.display_stats(false)
	
func _on_debug_enabled() -> void:
	show()
	owner.animations.status_hud.display_stats(true)

func _physics_process(delta: float) -> void:
	
	if Debug.enabled:
		var abil = owner.my_component_ability.get_data_ability_all()
		var abil_names : Array = []
		
		for i in abil.size():
			abil_names.append(abil[i].title)
		
		var dreamkin_summons = Global.player.my_component_party.my_summons
		var dreamkin_party = Global.player.my_component_party.my_party
		
		var dreamkin_list = []
		
		for i in dreamkin_summons.size():
			if is_instance_valid(dreamkin_summons[i]):
				dreamkin_list.append(dreamkin_summons[i].name)
		dreamkin_list.append(" / ")
		for i in dreamkin_party.size():
			if is_instance_valid(dreamkin_party[i]):
				dreamkin_list.append(dreamkin_party[i].name)
		
		var status_list = []
		if owner.my_component_ability.my_status.NORMAL:
			status_list.append(owner.my_component_ability.my_status.NORMAL.title)
		status_list.append(" / ")
		for i in owner.my_component_ability.my_status.PASSIVE.size():
			status_list.append(owner.my_component_ability.my_status.PASSIVE[i].title)
		
		#if history != owner.state_chart.get_current_state(true):
			#history = prev
			#prev = owner.state_chart.get_current_state(true)
		
		text = str(
		owner.name,
		"\n",
		dreamkin_list,
		"\n",
		abil_names,
		"\n",
		status_list,
		"\n",
		owner.state_chart.get_current_state(true),
		"\n",
		owner.my_component_physics.get_velocity_history(3),
		"\n",
		owner.velocity)
