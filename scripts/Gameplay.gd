extends Node3D

const DEFAULT_HOST := "127.0.0.1"
const DEFAULT_PORT := 7777

@export var max_players := 16
@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")

@onready var world: Node3D = $World

var players: Dictionary = {}
var run_mode := "offline"
var network_host := DEFAULT_HOST
var network_port := DEFAULT_PORT
var dedicated_server := false

func _ready() -> void:
	_parse_command_line()
	_start_network_mode()
	_register_network_callbacks()

	if run_mode == "offline":
		_spawn_player(1)
	elif run_mode == "server" and not dedicated_server:
		_spawn_player(multiplayer.get_unique_id())

func _parse_command_line() -> void:
	var args := OS.get_cmdline_args()
	for i in args.size():
		var token := String(args[i]).to_lower()
		if token == "--headless":
			dedicated_server = true
		elif token == "--server":
			run_mode = "server"
		elif token == "--connect":
			run_mode = "client"
			if i + 1 < args.size():
				network_host = String(args[i + 1])
		elif token == "--address":
			if i + 1 < args.size():
				network_host = String(args[i + 1])
		elif token == "--port":
			if i + 1 < args.size():
				var parsed := int(String(args[i + 1]))
				if parsed > 0 and parsed <= 65535:
					network_port = parsed

func _start_network_mode() -> void:
	if run_mode == "server":
		var peer := ENetMultiplayerPeer.new()
		var result := peer.create_server(network_port, max_players)
		if result != OK:
			push_warning("Server start failed (%s), running offline." % result)
			run_mode = "offline"
			return
		multiplayer.multiplayer_peer = peer
		return

	if run_mode == "client":
		var peer := ENetMultiplayerPeer.new()
		var result := peer.create_client(network_host, network_port)
		if result != OK:
			push_warning("Client connect failed (%s), running offline." % result)
			run_mode = "offline"
			return
		multiplayer.multiplayer_peer = peer

func _register_network_callbacks() -> void:
	if run_mode == "offline":
		return

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	if run_mode == "client":
		multiplayer.connected_to_server.connect(_on_connected_to_server)
		multiplayer.connection_failed.connect(_on_connection_failed)
		multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected_to_server() -> void:
	# Player spawns are driven by authoritative server RPCs.
	pass

func _on_connection_failed() -> void:
	push_warning("Connection failed, returning to offline mode.")
	multiplayer.multiplayer_peer = null
	run_mode = "offline"
	_spawn_player(1)

func _on_server_disconnected() -> void:
	push_warning("Disconnected from server.")
	for peer_id in players.keys():
		_despawn_player(int(peer_id))
	multiplayer.multiplayer_peer = null
	run_mode = "offline"
	_spawn_player(1)

func _on_peer_connected(peer_id: int) -> void:
	if not multiplayer.is_server():
		return

	for existing_id in players.keys():
		rpc_id(peer_id, "_rpc_spawn_player", int(existing_id))

	rpc("_rpc_spawn_player", peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	rpc("_rpc_despawn_player", peer_id)

@rpc("authority", "call_local", "reliable")
func _rpc_spawn_player(peer_id: int) -> void:
	_spawn_player(peer_id)

@rpc("authority", "call_local", "reliable")
func _rpc_despawn_player(peer_id: int) -> void:
	_despawn_player(peer_id)

func _spawn_player(peer_id: int) -> void:
	if players.has(peer_id):
		return

	var player: CharacterBody3D = player_scene.instantiate() as CharacterBody3D
	if player == null:
		return

	player.name = "Player_%s" % peer_id
	player.global_position = _spawn_position_for(peer_id)
	world.add_child(player)

	var local_control := _is_local_player(peer_id)
	player.call("configure_player", peer_id, local_control, dedicated_server)

	players[peer_id] = player

func _despawn_player(peer_id: int) -> void:
	if not players.has(peer_id):
		return
	var player: Node = players[peer_id]
	players.erase(peer_id)
	if is_instance_valid(player):
		player.queue_free()

func _spawn_position_for(peer_id: int) -> Vector3:
	var slot := int(peer_id % 8)
	return Vector3((slot - 4) * 1.4, 1.5, 0.0)

func _is_local_player(peer_id: int) -> bool:
	if run_mode == "offline":
		return true
	if dedicated_server:
		return false
	return peer_id == multiplayer.get_unique_id()
