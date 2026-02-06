extends CharacterBody3D

@export var walk_speed := 7.0
@export var sprint_speed := 12.0
@export var crouch_speed := 4.5
@export var prone_speed := 2.4
@export var jump_velocity := 4.5
@export var slide_speed := 16.0
@export var slide_time := 0.35
@export var slide_friction := 6.0
@export var gravity := 9.8
@export var max_health := 100.0
@export var accel_ground := 24.0
@export var accel_air := 10.0
@export var decel_ground := 18.0
@export var crouch_cam_offset := -0.45
@export var prone_cam_offset := -0.85
@export var cam_height_lerp := 10.0
@export var crouch_capsule_height := 0.7
@export var prone_capsule_height := 0.35
@export var wallrun_speed := 11.0
@export var wallrun_duration := 1.2
@export var wallrun_min_speed := 3.5
@export var wallrun_push := 5.5
@export var wallrun_stick_time := 0.35
@export var wallrun_gravity_start := 0.6
@export var wallrun_gravity_end := 14.0
@export var wallrun_stick_force := 16.0
@export var wallrun_ray_length := 1.1
@export var wallrun_contact_gap := 0.22
@export var wallrun_ray_height := 0.35
@export var wallrun_ray_height_top := 1.05

@export var fire_rate := 8.0
@export var fire_damage := 25.0
@export var fire_range := 60.0
@export var recoil_strength := 0.008
@export var recoil_return_speed := 16.0
@export var recoil_max := 0.25
@export var mag_size := 24
@export var reserve_ammo := 120
@export var reload_time := 1.2
@export var aim_fov := 55.0
@export var aim_speed := 10.0
@export var aim_gun_offset := Vector3(-0.18, 0.05, 0.25)
@export var aim_gun_lerp := 14.0
@export var melee_cooldown := 0.45
@export var radial_hold_time := 0.35
@export var grenade_throw_force := 12.0
@export var grenade_upward_force := 2.5
@export var grenade_cooldown_time := 3.5
@export var blink_range := 12.0
@export var blink_cooldown_time := 6.0
@export var slide_cancel_boost := 2.0

var current_health := 100.0
var sliding := false
var slide_timer := 0.0
var fire_cooldown := 0.0
var ammo_in_mag := 24
var is_reloading := false
var reload_timer_total := 0.0
var reload_timer_remaining := 0.0
var reload_progress := 0.0
var wallrunning := false
var wallrun_timer := 0.0
var wallrun_elapsed := 0.0
var wallrun_normal := Vector3.ZERO
var is_crouching := false
var is_prone := false
var is_aiming := false
var base_cam_pos := Vector3.ZERO
var base_fov := 70.0
var base_gun_pos := Vector3.ZERO
var reload_hold := false
var reload_hold_time := 0.0
var reload_radial_open := false
var titan_hold := false
var titan_hold_time := 0.0
var titan_radial_open := false
var grenade_cooldown := 0.0
var blink_cooldown := 0.0
var blink_hold := false
var blink_target := Vector3.ZERO
var blink_valid := false
var melee_timer := 0.0
var hud: Node = null
var pause_menu: Node = null
var base_collider_pos := Vector3.ZERO
var base_capsule_height := 1.2
var base_capsule_radius := 0.35
var crouch_key_down := false
var prone_key_down := false
var recoil_offset := 0.0
var recoil_applied := 0.0

@onready var cam: Camera3D = $Camera
@onready var gun_pivot: Node3D = $Camera/GunPivot
@onready var gun: Node3D = $Camera/GunPivot/Gun
@onready var collider: CollisionShape3D = $PlayerCollision
@onready var blink_marker: Node3D = get_parent().get_node_or_null("BlinkMarker")
@onready var grenade_scene: PackedScene = preload("res://scenes/Grenade.tscn")

func _ready() -> void:
	current_health = max_health
	ammo_in_mag = mag_size
	_ensure_input_mappings()
	call_deferred("_capture_mouse")
	call_deferred("_cache_hud")
	call_deferred("_cache_pause_menu")
	add_to_group("player")
	base_cam_pos = cam.position
	base_fov = cam.fov
	if gun_pivot:
		base_gun_pos = gun_pivot.position
	_cache_collider()
	if blink_marker:
		blink_marker.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("fullscreen"):
		_toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return
	if get_tree().paused:
		return
	if event is InputEventMouseButton and event.pressed and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * 0.002)
		cam.rotate_x(-event.relative.y * 0.002)
		cam.rotation.x = clamp(cam.rotation.x, -1.3, 1.3)

func _process(delta: float) -> void:
	fire_cooldown = max(0.0, fire_cooldown - delta)
	grenade_cooldown = max(0.0, grenade_cooldown - delta)
	blink_cooldown = max(0.0, blink_cooldown - delta)
	melee_timer = max(0.0, melee_timer - delta)

	_handle_reload_input(delta)
	_handle_titan_input(delta)
	_handle_blink_input(delta)
	_handle_grenade_input()

	if is_reloading:
		reload_timer_remaining = max(0.0, reload_timer_remaining - delta)
		if reload_timer_total > 0.0:
			reload_progress = clamp(1.0 - (reload_timer_remaining / reload_timer_total), 0.0, 1.0)
	else:
		reload_progress = 0.0

	if Input.is_action_pressed("fire"):
		_try_fire()

	if Input.is_action_just_pressed("melee"):
		if melee_timer <= 0.0:
			melee_timer = melee_cooldown
			if gun and gun.has_method("start_melee"):
				gun.start_melee()
		_hud_hint("Melee (placeholder)")
	if Input.is_action_just_pressed("class_ability"):
		_hud_hint("Blink ability (hold MMB)")
	if Input.is_action_just_pressed("tactical"):
		_hud_hint("Grenade (placeholder)")
	if Input.is_action_just_pressed("special1"):
		_hud_hint("Special skill 1 (placeholder)")
	if Input.is_action_just_pressed("interact"):
		_hud_hint("Interact (placeholder)")
	if Input.is_action_just_pressed("map"):
		_hud_hint("Map (placeholder)")
	if Input.is_action_just_pressed("quests"):
		_hud_hint("Quests & jobs (placeholder)")
	if Input.is_action_just_pressed("socials"):
		_hud_hint("Socials (placeholder)")
	if Input.is_action_just_pressed("inventory"):
		_hud_hint("Inventory (placeholder)")
	if Input.is_action_just_pressed("weapon_primary"):
		_hud_hint("Main weapon (placeholder)")
	if Input.is_action_just_pressed("weapon_secondary"):
		_hud_hint("Secondary weapon (placeholder)")
	if Input.is_action_just_pressed("weapon_tertiary"):
		_hud_hint("Tertiary weapon (placeholder)")
	if Input.is_action_just_pressed("weapon_melee"):
		_hud_hint("Melee slot (placeholder)")
	if Input.is_action_just_pressed("weapon_extras"):
		_hud_hint("Extras slot (placeholder)")
	if Input.is_action_just_pressed("chat"):
		_hud_hint("Chat (placeholder)")

	is_aiming = Input.is_action_pressed("aim") and not is_reloading and not reload_hold and not reload_radial_open
	var target_fov = aim_fov if is_aiming else base_fov
	cam.fov = lerp(cam.fov, target_fov, 1.0 - exp(-aim_speed * delta))
	if gun_pivot:
		var target_pos = base_gun_pos + (aim_gun_offset if is_aiming else Vector3.ZERO)
		gun_pivot.position = gun_pivot.position.lerp(target_pos, 1.0 - exp(-aim_gun_lerp * delta))
	_update_recoil(delta)

func _physics_process(delta: float) -> void:
	var input_dir = _get_move_input()
	var crouch_pressed = Input.is_action_pressed("crouch") or Input.is_key_pressed(KEY_CTRL)
	var crouch_just_pressed = Input.is_action_just_pressed("crouch") or (Input.is_key_pressed(KEY_CTRL) and not crouch_key_down)
	var prone_just_pressed = Input.is_action_just_pressed("prone") or (Input.is_key_pressed(KEY_X) and not prone_key_down)
	var prone_pressed = Input.is_action_pressed("prone") or Input.is_key_pressed(KEY_X)

	if prone_just_pressed:
		is_prone = not is_prone
		if is_prone:
			is_crouching = false

	if is_prone and crouch_just_pressed:
		is_prone = false
		is_crouching = true
	if crouch_just_pressed and not sliding and is_on_floor():
		if Input.is_action_pressed("sprint") and not is_prone:
			sliding = true
			slide_timer = slide_time
		else:
			is_crouching = true

	if sliding:
		slide_timer -= delta
		if Input.is_action_just_pressed("jump"):
			sliding = false
			slide_timer = 0.0
			is_crouching = false
			if is_on_floor():
				velocity.y = jump_velocity
				velocity += -transform.basis.z * slide_cancel_boost
		if slide_timer <= 0.0:
			sliding = false
			if crouch_pressed and not is_prone:
				is_crouching = true

	if not sliding:
		if is_prone:
			is_crouching = false
		else:
			is_crouching = crouch_pressed
	elif not crouch_pressed and not is_prone:
		is_crouching = false

	var speed = walk_speed
	if is_prone:
		speed = prone_speed
	elif is_crouching:
		speed = crouch_speed
	elif Input.is_action_pressed("sprint"):
		speed = sprint_speed
	if sliding:
		speed = slide_speed

	var direction = (transform.basis * Vector3(input_dir.x, 0, -input_dir.y)).normalized()
	var accel = accel_ground if is_on_floor() else accel_air
	var decel = slide_friction if sliding else decel_ground
	var target_velocity = direction * speed
	var horizontal = Vector3(velocity.x, 0, velocity.z)
	if direction != Vector3.ZERO:
		horizontal = horizontal.move_toward(target_velocity, accel * delta)
	else:
		horizontal = horizontal.move_toward(Vector3.ZERO, decel * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	if wallrunning:
		wallrun_timer -= delta
		wallrun_elapsed += delta
		var hit = _get_wallrun_hit()
		if hit and hit.has("normal"):
			wallrun_normal = hit["normal"]
		if wallrun_timer <= 0.0 or is_on_floor() or input_dir.y < 0.2 or not hit:
			_stop_wallrun()
		else:
			var wall_dir = wallrun_normal.cross(Vector3.UP).normalized()
			var desired_dir = Vector3(input_dir.x, 0, -input_dir.y)
			var desired_world = Vector3.ZERO
			if desired_dir.length() > 0.1:
				desired_world = (global_transform.basis * desired_dir).normalized()
			else:
				desired_world = Vector3(velocity.x, 0, velocity.z).normalized()
			if desired_world.length() > 0.1 and wall_dir.dot(desired_world) < 0:
				wall_dir = -wall_dir
			velocity.x = wall_dir.x * wallrun_speed
			velocity.z = wall_dir.z * wallrun_speed
			velocity += -wallrun_normal * wallrun_stick_force * delta
			if wallrun_elapsed < wallrun_stick_time:
				velocity.y = max(velocity.y, 0.1)
			else:
				var t = clamp((wallrun_elapsed - wallrun_stick_time) / max(0.01, wallrun_duration - wallrun_stick_time), 0.0, 1.0)
				var grav = lerp(wallrun_gravity_start, wallrun_gravity_end, t)
				velocity.y -= grav * delta
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_velocity
				velocity += wallrun_normal * wallrun_push
				_stop_wallrun()
	else:
		if not is_on_floor():
			velocity.y -= gravity * delta
			if input_dir.y > 0.2 and not is_prone:
				_try_start_wallrun(direction)
		elif Input.is_action_just_pressed("jump"):
			if is_prone:
				is_prone = false
				is_crouching = false
			velocity.y = jump_velocity

	_apply_stance()

	move_and_slide()

	crouch_key_down = crouch_pressed
	prone_key_down = prone_pressed

	var target_offset := base_cam_pos
	if is_prone:
		target_offset = base_cam_pos + Vector3(0, prone_cam_offset, 0)
	elif is_crouching or sliding:
		target_offset = base_cam_pos + Vector3(0, crouch_cam_offset, 0)
	cam.position = cam.position.lerp(target_offset, 1.0 - exp(-cam_height_lerp * delta))

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
	_ensure_key_action("crouch", 16777237)
	_ensure_key_action("reload", 82)
	_ensure_key_action("melee", 70)
	_ensure_key_action("tactical", 71)
	_ensure_key_action("special1", 81)
	_ensure_key_action("prone", 88)
	_ensure_key_action("titan_drop", 86)
	_ensure_key_action("interact", 69)
	_ensure_key_action("map", 77)
	_ensure_key_action("quests", 76)
	_ensure_key_action("socials", 80)
	_ensure_key_action("inventory", 73)
	_ensure_key_action("weapon_primary", 49)
	_ensure_key_action("weapon_secondary", 50)
	_ensure_key_action("weapon_tertiary", 51)
	_ensure_key_action("weapon_melee", 52)
	_ensure_key_action("weapon_extras", 53)
	_ensure_key_action("chat", 13)
	_ensure_key_action("ui_cancel", 16777217)
	_ensure_key_action("fullscreen", KEY_F11)
	_ensure_mouse_action("fire", 1)
	_ensure_mouse_action("aim", 2)
	_ensure_mouse_action("class_ability", 3)

func _capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _cache_hud() -> void:
	hud = get_tree().get_first_node_in_group("hud")

func _cache_pause_menu() -> void:
	pause_menu = get_tree().get_first_node_in_group("pause_menu")

func _cache_collider() -> void:
	if collider and collider.shape is CapsuleShape3D:
		var capsule := collider.shape as CapsuleShape3D
		base_capsule_height = capsule.height
		base_capsule_radius = capsule.radius
		base_collider_pos = collider.position

func _apply_stance() -> void:
	if collider == null:
		return
	if not (collider.shape is CapsuleShape3D):
		return
	var capsule := collider.shape as CapsuleShape3D
	var target_height := base_capsule_height
	if is_prone:
		target_height = prone_capsule_height
	elif is_crouching or sliding:
		target_height = crouch_capsule_height
	target_height = max(0.1, target_height)
	if abs(capsule.height - target_height) > 0.001:
		capsule.height = target_height
	var base_total := base_capsule_height + (base_capsule_radius * 2.0)
	var new_total := target_height + (base_capsule_radius * 2.0)
	var delta := (base_total - new_total) * 0.5
	collider.position.y = base_collider_pos.y - delta

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

func _handle_reload_input(delta: float) -> void:
	if Input.is_action_just_pressed("reload"):
		reload_hold = true
		reload_hold_time = 0.0
		reload_radial_open = false
	if reload_hold:
		reload_hold_time += delta
		if reload_hold_time >= radial_hold_time and not reload_radial_open:
			reload_radial_open = true
			_show_gun_radial(true)
	if Input.is_action_just_released("reload") and reload_hold:
		if reload_radial_open:
			_show_gun_radial(false)
		else:
			_start_reload()
		reload_hold = false

func _handle_titan_input(delta: float) -> void:
	if Input.is_action_just_pressed("titan_drop"):
		titan_hold = true
		titan_hold_time = 0.0
		titan_radial_open = false
	if titan_hold:
		titan_hold_time += delta
		if titan_hold_time >= radial_hold_time and not titan_radial_open:
			titan_radial_open = true
			_show_titan_radial(true)
	if Input.is_action_just_released("titan_drop") and titan_hold:
		if titan_radial_open:
			_show_titan_radial(false)
		else:
			_hud_hint("Titan drop (placeholder)")
		titan_hold = false

func _handle_grenade_input() -> void:
	if Input.is_action_just_pressed("tactical"):
		_try_throw_grenade()

func _handle_blink_input(_delta: float) -> void:
	var pressed = Input.is_action_pressed("class_ability")
	if pressed:
		if not blink_hold:
			blink_hold = true
			blink_valid = false
			_set_blink_marker_visible(true)
		_update_blink_target()
	else:
		if blink_hold:
			_set_blink_marker_visible(false)
			if blink_valid and blink_cooldown <= 0.0:
				global_position = blink_target + Vector3(0.0, base_capsule_radius + (base_capsule_height * 0.5) + 0.05, 0.0)
				velocity = Vector3.ZERO
				blink_cooldown = blink_cooldown_time
			blink_hold = false

func _update_blink_target() -> void:
	var space = get_world_3d().direct_space_state
	var from = cam.global_transform.origin
	var forward = -cam.global_transform.basis.z
	var to = from + forward * blink_range
	var params = PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	var hit = space.intersect_ray(params)
	if hit and hit.has("position"):
		blink_target = hit["position"]
		blink_valid = true
	else:
		var fall_from = to + Vector3(0, 2.0, 0)
		var fall_to = to + Vector3(0, -6.0, 0)
		var down_params = PhysicsRayQueryParameters3D.create(fall_from, fall_to)
		down_params.exclude = [self]
		var down_hit = space.intersect_ray(down_params)
		if down_hit and down_hit.has("position"):
			blink_target = down_hit["position"]
			blink_valid = true
		else:
			blink_valid = false

	if blink_marker:
		blink_marker.global_position = blink_target + Vector3(0.0, 0.02, 0.0)

func _set_blink_marker_visible(show: bool) -> void:
	if blink_marker:
		blink_marker.visible = show

func _show_gun_radial(show: bool) -> void:
	if hud and hud.has_method("show_gun_radial"):
		hud.show_gun_radial(show)

func _show_titan_radial(show: bool) -> void:
	if hud and hud.has_method("show_titan_radial"):
		hud.show_titan_radial(show)

func _hud_hint(text: String) -> void:
	if hud and hud.has_method("show_hint"):
		hud.show_hint(text)

func _try_start_wallrun(direction: Vector3) -> void:
	if wallrunning:
		return
	if direction.length() < 0.1:
		return
	if velocity.length() < wallrun_min_speed:
		return
	var hit = _get_wallrun_hit()
	if hit and hit.has("normal"):
		if hit.has("position"):
			var origin = global_transform.origin + Vector3(0, wallrun_ray_height, 0)
			var dist = origin.distance_to(hit["position"])
			var max_dist = min(wallrun_ray_length * 0.95, base_capsule_radius + wallrun_contact_gap)
			if dist > max_dist:
				return
		wallrun_normal = hit["normal"]
		wallrunning = true
		wallrun_timer = wallrun_duration
		wallrun_elapsed = 0.0
		velocity.y = max(velocity.y, 0.8)

func _stop_wallrun() -> void:
	wallrunning = false
	wallrun_timer = 0.0
	wallrun_elapsed = 0.0
	wallrun_normal = Vector3.ZERO

func _get_wallrun_hit() -> Dictionary:
	var space = get_world_3d().direct_space_state
	var left = -global_transform.basis.x
	var right = global_transform.basis.x
	var origin_low = global_transform.origin + Vector3(0, wallrun_ray_height, 0)
	var origin_high = global_transform.origin + Vector3(0, wallrun_ray_height_top, 0)
	var params_left_low = PhysicsRayQueryParameters3D.create(origin_low, origin_low + left * wallrun_ray_length)
	params_left_low.exclude = [self]
	var hit_left_low = space.intersect_ray(params_left_low)
	if hit_left_low:
		return hit_left_low
	var params_right_low = PhysicsRayQueryParameters3D.create(origin_low, origin_low + right * wallrun_ray_length)
	params_right_low.exclude = [self]
	var hit_right_low = space.intersect_ray(params_right_low)
	if hit_right_low:
		return hit_right_low
	var params_left_high = PhysicsRayQueryParameters3D.create(origin_high, origin_high + left * wallrun_ray_length)
	params_left_high.exclude = [self]
	var hit_left_high = space.intersect_ray(params_left_high)
	if hit_left_high:
		return hit_left_high
	var params_right_high = PhysicsRayQueryParameters3D.create(origin_high, origin_high + right * wallrun_ray_length)
	params_right_high.exclude = [self]
	var hit_right_high = space.intersect_ray(params_right_high)
	if hit_right_high:
		return hit_right_high
	return {}

func _toggle_pause() -> void:
	if pause_menu and pause_menu.has_method("toggle"):
		pause_menu.toggle()

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
	recoil_offset = clamp(recoil_offset + recoil_strength, -recoil_max, recoil_max)
	if gun and gun.has_method("kick"):
		gun.kick(recoil_strength)

func _update_recoil(delta: float) -> void:
	if cam == null:
		return
	recoil_offset = lerp(recoil_offset, 0.0, 1.0 - exp(-recoil_return_speed * delta))
	var delta_offset = recoil_offset - recoil_applied
	if abs(delta_offset) > 0.000001:
		cam.rotate_x(delta_offset)
		cam.rotation.x = clamp(cam.rotation.x, -1.3, 1.3)
		recoil_applied = recoil_offset

func _start_reload() -> void:
	if is_reloading:
		return
	if ammo_in_mag >= mag_size:
		return
	if reserve_ammo <= 0:
		return
	is_reloading = true
	reload_timer_total = reload_time
	reload_timer_remaining = reload_time
	reload_progress = 0.0
	if gun and gun.has_method("start_reload"):
		gun.start_reload(reload_time)
	var timer = get_tree().create_timer(reload_time)
	timer.timeout.connect(_finish_reload)

func _finish_reload() -> void:
	is_reloading = false
	reload_progress = 0.0
	var needed = mag_size - ammo_in_mag
	var take = min(needed, reserve_ammo)
	ammo_in_mag += take
	reserve_ammo -= take

func _try_throw_grenade() -> void:
	if grenade_cooldown > 0.0:
		return
	if grenade_scene == null:
		return
	var grenade = grenade_scene.instantiate()
	if grenade == null:
		return
	var spawn_pos = cam.global_transform.origin + (-cam.global_transform.basis.z * 0.6) + Vector3(0, -0.1, 0)
	if grenade is RigidBody3D:
		grenade.global_position = spawn_pos
		get_parent().add_child(grenade)
		var impulse = (-cam.global_transform.basis.z * grenade_throw_force) + (Vector3.UP * grenade_upward_force)
		grenade.apply_impulse(impulse)
	else:
		grenade.global_position = spawn_pos
		get_parent().add_child(grenade)
	grenade_cooldown = grenade_cooldown_time

func _toggle_fullscreen() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func take_damage(amount: float) -> void:
	current_health = max(0.0, current_health - amount)
