extends Node

@export var keep_world_nodes := ["PlayerSpawn", "Player", "Floor"]

func _ready() -> void:
	var gameplay = get_node_or_null("GameplayInstance")
	if gameplay == null:
		return
	var world = gameplay.get_node_or_null("World")
	if world == null:
		return
	var level_system = gameplay.get_node_or_null("CoreSystems/LevelSystem")
	if level_system:
		level_system.level_scene_path = ""
		level_system.load_on_ready = false
		level_system.clear_level()
	for child in world.get_children():
		if child.name in keep_world_nodes:
			continue
		child.queue_free()
	var floor = world.get_node_or_null("Floor")
	if floor:
		var floor_mesh = floor.get_node_or_null("FloorMesh")
		if floor_mesh:
			for child in floor_mesh.get_children():
				child.queue_free()
