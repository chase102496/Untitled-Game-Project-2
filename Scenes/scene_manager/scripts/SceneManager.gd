extends CanvasLayer

signal transitioned_in()
signal transitioned_out()

signal scene_load_start()
signal scene_load_end()

var current_scene : Node: set=set_current_scene
var prev_scene_path : String = ""
var busy : bool = false
var entry_point : Vector3 = Vector3.ZERO
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var margin_container: MarginContainer = $MarginContainer

func _ready() -> void:
	current_scene = get_tree().current_scene
	SaveManager.load_data_persistent()
	
	init_save_ids()

func init_save_ids() -> void:
	for inst in get_tree().get_nodes_in_group("save_id_scene"):
		if !inst.has_meta("save_id_scene"):
			inst.set_meta("save_id_scene",inst.get_path())

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
		scene_load_start.emit()
		
		## Save previous scene path for memory\
		var prefix = "res://Levels/"
		var suffix = ".tscn"
		SceneManager.prev_scene_path = str(prefix, current_scene.name, suffix)
		Debug.message(["Unloading Scene... ",SceneManager.prev_scene_path],Debug.msg_category.SCENE)
		
		transition_in()
		await transitioned_in
		
		var new_scene = load(scene).instantiate()
		current_scene = new_scene
		
		get_tree().paused = true
		
		new_scene.load_scene()
		
		## Entry point management for scenes
		if entry_point != Vector3.ZERO:
			Global.player.global_position = entry_point #Set the player's position
			entry_point = Vector3.ZERO #Reset the entry point
		
		if new_scene.emits_loaded_signal:
			await new_scene.loaded
		
		init_save_ids()
		
		SaveManager.load_data_session()
		
		get_tree().paused = false
		
		transition_out()
		await transitioned_out
		
		new_scene.activate()
		
		scene_load_end.emit()
		busy = false
		
	else:
		push_error("Tried to load scene while busy! - ",scene)
		#TODO maybe queue it as the next scene instead of cancelling it?

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "in":
		
		animation_player.play("pulse_text",-1,1.0,true)
		transitioned_in.emit()
	elif anim_name == "out":
		transitioned_out.emit()
