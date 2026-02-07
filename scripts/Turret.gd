extends StaticBody3D

@export var max_health := 80.0
@export var fire_interval := 1.1
@export var damage := 10.0
@export var attack_range := 25.0
@export var respawn_delay := 3.0
@export var turn_speed := 6.0
@export var muzzle_height := 0.8
@export var projectile_speed := 6.0
@export var projectile_lifetime := 3.5
@export var projectile_offset := 0.5
@export var projectile_scene: PackedScene = preload("res://scenes/TurretProjectile.tscn")

var current_health := 0.0
var fire_timer := 0.0
var is_dead := false
var is_aggro := false

@onready var collision: CollisionShape3D = $Collision
@onready var mesh_root: Node3D = $TurretMesh

func _ready() -> void:
	current_health = max_health
	fire_timer = fire_interval
	add_to_group("enemy")

func _process(delta: float) -> void:
	if is_dead:
		return
	if not is_aggro:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if player.is_dead:
		return
	var player_pos = (player as Node3D).global_transform.origin
	var origin = global_transform.origin + Vector3(0, muzzle_height, 0)
	var to_player = player_pos - origin
	if to_player.length() > attack_range:
		return

	var target = Vector3(player_pos.x, global_transform.origin.y, player_pos.z)
	var desired = (target - global_transform.origin).normalized()
	var current = -global_transform.basis.z
	var blend = clamp(turn_speed * delta, 0.0, 1.0)
	var new_dir = current.slerp(desired, blend)
	look_at(global_transform.origin + new_dir, Vector3.UP)

	var space = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(origin, player_pos)
	params.exclude = [self]
	var hit = space.intersect_ray(params)
	if hit and hit.has("collider") and hit["collider"] == player:
		fire_timer -= delta
		if fire_timer <= 0.0:
			fire_timer = fire_interval
			_fire_projectile(origin, to_player.normalized())
	else:
		fire_timer = min(fire_timer, fire_interval)

func _fire_projectile(origin: Vector3, direction: Vector3) -> void:
	if projectile_scene == null:
		return
	var projectile = projectile_scene.instantiate()
	if projectile == null:
		return
	var spawn_pos = origin + (direction * projectile_offset)
	if projectile is Node3D:
		projectile.global_position = spawn_pos
	get_parent().add_child(projectile)
	if projectile.has_method("configure"):
		projectile.configure(direction, projectile_speed, damage, projectile_lifetime)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	is_aggro = true
	current_health = max(0.0, current_health - amount)
	if current_health <= 0.0:
		_die()

func _die() -> void:
	is_dead = true
	current_health = 0.0
	if collision:
		collision.disabled = true
	if mesh_root:
		mesh_root.visible = false
	var timer = get_tree().create_timer(respawn_delay)
	timer.timeout.connect(_respawn)

func _respawn() -> void:
	is_dead = false
	is_aggro = false
	current_health = max_health
	if collision:
		collision.disabled = false
	if mesh_root:
		mesh_root.visible = true
	fire_timer = fire_interval
