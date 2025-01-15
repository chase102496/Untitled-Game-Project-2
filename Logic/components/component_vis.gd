class_name component_vis
extends component_node

signal vis_changed(amt : int)

@export var max_vis : int = 6
@export var status_hud : Node3D

var vis : int:
	set(value):
		vis = value
		_update(value)

func _ready() -> void:
	if !vis:
		vis = max_vis
	_update(0)

## Local and global emission of health changed event
func _update(amt : int) -> void:
	vis_changed.emit(amt)
	Events.entity_vis_changed.emit(owner,amt)

## Change current vis
## Display will show the change above this entity in colored text
func change(amt : int, display : bool = false):
	
	var old_vis = vis
	
	## Adding to Vis
	if amt > 0:
		if display:
			Glossary.create_text_particle_queue(owner.animations.selector_anchor,str("+ ",abs(amt)),"text_float_away",Color.LIGHT_SKY_BLUE)
	
	## Removing from Vis
	elif amt < 0:
		if display:
			Glossary.create_text_particle_queue(owner.animations.selector_anchor,str("- ",abs(amt)),"text_float_away",Color.FUCHSIA)
		### Checking for overflow damage WIP
		#var overflow = amt + vis
		#if overflow < 0:
			#owner.my_component_health.change(overflow)
	
	vis = clamp(vis + amt,0,max_vis)
	
	Debug.message([old_vis," MP -> ",vis," MP"],Debug.msg_category.BATTLE)
	
	_update(vis - old_vis)
