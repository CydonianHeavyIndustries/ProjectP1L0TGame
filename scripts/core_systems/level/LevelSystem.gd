extends Node

@export var level_scene_path := ""
@export var world_path: NodePath = NodePath("../World")
@export var level_root_path: NodePath = NodePath("../World/LevelRoot")
@export var player_path: NodePath = NodePath("../World/Player")
@export var load_on_ready := true
@export var auto_spawn_player := true

var level_instance: Node = null

func _ready() -> void:
	if load_on_ready and level_scene_path != "":
		load_level(level_scene_path)

func load_level(path: String) -> void:
	if path == "":
		return
	clear_level()
	var scene = load(path)
	if scene == null or not (scene is PackedScene):
		return
	level_instance = (scene as PackedScene).instantiate()
	if level_instance == null:
		return
	var root = _get_level_root()
	if root:
		root.add_child(level_instance)
	else:
		add_child(level_instance)
	level_instance.add_to_group("level")
	if auto_spawn_player:
		_try_set_spawn(level_instance)

func clear_level() -> void:
	if level_instance and is_instance_valid(level_instance):
		level_instance.queue_free()
	level_instance = null

func _get_level_root() -> Node:
	if level_root_path == NodePath():
		return null
	var root = get_node_or_null(level_root_path)
	return root

func _try_set_spawn(level_root: Node) -> void:
	var player = get_node_or_null(player_path)
	if player == null:
		return
	var spawn = _find_spawn(level_root)
	if spawn and spawn is Node3D:
		(player as Node3D).global_transform = (spawn as Node3D).global_transform
		if player.has_method("set_spawn_transform"):
			player.set_spawn_transform((spawn as Node3D).global_transform)

func _find_spawn(root: Node) -> Node:
	if root.is_in_group("player_spawn") or root.is_in_group("level_spawn"):
		return root
	for child in root.get_children():
		var found = _find_spawn(child)
		if found:
			return found
	return null
