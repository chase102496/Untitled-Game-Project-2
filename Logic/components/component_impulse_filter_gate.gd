class_name component_impulse_filter_gate
extends component_impulse_filter

var gates_activated : int = 0
var gates_count : int = 0

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
					gates_count += 1
				"OR":
					impulse_inst.activated.connect(_on_activated_OR)
					impulse_inst.deactivated.connect(_on_deactivated_OR)
					gates_count += 1
			

## --- AND --- ##
# All signals activated = activated, otherwise, deactivated

func _on_activated_AND() -> void:
	
	gates_activated = clamp(gates_activated + 1,0,gates_count)
	
	if gates_activated == gates_count:
		activated.emit()

func _on_deactivated_AND() -> void:
	
	gates_activated = clamp(gates_activated - 1,0,gates_count)
	
	if gates_activated != gates_count:
		deactivated.emit()

## --- OR --- ##
# 1 or more signals = activated, otherwise, deactivated

func _on_activated_OR() -> void:
	
	gates_activated = clamp(gates_activated + 1,0,gates_count)
	
	activated.emit()

func _on_deactivated_OR() -> void:

	gates_activated = clamp(gates_activated - 1,0,gates_count)
	
	if gates_activated == 0:
		deactivated.emit()
