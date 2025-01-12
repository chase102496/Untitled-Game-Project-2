extends Node

## The scene's camera node will assign itself at _enter_tree 
var current : PhantomCamera3D

func shake(duration : float = 0.2, intensity : float = 0.15) -> void:
	current.shaker.duration = duration
	current.shaker.intensity = intensity
	current.shaker.play_shake()
