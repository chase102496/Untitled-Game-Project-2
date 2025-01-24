class_name GUI
extends Control

## Sets a bunch of info for the description of something based on universal gui converter func
func _set_info(properties : Dictionary, icon_slot : Control, label : Control, desc : Control) -> void:
	
	var dict : Dictionary
	
	if properties.get("info"):
		dict = Glossary.convert_info_universal_gui(properties.info)
	elif properties.get("item"):
		dict = Glossary.convert_info_universal_gui(properties.item)
	else:
		push_error("EEE")
	
	_set_info_icon(dict,icon_slot)
	_set_info_text(dict,label,desc)

func _set_info_icon(dict : Dictionary, icon_slot : Control) -> void:
	
	var icon_inst : Control = dict.icon.instantiate()
	
	Global.clear_children(icon_slot)
	
	icon_slot.add_child(icon_inst)

func _set_info_text(dict : Dictionary, label : Control, desc : Control) -> void:
	## This is a standard label
	label.text = dict.header
	## This is a RichTextLabel
	desc.text = str("[center]",dict.description)

## Will create and add a list of buttons to a specific grid, linking up the signals based on the suffix
func _create_button_category_slots(items : Array, output_parent : Control, signal_suffix : String) -> Array:
	
	var button_list = Glossary.create_button_slots(items,output_parent,self,
	"_on_button_pressed_" + signal_suffix,
	"_on_button_enter_hover_" + signal_suffix,
	"_on_button_exit_hover_" + signal_suffix)
	
	## Now we need to make it look like the item
	for button_slot in button_list:
		
		var icon_inst = button_slot.properties.item.icon.instantiate()
		
		button_slot.slot_container.add_child(icon_inst)
		
		## This is where we customize the slots based on item properties
		
		## If it's equipped, color the slot blue
		if button_slot.properties.item.get("my_world_ability"):
			#If stackable, get the quantity and display it in the corner of the slot!
			if button_slot.properties.item.my_world_ability.is_in_equipment():
				button_slot.button.modulate = Global.palette["Medium Slate Blue"]
		
		## If it's a Dreamkin on the field, color the slot blue
		if button_slot.properties.item is world_entity_dreamkin:
			button_slot.button.modulate = Global.palette["Magenta Haze"]
		
		## If it has a quantity and is stackable
		if button_slot.properties.item.get("quantity") and button_slot.properties.item.get("stackable"):
			var inst = Glossary.ui_scene["quantity_slot"].instantiate()
			inst.quantity.text = str(button_slot.properties.item.quantity)
			button_slot.slot_container.add_child(inst)
	
		Global.set_all_nodes_ignore_mouse(button_slot.slot_container)
	
	return button_list
