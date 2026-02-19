extends Node3D

@export var end_node: NodePath
@export var end_offset := Vector3(0, 0, -6)
@export var interact_prompt := "Press E to use zipline"

func get_zipline_dir() -> Vector3:
	var end = get_node_or_null(end_node)
	if end and end is Node3D:
		return (end as Node3D).global_transform.origin - global_transform.origin
	return end_offset

func get_interact_prompt() -> String:
	return interact_prompt
