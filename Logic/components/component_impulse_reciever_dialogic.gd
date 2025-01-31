class_name component_impulse_reciever_dialogic
extends component_impulse_reciever

@export var timeline : DialogicTimeline
@export_multiline var dialogue : String

var timeline_inst

func _ready() -> void:
	super._ready()
	
	if dialogue:
		timeline = DialogicTimeline.new()
		var events : PackedStringArray = dialogue.split("\n")
		timeline.events = events
	
	if timeline:
		timeline_inst = Dialogic.preload_timeline(timeline)

func _on_activated() -> void:
	super._on_activated()
	Dialogic.start(timeline_inst)
