extends Node

@export var animation : String
@export var animation_player : AnimationPlayer
@export var listen_node : Node
@export var node_signal_name : String

func _ready() -> void:
	listen_node.connect(node_signal_name,Callable(self,"_on_animation_signal")) #So we don't recieve args

func _on_animation_signal() -> void:
	animation_player.play(animation)
