class_name GUI
extends Control


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
