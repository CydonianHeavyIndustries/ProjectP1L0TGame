extends Node3D

@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")

@onready var world: Node3D = $World

var local_player: CharacterBody3D = null

func _ready() -> void:
	_spawn_local_player()

func _spawn_local_player() -> void:
	if world == null or player_scene == null:
		push_error("Gameplay setup invalid: missing World or player scene.")
		return

	var player := player_scene.instantiate() as CharacterBody3D
	if player == null:
		push_error("Failed to instantiate player scene.")
		return

	player.name = "Player"
	player.position = Vector3(0.0, 1.5, 2.0)
	world.add_child(player)
	local_player = player

	if player.has_method("configure_player"):
		player.call("configure_player", 1, true, false)
	else:
		if not player.is_in_group("local_player"):
			player.add_to_group("local_player")
		var cam := player.get_node_or_null("Camera") as Camera3D
		if cam:
			cam.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
