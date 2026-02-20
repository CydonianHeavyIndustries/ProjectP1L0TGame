extends Node
class_name SpaceshipHomeSystem

@export var world_path: NodePath
@export var player_path: NodePath
@export var home_scene: PackedScene = preload("res://scenes/SpaceshipHome.tscn")

const DEBUG_CONFIG = preload("res://scripts/core_systems/DebugConfig.gd")

var _home_instance: Node3D
var _world: Node3D
var _player: CharacterBody3D

func _save_manager() -> Node:
	return get_node_or_null("/root/SaveManager")

func _ready() -> void:
	_world = get_node_or_null(world_path)
	_player = get_node_or_null(player_path)
	_spawn_or_restore_home()
	_respawn_player()
	if _player and _player.has_signal("died"):
		_player.died.connect(_on_player_died)

func _spawn_or_restore_home() -> void:
	if not _world:
		return
	if _home_instance:
		_home_instance.queue_free()
	var save_manager = _save_manager()
	var transform := Transform3D.IDENTITY
	if save_manager and save_manager.has_method("get_spaceship_home_transform"):
		transform = save_manager.get_spaceship_home_transform()
	_home_instance = home_scene.instantiate()
	_world.add_child(_home_instance)
	_home_instance.global_transform = transform
	if save_manager and save_manager.has_method("set_spaceship_home_transform"):
		save_manager.set_spaceship_home_transform(_home_instance.global_transform)
	_log("Home spawned at %s" % str(_home_instance.global_position))

func _log(message: String) -> void:
	if not DEBUG_CONFIG.LOGGING:
		return
	var logger = get_node_or_null("/root/Logger")
	if logger and logger.has_method("info"):
		logger.info("[SpaceshipHomeSystem] " + message)
	else:
		print("[SpaceshipHomeSystem] " + message)

func _respawn_player() -> void:
	if not _player or not _home_instance:
		return
	var spawn_transform = _home_instance.global_transform
	if _home_instance.has_method("get_spawn_transform"):
		spawn_transform = _home_instance.get_spawn_transform()
	if _player.has_method("respawn_at"):
		_player.respawn_at(spawn_transform)
	else:
		_player.global_transform = spawn_transform
		_player.velocity = Vector3.ZERO

func _on_player_died() -> void:
	_respawn_player()
