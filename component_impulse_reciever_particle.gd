extends component_impulse_reciever_3d

##
@export var anchor : Node = self
##
@export var particle_id : String = "star_explosion"
##
@export var one_shot : bool = true
##
#@export var direction : Vector3

##
@export var particle_flags : Dictionary = {
	"spawn_on_activated" : true,
	"spawn_on_deactivated" : false,
	"kill_on_activated" : false,
	"kill_on_deactivated" : true
}

var particle_inst : Node

func _ready() -> void:
	if my_impulse and particle_id not in Glossary.particle:
		push_error("Unknown particle_id: ",particle_id,name)

func _on_activated() -> void:
	super._on_activated()
	
	particle_inst = Glossary.create_fx_particle_custom(anchor,particle_id,true)

func _on_deactivated() -> void:
	
	if particle_inst:
		particle_inst.queue_free()
