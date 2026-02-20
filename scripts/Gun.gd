extends Node3D

@export var mag_eject_offset := Vector3(0.16, -0.18, 0.08)
@export var mag_eject_rotation := Vector3(-0.45, 0.0, -0.22)
@export var mag_anim_time := 0.25
@export var recoil_kick := Vector3(0.0, 0.0, 0.045)
@export var recoil_rot := Vector3(0.03, 0.0, 0.0)
@export var recoil_time := 0.05
@export var melee_offset := Vector3(0.06, -0.03, -0.08)
@export var melee_rot := Vector3(-0.2, 0.1, 0.0)
@export var melee_time := 0.1

var rifle_root: Node3D
var sniper_root: Node3D
var rocket_root: Node3D
var pistol_root: Node3D
var sword_root: Node3D
var rifle_mag: Node3D
var sniper_mag: Node3D
var pistol_mag: Node3D

var _mag_home := Vector3.ZERO
var _mag_home_rot := Vector3.ZERO
var _gun_home := Vector3.ZERO
var _gun_home_rot := Vector3.ZERO
var _reload_tween: Tween
var _recoil_tween: Tween
var _melee_tween: Tween
var _active_mag: Node3D = null

func _ready() -> void:
	_ensure_weapon_nodes()
	_set_weapon_visibility("rifle")
	_active_mag = rifle_mag
	if _active_mag:
		_mag_home = _active_mag.position
		_mag_home_rot = _active_mag.rotation
	_gun_home = position
	_gun_home_rot = rotation

func set_weapon(weapon_name: String) -> void:
	_set_weapon_visibility(weapon_name)
	_active_mag = null
	match weapon_name:
		"rifle":
			_active_mag = rifle_mag
		"sniper":
			_active_mag = sniper_mag
		"pistol":
			_active_mag = pistol_mag
		_:
			_active_mag = null
	if _active_mag:
		_mag_home = _active_mag.position
		_mag_home_rot = _active_mag.rotation

func _set_weapon_visibility(active: String) -> void:
	if rifle_root:
		rifle_root.visible = active == "rifle"
	if sniper_root:
		sniper_root.visible = active == "sniper"
	if rocket_root:
		rocket_root.visible = active == "rocket"
	if pistol_root:
		pistol_root.visible = active == "pistol"
	if sword_root:
		sword_root.visible = active == "sword"

func start_reload(total_time: float) -> void:
	if _active_mag == null:
		return
	if _reload_tween:
		_reload_tween.kill()
	_reload_tween = create_tween()
	var out_time: float = min(mag_anim_time, total_time * 0.25)
	var hold_time: float = max(0.0, total_time - (out_time * 2.0))
	_reload_tween.tween_property(_active_mag, "position", _mag_home + mag_eject_offset, out_time)
	_reload_tween.parallel().tween_property(_active_mag, "rotation", _mag_home_rot + mag_eject_rotation, out_time)
	if hold_time > 0.0:
		_reload_tween.tween_interval(hold_time)
	_reload_tween.tween_property(_active_mag, "position", _mag_home, out_time)
	_reload_tween.parallel().tween_property(_active_mag, "rotation", _mag_home_rot, out_time)

func kick(_strength: float) -> void:
	if _recoil_tween:
		_recoil_tween.kill()
	_recoil_tween = create_tween()
	_recoil_tween.tween_property(self, "position", _gun_home + recoil_kick, recoil_time)
	_recoil_tween.parallel().tween_property(self, "rotation", _gun_home_rot + recoil_rot, recoil_time)
	_recoil_tween.tween_property(self, "position", _gun_home, recoil_time * 1.6)
	_recoil_tween.parallel().tween_property(self, "rotation", _gun_home_rot, recoil_time * 1.6)

func start_melee() -> void:
	if _melee_tween:
		_melee_tween.kill()
	_melee_tween = create_tween()
	var hit_pos = _gun_home + melee_offset
	var hit_rot = _gun_home_rot + melee_rot
	_melee_tween.tween_property(self, "position", hit_pos, melee_time)
	_melee_tween.parallel().tween_property(self, "rotation", hit_rot, melee_time)
	_melee_tween.tween_property(self, "position", _gun_home, melee_time * 1.2)
	_melee_tween.parallel().tween_property(self, "rotation", _gun_home_rot, melee_time * 1.2)

func _ensure_weapon_nodes() -> void:
	rifle_root = _ensure_weapon_root("Rifle", Vector3(0.28, -0.2, -0.7), Vector3(0.08, 0.08, 0.58), true)
	sniper_root = _ensure_weapon_root("Sniper", Vector3(0.3, -0.18, -0.8), Vector3(0.08, 0.08, 0.9), true)
	rocket_root = _ensure_weapon_root("RocketLauncher", Vector3(0.35, -0.12, -0.82), Vector3(0.14, 0.14, 0.9), false)
	pistol_root = _ensure_weapon_root("Pistol", Vector3(0.22, -0.25, -0.55), Vector3(0.08, 0.1, 0.28), true)
	sword_root = _ensure_weapon_root("Sword", Vector3(0.25, -0.25, -0.5), Vector3(0.04, 0.6, 0.06), false)

	rifle_mag = _ensure_mag(rifle_root)
	sniper_mag = _ensure_mag(sniper_root)
	pistol_mag = _ensure_mag(pistol_root)

func _ensure_weapon_root(name: String, pos: Vector3, size: Vector3, has_mag: bool) -> Node3D:
	var node := get_node_or_null(name) as Node3D
	if node == null:
		node = Node3D.new()
		node.name = name
		add_child(node)
	var body := node.get_node_or_null("Body") as MeshInstance3D
	if body == null:
		body = MeshInstance3D.new()
		body.name = "Body"
		var mesh := BoxMesh.new()
		mesh.size = size
		body.mesh = mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.65, 0.7, 0.78, 1)
		mat.roughness = 0.9
		body.material_override = mat
		node.add_child(body)
	node.position = pos
	if has_mag and node.get_node_or_null("Mag") == null:
		_ensure_mag(node)
	return node

func _ensure_mag(root: Node3D) -> Node3D:
	if root == null:
		return null
	var mag := root.get_node_or_null("Mag") as Node3D
	if mag == null:
		mag = Node3D.new()
		mag.name = "Mag"
		root.add_child(mag)
		mag.position = Vector3(0.0, -0.08, 0.05)
		var mesh := MeshInstance3D.new()
		mesh.name = "MagMesh"
		var box := BoxMesh.new()
		box.size = Vector3(0.06, 0.16, 0.08)
		mesh.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.22, 0.24, 0.28, 1)
		mat.roughness = 0.85
		mesh.material_override = mat
		mag.add_child(mesh)
	return mag
