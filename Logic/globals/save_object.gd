class_name save_object
extends Node

## Valid places this object can be saved to and loaded from
var valid_worlds_save : Array[int] = [Global.scene_type.WORLD,Global.scene_type.BATTLE]
var valid_worlds_load : Array[int] = [Global.scene_type.WORLD,Global.scene_type.BATTLE]
