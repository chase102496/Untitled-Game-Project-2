extends Control

@onready var health : Label = $Ribbon/Health
@onready var vis : Label = $Ribbon/Vis

func _ready() -> void:
	owner.owner.my_component_health.health_changed.connect(_on_health_changed)
	owner.owner.my_component_vis.vis_changed.connect(_on_vis_changed)

func _reset_label(target : Label,amt_changed : int) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(target,"scale",Vector2(1,1),0.2)
	tween.tween_property(target.label_settings,"font_color",Color(255,255,255),0.2)
	tween.tween_property(target,"rotation_degrees",0,0.1)
	
	match target.name:
		"Health":
			if amt_changed < 0:
				tween.tween_property(self,"scale",Vector2(1,1),0.2)
				tween.tween_property(self,"rotation_degrees",0,0.1)

func _update_label(input : Variant, target : Label, amt_changed : int) -> void:
	
	target.text = str(input)
	
	if amt_changed != 0:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_IN)
		
		tween.tween_property(target,"scale",Vector2(3,3),0.05)
		tween.tween_property(target.label_settings,"font_color",Color(255,255,0),0.05)
		tween.tween_property(target,"rotation_degrees",[-45,-30,-15,15,30,45].pick_random(),0.05)
		
		match target.name:
			"Health":
				if amt_changed < 0:
					var ratio = owner.owner.my_component_health.get_current_ratio()
					tween.tween_property(self,"scale",Vector2(1+(ratio/2),1+(ratio/2)),0.05)
					tween.tween_property(self,"rotation_degrees",[-15,-5,5,15].pick_random(),0.05)
		
		tween.set_parallel(false)
		tween.tween_callback(_reset_label.bind(target,amt_changed))

func _on_health_changed(amt_changed : int) -> void:
	_update_label(owner.owner.my_component_health.health,health,amt_changed)


func _on_vis_changed(amt_changed : int) -> void:
	_update_label(owner.owner.my_component_vis.vis,vis,amt_changed)
