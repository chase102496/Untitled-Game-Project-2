extends Node
var camera : Node3D = null
var player : Node3D = null
var state_chart_already_exists : bool = false
var debug = false

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
