## This will listen for the inputs under my_impulse, and when they are all activated, it will send its own impulse
class_name component_impulse_filter_gate
extends component_impulse_filter

## Gates that are currently activated in our impulse list
var gates_activated : int = 0
## Total amount of gates in our impulse list
var gates_total : int = 0

@export_enum("AND","OR") var gate : String

## Input for gate. Will ignore empties
var my_impulse_count : int = 8
@export var my_impulse_0 : component_impulse
@export var my_impulse_1 : component_impulse
@export var my_impulse_2 : component_impulse
@export var my_impulse_3 : component_impulse
@export var my_impulse_4 : component_impulse
@export var my_impulse_5 : component_impulse
@export var my_impulse_6 : component_impulse
@export var my_impulse_7 : component_impulse

func _ready() -> void:
	
	var impulse_placeholder : String = "my_impulse_"
	
	for i in my_impulse_count:
		if get(str(impulse_placeholder,i)):
			var impulse_inst = get(str(impulse_placeholder,i))
			
			match gate:
				"AND":
					impulse_inst.activated.connect(_on_activated_AND)
					impulse_inst.deactivated.connect(_on_deactivated_AND)
					gates_total += 1
				"OR":
					impulse_inst.activated.connect(_on_activated_OR)
					impulse_inst.deactivated.connect(_on_deactivated_OR)
					gates_total += 1
			

## --- AND --- ##
# All signals activated = activated, otherwise, deactivated

#func _update_gates() -> void:
	#for impulse_child in [my_impulse_0,my_impulse_1,my_impulse_2,my_impulse_3,my_impulse_4,my_impulse_5,my_impulse_6,my_impulse_7]:
		#if impulse_child:
			#impulse_child.state_chart.get_current_state() == "Activated"

func _update_gates_activated(val : int) -> void:
	gates_activated = clamp(gates_activated + val,0,gates_total)
	Debug.message(["++ ",gates_activated," / ",gates_total])

func _on_activated_AND() -> void:
	
	_update_gates_activated(1)
	
	if gates_activated == gates_total:
		Debug.message(["!! ",gates_activated," / ",gates_total])
		activated.emit()

func _on_deactivated_AND() -> void:
	
	_update_gates_activated(-1)
	
	if gates_activated != gates_total:
		deactivated.emit()

## --- OR --- ##
# 1 or more signals = activated, otherwise, deactivated

func _on_activated_OR() -> void:
	
	_update_gates_activated(1)
	
	activated.emit()

func _on_deactivated_OR() -> void:

	_update_gates_activated(-1)
	
	if gates_activated == 0:
		deactivated.emit()
