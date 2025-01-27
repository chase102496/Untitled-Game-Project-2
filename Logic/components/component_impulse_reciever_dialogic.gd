class_name component_impulse_reciever_dialogic
extends component_impulse_reciever

@export var timeline : DialogicTimeline
var timeline_inst

func _ready() -> void:
	super._ready()
	if timeline:
		timeline_inst = Dialogic.preload_timeline(timeline)

func _on_activated() -> void:
	super._on_activated()
	Dialogic.start(timeline_inst)
