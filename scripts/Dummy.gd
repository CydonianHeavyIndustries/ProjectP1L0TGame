extends StaticBody3D

@export var max_health := 150.0
var current_health := 150.0
var is_ko := false
var _fill_base_pos := Vector3.ZERO
var _fill_width := 1.0
var mesh_parts: Array[MeshInstance3D] = []

@onready var mesh_root: Node = $DummyMesh
@onready var health_back: MeshInstance3D = $HealthBar/HealthBack
@onready var health_fill: Node3D = $HealthBar/HealthFill
@onready var health_fill_mesh: MeshInstance3D = $HealthBar/HealthFill/HealthFillMesh

func _ready() -> void:
	current_health = max_health
	_cache_mesh_parts()
	_setup_healthbar()
	_update_healthbar()
	_update_color(false)

func take_damage(amount: float) -> void:
	if is_ko:
		return
	current_health = max(0.0, current_health - amount)
	_update_healthbar()
	_update_color(current_health <= 0.0)
	if current_health <= 0.0:
		_start_ko_jump()

func _update_color(dead: bool) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.2, 0.2) if dead else Color(0.95, 0.8, 0.2)
	for part in mesh_parts:
		part.material_override = mat

func _cache_mesh_parts() -> void:
	mesh_parts.clear()
	if mesh_root:
		for child in mesh_root.get_children():
			if child is MeshInstance3D:
				mesh_parts.append(child)

func _setup_healthbar() -> void:
	if health_fill:
		_fill_base_pos = health_fill.position
	if health_fill_mesh and health_fill_mesh.mesh is QuadMesh:
		_fill_width = (health_fill_mesh.mesh as QuadMesh).size.x

	if health_back:
		var back_mat := StandardMaterial3D.new()
		back_mat.albedo_color = Color(0.1, 0.1, 0.1, 0.8)
		back_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		back_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		back_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		health_back.material_override = back_mat

	if health_fill_mesh:
		var fill_mat := StandardMaterial3D.new()
		fill_mat.albedo_color = Color(0.2, 1.0, 0.3, 0.9)
		fill_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fill_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		health_fill_mesh.material_override = fill_mat

func _update_healthbar() -> void:
	if not health_fill:
		return
	var ratio := 0.0
	if max_health > 0.0:
		ratio = current_health / max_health
	ratio = clamp(ratio, 0.0, 1.0)
	health_fill.scale.x = ratio
	health_fill.position.x = _fill_base_pos.x - (_fill_width * (1.0 - ratio) * 0.5)

func _start_ko_jump() -> void:
	if is_ko:
		return
	is_ko = true
	var start_pos := position
	var up_pos := start_pos + Vector3(0, 0.8, 0)
	var tween := create_tween()
	tween.tween_property(self, "position", up_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", start_pos, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(_reset_health)

func _reset_health() -> void:
	current_health = max_health
	is_ko = false
	_update_color(false)
	_update_healthbar()
