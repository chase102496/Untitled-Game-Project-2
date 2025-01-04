extends Node

var enabled : bool = false

signal debug_enabled
signal debug_disabled

var msg_category : Dictionary = {
	"DEFAULT" : "",
	"INTERACT" : "<INTERACT>",
	"SAVE" : "<SAVE>",
	"BATTLE" : "<BATTLE>",
	"SCENE" : "<SCENE>"
}

func toggle():
	#Invert it
	#Fuckin genius
	enabled = !enabled
	
	if enabled:
		debug_enabled.emit()
	else:
		debug_disabled.emit()

var msg_source_prev : String = ""
func message(msg : Variant, cat : String = msg_category.DEFAULT):
	
	## If message is more important than debug toggle
	var msg_override : bool = false
	
	match cat:
		msg_category.SAVE, msg_category.SCENE:
			msg_override = true
		_:
			pass
	
	if enabled or msg_override:
		var result : String = ""
		
		if msg is Array:
			for m in msg:
				result += str(m)
		else:
			result = str(msg)
		
		var msg_source = str("    |    [SOURCE]: ", get_stack()[-1]["source"])
		
		if msg_source != msg_source_prev:
			result += msg_source
		
		print("[DEBUG_MESSAGE] ",cat," ",result)
		msg_source_prev = msg_source
