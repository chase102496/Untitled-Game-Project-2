extends CanvasLayer

signal transitioned_in()
signal transitioned_out()

var current_scene : Node: set=set_current_scene
var prev_scene_path : String = ""
var busy : bool = false
var entry_point : Vector3 = Vector3.ZERO
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var margin_container: MarginContainer = $MarginContainer

func _ready() -> void:
	current_scene = get_tree().current_scene

func set_entry_point(pos : Vector3) -> void:
	entry_point = pos

func set_current_scene(value: Node) -> void:
	if current_scene == null:
		current_scene = value
		return

	current_scene = value
	var root: Window = get_tree().get_root()
	root.get_child(root.get_child_count() - 1).free()
	root.add_child(value)

func transition_in() -> void:
	animation_player.play("in")

func transition_out() -> void:
	create_tween().tween_property(margin_container, "scale", Vector2.ZERO, 0.3)
	animation_player.play("out")

func transition_to_prev() -> void:
	transition_to(prev_scene_path)

func transition_to(scene: String) -> void:
	
	##Make sure we don't try to load another scene
	if !busy:
		busy = true
		
		## Save previous scene path for memory\
		var prefix = "res://Levels/"
		var suffix = ".tscn"
		SceneManager.prev_scene_path = str(prefix, current_scene.name, suffix)
		print_debug("Unloading Scene... ",SceneManager.prev_scene_path)
		
		transition_in()
		await transitioned_in
		
		var new_scene = load(scene).instantiate()
		current_scene = new_scene
		
		new_scene.load_scene()
		
		## Entry point management for scenes
		if entry_point != Vector3.ZERO:
			Global.player.global_position = entry_point #Set the player's position
			entry_point = Vector3.ZERO #Reset the entry point
		
		if new_scene.emits_loaded_signal:
			await new_scene.loaded

		transition_out()
		await transitioned_out
		
		new_scene.activate()
		
		busy = false
		
	else:
		push_error("Tried to load scene while busy! - ",scene)

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "in":
		
		animation_player.play("pulse_text",-1,1.0,true)
		transitioned_in.emit()
	elif anim_name == "out":
		transitioned_out.emit()
