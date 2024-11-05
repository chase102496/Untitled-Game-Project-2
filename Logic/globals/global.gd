extends Node
var camera : Node3D = null
var camera_function : Node = null
var player : Node3D = null
var state_chart_already_exists : bool = false
var debug = false

func _ready() -> void:
	Events.scene_tree_ready.connect(_on_scene_tree_ready)

func _on_scene_tree_ready() -> void:
	pass

func scene_transition(scene : NodePath) -> void:
	print(scene)

const alignment : Dictionary = {
	"FRIENDS" : "Friends",
	"FOES" : "Foes"
	}

const type : Dictionary = {
	"EMPTY" : {
		"TITLE" : "",
		"ICON" : ""
	},
	"NEUTRAL" : {
		"TITLE" : "Neutral",
		"ICON" : "●"
	},
	"VOID" : {
		"TITLE" : "Void",
		"ICON" : "✫"
	},
	"NOVA" : {
		"TITLE" : "Nova",
		"ICON" : "✯"
	},
	"TERA" : {
		"TITLE" : "Tera",
		"ICON" : "⬡"
	},
	"ETHEREAL" : {
		"TITLE" : "Ethereal",
		"ICON" : "≋"
	},
}

const status_type : Dictionary = {
	"NORMAL" : {
		"TITLE" : "Normal",
		"ICON" : ""
	},
	"TETHER" : {
		"TITLE" : "Tether",
		"ICON" : "⛓"
	}
}
