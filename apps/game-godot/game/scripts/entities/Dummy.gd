extends StaticBody3D

@export var max_health := 150.0
@export var healthbar_height := 1.85
@export var healthbar_forward := 0.18
@export var unit_class := "grunt"
@export var is_upgraded := false
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

func take_damage(amount: float, source: Node = null, cause: String = "") -> void:
	if is_ko:
		return
	current_health = max(0.0, current_health - amount)
	_update_healthbar()
	_update_color(current_health <= 0.0)
	if current_health <= 0.0:
		_award_points(source, cause)
		_start_ko_jump()

func execute(killer: Node) -> void:
	take_damage(max_health, killer, "execute")

func _award_points(source: Node, cause: String) -> void:
	if source == null:
		return
	var point_system = get_tree().get_first_node_in_group("point_system")
	if point_system == null:
		return
	var event_id := "grunt_kill"
	if unit_class != "" and unit_class != "grunt":
		event_id = "%s_kill" % unit_class
	if is_upgraded:
		event_id = "upgraded_%s_kill" % (unit_class if unit_class != "" else "grunt")
	if cause == "execute":
		if is_upgraded:
			event_id = "upgraded_%s_execute" % (unit_class if unit_class != "" else "grunt")
		else:
			event_id = "%s_execute" % (unit_class if unit_class != "" else "grunt")
	if point_system.has_method("award"):
		point_system.award(event_id, source, {"target": self, "upgraded": is_upgraded, "unit_class": unit_class})
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
	if health_back and health_back.get_parent() is Node3D:
		var bar := health_back.get_parent() as Node3D
		bar.position = Vector3(0.0, healthbar_height, healthbar_forward)
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
		health_back.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	if health_fill_mesh:
		var fill_mat := StandardMaterial3D.new()
		fill_mat.albedo_color = Color(0.2, 1.0, 0.3, 0.9)
		fill_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fill_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		health_fill_mesh.material_override = fill_mat
		health_fill_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _update_healthbar() -> void:
	if not health_fill:
		return
	var ratio := 0.0
	if max_health > 0.0:
		ratio = current_health / max_health
	ratio = clamp(ratio, 0.0, 1.0)
	if health_fill_mesh and health_fill_mesh.mesh is QuadMesh:
		var quad := health_fill_mesh.mesh as QuadMesh
		var new_width = max(0.01, _fill_width * ratio)
		quad.size.x = new_width
		health_fill_mesh.mesh = quad
		health_fill_mesh.position.x = -(_fill_width - new_width) * 0.5
	else:
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
