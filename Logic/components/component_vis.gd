class_name component_vis
extends Node

@export var max_vis : int = 6
var vis : int

func _ready() -> void:
	vis = max_vis

func change(amt : int):
	var old_vis = vis
	
	## Adding to Vis
	if amt > 0:
		Glossary.create_text_particle(owner.animations.selector_anchor,str(amt),"float_away",Color.BLUE)
	
	## Removing from Vis
	elif amt < 0:
		Glossary.create_text_particle(owner.animations.selector_anchor,str(amt),"float_away",Color.FUCHSIA)
		## Checking for overflow damage
		var overflow = amt + vis
		if overflow < 0:
			owner.my_component_health.change(overflow)
	
	vis = clamp(vis + amt,0,max_vis)
	print_debug(old_vis," MP -> ",vis," MP")
