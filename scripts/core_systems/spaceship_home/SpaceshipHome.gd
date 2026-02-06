extends Node3D
class_name SpaceshipHome

@export var home_id := "starter_hab"
@export var spawn_node_path: NodePath = NodePath("SpawnPoint")

func get_spawn_transform() -> Transform3D:
	var spawn_node = get_node_or_null(spawn_node_path)
	if spawn_node:
		return spawn_node.global_transform
	return global_transform
