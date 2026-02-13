extends Area3D
class_name SafeZoneArea

@export var zone_id := "main_city"
@export var pvp_disabled := true

@onready var debug_mesh: MeshInstance3D = get_node_or_null("DebugMesh")

func _ready() -> void:
	add_to_group("safe_zone")
	monitoring = true
	monitorable = true
	if debug_mesh:
		debug_mesh.visible = DebugConfig.SHOW_SAFEZONE_GIZMO
