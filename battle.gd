extends Node
#This is where all the battle info will be stored
@onready var battle_list_friends : Array
@onready var battle_list_foes : Array

const unit_player: PackedScene = preload("res://scenes/player.tscn")

func set_battle_list(friends,foes):
	battle_list_friends = friends
	battle_list_foes = foes
