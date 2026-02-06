extends CharacterBody3D

@export var walk_speed := 7.0
@export var sprint_speed := 12.0
@export var jump_velocity := 4.5
@export var slide_speed := 16.0
@export var slide_time := 0.35
@export var gravity := 9.8
@export var max_health := 100.0
@export var wallrun_speed := 11.0
@export var wallrun_gravity := 2.5
@export var wallrun_duration := 1.1
@export var wallrun_min_speed := 6.5
@export var wallrun_push := 5.5

@export var fire_rate := 8.0
@export var fire_damage := 25.0
@export var fire_range := 60.0
@export var recoil_strength := 0.008
@export var mag_size := 24
@export var reserve_ammo := 120
@export var reload_time := 1.2

var current_health := 100.0
var sliding := false
var slide_timer := 0.0
var fire_cooldown := 0.0
var ammo_in_mag := 24
var is_reloading := false
var wallrunning := false
var wallrun_timer := 0.0
var wallrun_normal := Vector3.ZERO

@onready var cam: Camera3D = $Camera

func _ready() -> void:
	current_health = max_health
	ammo_in_mag = mag_size
	_ensure_input_mappings()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * 0.002)
		cam.rotate_x(-event.relative.y * 0.002)
		cam.rotation.x = clamp(cam.rotation.x, -1.3, 1.3)

func _process(delta: float) -> void:
	fire_cooldown = max(0.0, fire_cooldown - delta)

	if Input.is_action_just_pressed("reload"):
		_start_reload()

	if Input.is_action_pressed("fire"):
		_try_fire()

func _physics_process(delta: float) -> void:
	var input_dir = _get_move_input()

	var speed = sprint_speed if Input.is_action_pressed("sprint") else walk_speed

	if Input.is_action_just_pressed("slide") and not sliding and is_on_floor():
		sliding = true
		slide_timer = slide_time

	if sliding:
		speed = slide_speed
		slide_timer -= delta
		if slide_timer <= 0.0:
			sliding = false

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if wallrunning:
		wallrun_timer -= delta
		if wallrun_timer <= 0.0 or is_on_floor():
			_stop_wallrun()
		else:
			var wall_dir = wallrun_normal.cross(Vector3.UP).normalized()
			if wall_dir.dot(-transform.basis.z) < 0:
				wall_dir = -wall_dir
			velocity.y = -wallrun_gravity
			velocity.x = wall_dir.x * wallrun_speed
			velocity.z = wall_dir.z * wallrun_speed
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_velocity
				velocity += wallrun_normal * wallrun_push
				_stop_wallrun()
	else:
		if not is_on_floor():
			velocity.y -= gravity * delta
			_try_start_wallrun(direction)
		elif Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	move_and_slide()

func _get_move_input() -> Vector2:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	if input_dir == Vector2.ZERO:
		if Input.is_key_pressed(68):
			input_dir.x += 1
		if Input.is_key_pressed(65):
			input_dir.x -= 1
		if Input.is_key_pressed(87):
			input_dir.y += 1
		if Input.is_key_pressed(83):
			input_dir.y -= 1
	return input_dir.normalized()

func _ensure_input_mappings() -> void:
	_ensure_key_action("move_forward", 87)
	_ensure_key_action("move_back", 83)
	_ensure_key_action("move_left", 65)
	_ensure_key_action("move_right", 68)
	_ensure_key_action("jump", 32)
	_ensure_key_action("sprint", 16777248)
	_ensure_key_action("slide", 67)
	_ensure_key_action("reload", 82)
	_ensure_key_action("ui_cancel", 16777217)
	_ensure_mouse_action("fire", 1)

func _ensure_key_action(action: StringName, keycode: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var has_key := false
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey and ev.keycode == keycode:
			has_key = true
			break
	if not has_key:
		var ev_key := InputEventKey.new()
		ev_key.keycode = keycode
		InputMap.action_add_event(action, ev_key)

func _ensure_mouse_action(action: StringName, button_index: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var has_button := false
	for ev in InputMap.action_get_events(action):
		if ev is InputEventMouseButton and ev.button_index == button_index:
			has_button = true
			break
	if not has_button:
		var ev_button := InputEventMouseButton.new()
		ev_button.button_index = button_index
		InputMap.action_add_event(action, ev_button)

func _try_start_wallrun(direction: Vector3) -> void:
	if wallrunning:
		return
	if direction.length() < 0.1:
		return
	if velocity.length() < wallrun_min_speed:
		return
	var space = get_world_3d().direct_space_state
	var origin = global_transform.origin
	var left = -global_transform.basis.x
	var right = global_transform.basis.x
	var params_left = PhysicsRayQueryParameters3D.create(origin, origin + left * 1.1)
	params_left.exclude = [self]
	var hit_left = space.intersect_ray(params_left)
	var params_right = PhysicsRayQueryParameters3D.create(origin, origin + right * 1.1)
	params_right.exclude = [self]
	var hit_right = space.intersect_ray(params_right)
	var hit = hit_left if hit_left else hit_right
	if hit and hit.has("normal"):
		wallrun_normal = hit["normal"]
		wallrunning = true
		wallrun_timer = wallrun_duration

func _stop_wallrun() -> void:
	wallrunning = false
	wallrun_timer = 0.0
	wallrun_normal = Vector3.ZERO

func _try_fire() -> void:
	if is_reloading:
		return
	if fire_cooldown > 0.0:
		return
	if ammo_in_mag <= 0:
		_start_reload()
		return

	ammo_in_mag -= 1
	fire_cooldown = 1.0 / fire_rate
	_apply_recoil()
	_fire_hitscan()

func _fire_hitscan() -> void:
	var from = cam.global_transform.origin
	var to = from + (-cam.global_transform.basis.z * fire_range)
	var space = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	var result = space.intersect_ray(params)
	if result and result.has("collider"):
		var target = result["collider"]
		if target and target.has_method("take_damage"):
			target.take_damage(fire_damage)

func _apply_recoil() -> void:
	cam.rotate_x(-recoil_strength)
	cam.rotation.x = clamp(cam.rotation.x, -1.3, 1.3)

func _start_reload() -> void:
	if is_reloading:
		return
	if ammo_in_mag >= mag_size:
		return
	if reserve_ammo <= 0:
		return
	is_reloading = true
	var timer = get_tree().create_timer(reload_time)
	timer.timeout.connect(_finish_reload)

func _finish_reload() -> void:
	is_reloading = false
	var needed = mag_size - ammo_in_mag
	var take = min(needed, reserve_ammo)
	ammo_in_mag += take
	reserve_ammo -= take

func take_damage(amount: float) -> void:
	current_health = max(0.0, current_health - amount)
