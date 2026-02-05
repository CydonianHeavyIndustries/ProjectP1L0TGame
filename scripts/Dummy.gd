extends StaticBody3D

@export var max_health := 150.0
var current_health := 150.0

@onready var mesh: MeshInstance3D = $DummyMesh

func _ready() -> void:
	current_health = max_health
	_update_color(false)

func take_damage(amount: float) -> void:
	current_health = max(0.0, current_health - amount)
	_update_color(current_health <= 0.0)

func _update_color(dead: bool) -> void:
	if not mesh:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.2, 0.2) if dead else Color(0.95, 0.8, 0.2)
	mesh.material_override = mat
