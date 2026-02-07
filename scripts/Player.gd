extends CharacterBody3D
signal died

@export var walk_speed := 8.5
@export var sprint_speed := 18.5
@export var crouch_speed := 6.0
@export var prone_speed := 2.4
@export var jump_velocity := 7.2
@export var double_jump_velocity := 6.6
@export var max_air_jumps := 1
@export var slide_speed := 16.0
@export var slide_time := 0.35
@export var slide_friction := 7.0
@export var gravity := 9.8
@export var gravity_fall_multiplier := 1.85
@export var gravity_jump_cut_multiplier := 2.4
@export var max_health := 100.0
@export var accel_ground := 24.0
@export var accel_air := 10.0
@export var air_reverse_accel_multiplier := 2.0
@export var decel_ground := 18.0
@export var crouch_cam_offset := -0.45
@export var prone_cam_offset := -0.85
@export var cam_height_lerp := 10.0
@export var look_pitch_min := -1.3
@export var look_pitch_max := 1.3
@export var crouch_capsule_height := 0.7
@export var prone_capsule_height := 0.35
@export var jump_buffer_time := 0.12
@export var wallrun_speed := 11.0
@export var wallrun_accel := 40.0
@export var wallrun_blend_time := 0.16
@export var wallrun_duration := 1.2
@export var wallrun_min_speed := 3.5
@export var wallrun_push := 7
@export var wallrun_jump_speed := 12.0
@export var walljump_alignment_min_multiplier := 0.35
@export var wallrun_jump_up := 5.2
@export var wallrun_stick_time := 0.32
@export var wallrun_gravity_start := 1.8
@export var wallrun_gravity_end := 18.0
@export var wallrun_gravity_curve := 1.7
@export var wallrun_stick_gravity := 0.2
@export var wallrun_stick_force := 20.0
@export var wallrun_ray_length := 0.9
@export var wallrun_contact_gap := 0.12
@export var wallrun_ray_height := 0.35
@export var wallrun_ray_height_top := 1.02
@export var wallrun_roll := 0.22
@export var wallrun_roll_speed := 10.0
@export var wallrun_reentry_delay := 0.18
@export var wallrun_intent_time := 0.2
@export var wallrun_chain_time := 0.45
@export var climb_check_distance := 1.0
@export var climb_height := 1.4
@export var climb_forward_offset := 0.6
@export var climb_speed := 6.5
@export var climb_min_clearance := 0.4
@export var fire_rate := 8.0
@export var fire_damage := 25.0
@export var fire_range := 60.0
@export var recoil_strength := 0.008
@export var recoil_return_speed := 16.0
@export var recoil_max := 0.25
@export var mag_size := 24
@export var reserve_ammo := 120
@export var reload_time := 1.2
@export var safezone_system_path: NodePath
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
@export var slide_landing_inherit := 1.4
@export var slide_downhill_friction_multiplier := 0.03
@export var slide_uphill_speed_multiplier := 0.75
@export var slide_downhill_accel_multiplier := 1.1
@export var crouch_landing_boost_multiplier := 1.15
@export var slide_min_speed := 4.0
@export var respawn_delay := 2.0
@export var hit_vfx_scale := 0.25
@export var hit_vfx_lifetime := 0.12

var current_health := 100.0
var sliding := false
var slide_timer := 0.0
var slide_dir := Vector3.ZERO
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
var wallrun_cooldown := 0.0
var last_wall_normal := Vector3.ZERO
var wallrun_intent := 0.0
var wallrun_entry_speed := 0.0
var wallrun_entry_dir := Vector3.ZERO
var jump_buffer := 0.0
var climbing := false
var climb_target := Vector3.ZERO
var air_jumps_left := 0
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
var safezone_system: Node = null
var base_collider_pos := Vector3.ZERO
var base_capsule_height := 1.2
var base_capsule_radius := 0.35
var recoil_offset := 0.0
var is_dead := false
var spawn_transform := Transform3D.IDENTITY
var hit_audio: AudioStreamPlayer = null
var hurt_audio: AudioStreamPlayer = null
var hit_stream: AudioStreamGenerator = null
var hurt_stream: AudioStreamGenerator = null
var hit_vfx_material: StandardMaterial3D = null
var _jump_down := false
var _sprint_down := false
var _crouch_down := false
var _was_on_floor := true
var _pitch := 0.0
var _reload_down := false
var _titan_down := false
var _fire_down := false
var _aim_down := false
var _esc_down := false

@onready var cam: Camera3D = $Camera
@onready var gun_pivot: Node3D = $Camera/GunPivot
@onready var gun: Node3D = $Camera/GunPivot/Gun
@onready var collider: CollisionShape3D = $PlayerCollision
@onready var blink_marker: Node3D = get_parent().get_node_or_null("BlinkMarker")
@onready var grenade_scene: PackedScene = preload("res://scenes/Grenade_Frag.tscn")

func _ready() -> void:
	current_health = max_health
	ammo_in_mag = mag_size
	air_jumps_left = max_air_jumps
	set_process_input(true)
	set_process_unhandled_input(true)
	_ensure_default_input()
	call_deferred("_capture_mouse")
	call_deferred("_cache_hud")
	call_deferred("_cache_pause_menu")
	add_to_group("player")
	base_cam_pos = cam.position
	base_fov = cam.fov
	_pitch = clamp(cam.rotation.x, look_pitch_min, look_pitch_max)
	_apply_camera_pitch()
	if gun_pivot:
		base_gun_pos = gun_pivot.position
	safezone_system = get_node_or_null(safezone_system_path)
	if safezone_system == null:
		safezone_system = get_tree().get_first_node_in_group("safezone_system")
	_cache_collider()
	if blink_marker:
		blink_marker.visible = false
	_setup_feedback()
	var spawn = get_tree().get_first_node_in_group("player_spawn")
	if spawn and spawn is Node3D:
		spawn_transform = (spawn as Node3D).global_transform
	else:
		spawn_transform = global_transform

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and not get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		_toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("fullscreen"):
		_toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("jump"):
		jump_buffer = jump_buffer_time
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		jump_buffer = jump_buffer_time
	if is_dead:
		return
	if get_tree().paused:
		return
	if event is InputEventMouseButton and event.pressed and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var look_sensitivity := 0.002
		rotate_y(-event.relative.x * look_sensitivity)
		_pitch = clamp(_pitch - event.relative.y * look_sensitivity, look_pitch_min, look_pitch_max)
		_apply_camera_pitch()

func _process(delta: float) -> void:
	if is_dead:
		return
	var esc_pressed = Input.is_action_pressed("ui_cancel") or _key_pressed(KEY_ESCAPE)
	var esc_just_pressed = (esc_pressed and not _esc_down) or Input.is_action_just_pressed("ui_cancel")
	if esc_just_pressed:
		_toggle_pause()
	_esc_down = esc_pressed
	if get_tree().paused:
		return
	fire_cooldown = max(0.0, fire_cooldown - delta)
	grenade_cooldown = max(0.0, grenade_cooldown - delta)
	blink_cooldown = max(0.0, blink_cooldown - delta)
	melee_timer = max(0.0, melee_timer - delta)

	if Input.is_action_just_pressed("debug_kill"):
		take_damage(max_health)

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

	var fire_pressed = Input.is_action_pressed("fire") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	_fire_down = fire_pressed
	if not reload_radial_open and not titan_radial_open and fire_pressed:
		_try_fire()

	if Input.is_action_just_pressed("melee"):
		if melee_timer <= 0.0:
			melee_timer = melee_cooldown
			if gun and gun.has_method("start_melee"):
				gun.start_melee()
		_hud_placeholder("Melee (placeholder)")
	if Input.is_action_just_pressed("class_ability"):
		_hud_placeholder("Blink ability (hold MMB)")
	if Input.is_action_just_pressed("tactical"):
		_hud_placeholder("Grenade (placeholder)")
	if Input.is_action_just_pressed("special1"):
		_hud_placeholder("Special skill 1 (placeholder)")
	if Input.is_action_just_pressed("interact"):
		_hud_placeholder("Interact (placeholder)")
	if Input.is_action_just_pressed("map"):
		_hud_placeholder("Map (placeholder)")
	if Input.is_action_just_pressed("quests"):
		_hud_placeholder("Quests & jobs (placeholder)")
	if Input.is_action_just_pressed("socials"):
		_hud_placeholder("Socials (placeholder)")
	if Input.is_action_just_pressed("inventory"):
		_hud_placeholder("Inventory (placeholder)")
	if Input.is_action_just_pressed("weapon_primary"):
		_hud_placeholder("Main weapon (placeholder)")
	if Input.is_action_just_pressed("weapon_secondary"):
		_hud_placeholder("Secondary weapon (placeholder)")
	if Input.is_action_just_pressed("weapon_tertiary"):
		_hud_placeholder("Tertiary weapon (placeholder)")
	if Input.is_action_just_pressed("weapon_melee"):
		_hud_placeholder("Melee slot (placeholder)")
	if Input.is_action_just_pressed("weapon_extras"):
		_hud_placeholder("Extras slot (placeholder)")
	if Input.is_action_just_pressed("chat"):
		_hud_placeholder("Chat (placeholder)")

	var aim_pressed = Input.is_action_pressed("aim") or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	_aim_down = aim_pressed
	is_aiming = aim_pressed and not is_reloading and not reload_hold and not reload_radial_open and not titan_radial_open and not sliding
	var target_fov = aim_fov if is_aiming else base_fov
	cam.fov = lerp(cam.fov, target_fov, 1.0 - exp(-aim_speed * delta))
	if gun_pivot:
		var target_pos = base_gun_pos + (aim_gun_offset if is_aiming else Vector3.ZERO)
		gun_pivot.position = gun_pivot.position.lerp(target_pos, 1.0 - exp(-aim_gun_lerp * delta))
	_update_recoil(delta)
	_update_wallrun_roll(delta)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	jump_buffer = max(0.0, jump_buffer - delta)
	var on_floor = is_on_floor()
	if climbing:
		_update_climb(delta)
		return
	if on_floor or wallrunning:
		air_jumps_left = max_air_jumps
	var sprint_key = _key_pressed(KEY_SHIFT)
	var sprint_pressed = Input.is_action_pressed("sprint") or sprint_key
	var sprint_just_pressed = Input.is_action_just_pressed("sprint") or (sprint_key and not _sprint_down)
	var crouch_key = _key_pressed(KEY_C)
	var crouch_pressed = Input.is_action_pressed("crouch") or Input.is_action_pressed("slide") or crouch_key
	var crouch_just_pressed = Input.is_action_just_pressed("crouch") or Input.is_action_just_pressed("slide") or (crouch_key and not _crouch_down)
	var jump_key = _key_pressed(KEY_SPACE)
	var jump_just_pressed = Input.is_action_just_pressed("jump") or (jump_key and not _jump_down)
	if jump_just_pressed:
		jump_buffer = jump_buffer_time
	var jump_request = jump_just_pressed or jump_buffer > 0.0
	if jump_just_pressed:
		wallrun_intent = wallrun_intent_time
	if wallrun_intent > 0.0:
		wallrun_intent = max(0.0, wallrun_intent - delta)
	if wallrun_cooldown > 0.0:
		wallrun_cooldown = max(0.0, wallrun_cooldown - delta)
	var input_dir = _get_move_input()
	var horizontal_speed = Vector3(velocity.x, 0, velocity.z).length()
	var prone_just_pressed = Input.is_action_just_pressed("prone")
	var _prone_pressed = Input.is_action_pressed("prone")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if prone_just_pressed:
		is_prone = not is_prone
		if is_prone:
			is_crouching = false

	if is_prone and crouch_just_pressed:
		is_prone = false
		is_crouching = true
	var wants_slide = sprint_pressed and crouch_pressed and (crouch_just_pressed or sprint_just_pressed) and not sliding and on_floor and not is_prone and input_dir.length() > 0.1
	if wants_slide:
		sliding = true
		slide_timer = slide_time
		if direction.length() > 0.1:
			slide_dir = direction
		else:
			slide_dir = -transform.basis.z
		velocity.x = slide_dir.x * slide_speed
		velocity.z = slide_dir.z * slide_speed
	elif crouch_just_pressed and not sliding and on_floor:
		is_crouching = true
	if sliding:
		var slope_dot := 0.0
		var downhill := false
		var slide_speed_now := Vector3(velocity.x, 0, velocity.z).length()
		if on_floor:
			var floor_normal = get_floor_normal()
			if floor_normal != Vector3.ZERO:
				var aligned = slide_dir.slide(floor_normal)
				if aligned.length() > 0.001:
					slide_dir = aligned.normalized()
				var downhill_dir = Vector3.DOWN.slide(floor_normal)
				if downhill_dir.length() > 0.001:
					downhill_dir = downhill_dir.normalized()
					slope_dot = slide_dir.dot(downhill_dir)
					downhill = slope_dot > 0.1
		if not (downhill and crouch_pressed):
			slide_timer -= delta
		if on_floor:
			slide_speed_now = velocity.length()
			if slope_dot < -0.1:
				var uphill_cap = slide_speed * slide_uphill_speed_multiplier
				slide_speed_now = min(slide_speed_now, uphill_cap)
			var friction_mult := 1.0
			if crouch_pressed and downhill:
				friction_mult = slide_downhill_friction_multiplier
			slide_speed_now = max(0.0, slide_speed_now - slide_friction * friction_mult * delta)
			if downhill:
				slide_speed_now += gravity * clamp(slope_dot, 0.0, 1.0) * slide_downhill_accel_multiplier * delta
			velocity = slide_dir * slide_speed_now
		if jump_just_pressed:
			sliding = false
			slide_timer = 0.0
			is_crouching = false
			if on_floor:
				velocity.y = jump_velocity
				velocity += slide_dir * slide_cancel_boost
		var allow_timer_end = not (on_floor and downhill and crouch_pressed)
		if (slide_timer <= 0.0 and allow_timer_end) or slide_speed_now < slide_min_speed:
			sliding = false
			if crouch_pressed and not is_prone:
				is_crouching = true

	if not sliding:
		if is_prone:
			is_crouching = false
		elif on_floor:
			is_crouching = crouch_pressed
	# Prevent mid-air crouch/prone from changing momentum/stance
	if not on_floor and not sliding:
		is_crouching = false
		is_prone = false
	elif not crouch_pressed and not is_prone:
		is_crouching = false

	var speed = walk_speed
	if is_prone:
		speed = prone_speed
	elif is_crouching:
		speed = crouch_speed
	elif sprint_pressed:
		speed = sprint_speed
	if not sliding:
		var accel = accel_ground if on_floor else accel_air
		var decel = decel_ground
		var target_velocity = direction * speed
		var horizontal = Vector3(velocity.x, 0, velocity.z)
		if direction != Vector3.ZERO:
			if not on_floor and velocity.y < 0.0 and horizontal.length() > 0.01 and horizontal.normalized().dot(direction) < 0.0:
				accel *= air_reverse_accel_multiplier
			horizontal = horizontal.move_toward(target_velocity, accel * delta)
		else:
			horizontal = horizontal.move_toward(Vector3.ZERO, decel * delta)
		velocity.x = horizontal.x
		velocity.z = horizontal.z

	if not wallrunning and jump_request and not on_floor and _try_start_climb():
		jump_buffer = 0.0
		return
	if wallrunning:
		wallrun_timer -= delta
		wallrun_elapsed += delta
		var hit = _get_wallrun_hit()
		var wall_speed = Vector3(velocity.x, 0, velocity.z).length()
		if wallrun_timer <= 0.0 or on_floor or not hit or wall_speed < (wallrun_min_speed * 0.45):
			_stop_wallrun()
		else:
			wallrun_normal = hit["normal"]
			var desired = (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
			if desired.length() < 0.1:
				desired = Vector3(velocity.x, 0, velocity.z)
			var wall_dir = _compute_wallrun_dir(wallrun_normal, desired)
			if wall_dir == Vector3.ZERO:
				_stop_wallrun()
			else:
				var wall_horiz = Vector3(velocity.x, 0, velocity.z)
				var blend = 1.0
				if wallrun_blend_time > 0.0:
					blend = clamp(wallrun_elapsed / wallrun_blend_time, 0.0, 1.0)
				var entry_speed = max(wallrun_entry_speed, wallrun_min_speed)
				var target_speed = lerp(entry_speed, wallrun_speed, blend)
				var target = wall_dir * target_speed
				wall_horiz = wall_horiz.move_toward(target, wallrun_accel * delta)
				velocity.x = wall_horiz.x
				velocity.z = wall_horiz.z
				velocity += -wallrun_normal * wallrun_stick_force * delta
				if wallrun_elapsed < wallrun_stick_time:
					var stick_grav = wallrun_gravity_start * wallrun_stick_gravity
					velocity.y = max(velocity.y - (stick_grav * delta), 0.05)
				else:
					var t = clamp((wallrun_elapsed - wallrun_stick_time) / max(0.01, wallrun_duration - wallrun_stick_time), 0.0, 1.0)
					var curve = pow(t, wallrun_gravity_curve)
					var grav = lerp(wallrun_gravity_start, wallrun_gravity_end, curve)
					velocity.y -= grav * delta
				if jump_request:
					var horiz = Vector3(velocity.x, 0, velocity.z)
					var takeoff_dir = horiz
					if takeoff_dir.length() < 0.1:
						takeoff_dir = _compute_wallrun_dir(wallrun_normal, input_dir)
					if takeoff_dir.length() > 0.1:
						takeoff_dir = takeoff_dir.normalized()
					var desired_dir := Vector3.ZERO
					if input_dir.length() > 0.1:
						desired_dir = (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
					if desired_dir.length() < 0.1:
						desired_dir = takeoff_dir
					var wall_jump_dir = takeoff_dir
					if wall_jump_dir.length() < 0.1:
						wall_jump_dir = wallrun_normal.cross(Vector3.UP).normalized()
					var alignment := 1.0
					if wall_jump_dir.length() > 0.1 and desired_dir.length() > 0.1:
						alignment = clamp(abs(wall_jump_dir.dot(desired_dir)), 0.0, 1.0)
					var speed_scale = lerp(walljump_alignment_min_multiplier, 1.0, alignment)
					velocity = takeoff_dir * wallrun_jump_speed * speed_scale
					velocity.y = wallrun_jump_up
					velocity += wallrun_normal * wallrun_push
					jump_buffer = 0.0
					_stop_wallrun(true)
	else:
		if not on_floor:
			var grav = gravity
			if velocity.y < 0.0:
				grav = gravity * gravity_fall_multiplier
			elif velocity.y > 0.0 and not Input.is_action_pressed("jump"):
				grav = gravity * gravity_jump_cut_multiplier
			velocity.y -= grav * delta
			if not is_prone and (input_dir.length() > 0.1 or horizontal_speed > (wallrun_min_speed * 0.6)):
				_try_start_wallrun(input_dir)
			if jump_request and air_jumps_left > 0 and not is_prone:
				air_jumps_left -= 1
				velocity.y = double_jump_velocity
				jump_buffer = 0.0
		elif jump_request:
			if is_prone:
				is_prone = false
				is_crouching = false
			velocity.y = jump_velocity
			jump_buffer = 0.0

	_apply_stance()

	move_and_slide()

	var now_on_floor = is_on_floor()
	if now_on_floor and not _was_on_floor and crouch_pressed and not is_prone and not sliding:
		sliding = true
		slide_timer = slide_time
		var landing_dir = direction
		if landing_dir.length() < 0.1:
			var horiz = Vector3(velocity.x, 0, velocity.z)
			if horiz.length() > 0.1:
				landing_dir = horiz.normalized()
			else:
				landing_dir = -transform.basis.z
		slide_dir = landing_dir
		var floor_normal = get_floor_normal()
		if floor_normal != Vector3.ZERO:
			var aligned = slide_dir.slide(floor_normal)
			if aligned.length() > 0.001:
				slide_dir = aligned.normalized()
		var horiz_speed = Vector3(velocity.x, 0, velocity.z).length()
		var inherited_speed = horiz_speed * slide_landing_inherit
		var boost_speed = max(slide_speed * crouch_landing_boost_multiplier, inherited_speed)
		velocity.x = slide_dir.x * boost_speed
		velocity.z = slide_dir.z * boost_speed

	var target_offset := base_cam_pos
	if is_prone:
		target_offset = base_cam_pos + Vector3(0, prone_cam_offset, 0)
	elif is_crouching or sliding:
		target_offset = base_cam_pos + Vector3(0, crouch_cam_offset, 0)
	cam.position = cam.position.lerp(target_offset, 1.0 - exp(-cam_height_lerp * delta))
	_jump_down = jump_key
	_sprint_down = sprint_key
	_crouch_down = crouch_key
	_was_on_floor = now_on_floor

func _get_move_input() -> Vector2:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input_dir == Vector2.ZERO:
		var x = int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
		var y = int(Input.is_key_pressed(KEY_W)) - int(Input.is_key_pressed(KEY_S))
		input_dir = Vector2(x, y)
	return input_dir.normalized()

func _apply_camera_pitch() -> void:
	if cam == null:
		return
	cam.rotation.x = clamp(_pitch + recoil_offset, look_pitch_min, look_pitch_max)

func _capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _cache_hud() -> void:
	hud = get_tree().get_first_node_in_group("hud")

func _cache_pause_menu() -> void:
	pause_menu = get_tree().get_first_node_in_group("pause_menu")
	if pause_menu and pause_menu.has_method("close"):
		pause_menu.close()
	else:
		get_tree().paused = false

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

func _ensure_default_input() -> void:
	_ensure_key_action("move_forward", KEY_W)
	_ensure_key_action("move_back", KEY_S)
	_ensure_key_action("move_left", KEY_A)
	_ensure_key_action("move_right", KEY_D)
	_ensure_key_action("jump", KEY_SPACE)
	_ensure_key_action("sprint", KEY_SHIFT)
	_ensure_key_action("crouch", KEY_C)
	_ensure_key_action("slide", KEY_C)
	_ensure_key_action("reload", KEY_R)
	_ensure_key_action("ui_cancel", KEY_ESCAPE)
	_ensure_key_action("fullscreen", KEY_F11)
	_ensure_mouse_action("fire", MOUSE_BUTTON_LEFT)
	_ensure_mouse_action("aim", MOUSE_BUTTON_RIGHT)
	_ensure_mouse_action("class_ability", MOUSE_BUTTON_MIDDLE)

func _ensure_key_action(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var events := InputMap.action_get_events(action)
	for ev in events:
		if ev is InputEventKey and ev.keycode == keycode:
			return
	var add := InputEventKey.new()
	add.keycode = keycode
	InputMap.action_add_event(action, add)

func _key_pressed(keycode: int) -> bool:
	return Input.is_key_pressed(keycode) or Input.is_physical_key_pressed(keycode)

func _ensure_mouse_action(action: String, button_index: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var events := InputMap.action_get_events(action)
	for ev in events:
		if ev is InputEventMouseButton and ev.button_index == button_index:
			return
	var add := InputEventMouseButton.new()
	add.button_index = button_index
	InputMap.action_add_event(action, add)

func _handle_reload_input(delta: float) -> void:
	var reload_key = _key_pressed(KEY_R)
	var reload_pressed = Input.is_action_pressed("reload") or reload_key
	var reload_just_pressed = Input.is_action_just_pressed("reload") or (reload_key and not _reload_down)
	var reload_just_released = Input.is_action_just_released("reload") or (not reload_key and _reload_down)
	if reload_just_pressed:
		reload_hold = true
		reload_hold_time = 0.0
		reload_radial_open = false
	if reload_hold:
		reload_hold_time += delta
		if reload_hold_time >= radial_hold_time and not reload_radial_open:
			reload_radial_open = true
			_show_gun_radial(true)
	if reload_just_released and reload_hold:
		if reload_radial_open:
			_show_gun_radial(false)
			var choice := ""
			if hud and hud.has_method("get_gun_radial_choice"):
				choice = hud.get_gun_radial_choice()
			if choice != "":
				_hud_placeholder("Gun menu: %s" % choice)
		else:
			_start_reload()
		reload_hold = false
	if reload_hold and not reload_pressed and reload_hold_time > 0.1:
		# Failsafe if key release wasn't detected
		reload_hold = false
		if reload_radial_open:
			_show_gun_radial(false)
			reload_radial_open = false
	_reload_down = reload_pressed

func _handle_titan_input(delta: float) -> void:
	var titan_key = _key_pressed(KEY_V)
	var titan_pressed = Input.is_action_pressed("titan_drop") or titan_key
	var titan_just_pressed = Input.is_action_just_pressed("titan_drop") or (titan_key and not _titan_down)
	var titan_just_released = Input.is_action_just_released("titan_drop") or (not titan_key and _titan_down)
	if titan_just_pressed:
		titan_hold = true
		titan_hold_time = 0.0
		titan_radial_open = false
	if titan_hold:
		titan_hold_time += delta
		if titan_hold_time >= radial_hold_time and not titan_radial_open:
			titan_radial_open = true
			_show_titan_radial(true)
	if titan_just_released and titan_hold:
		if titan_radial_open:
			_show_titan_radial(false)
			var choice := ""
			if hud and hud.has_method("get_titan_radial_choice"):
				choice = hud.get_titan_radial_choice()
			if choice != "":
				_hud_placeholder("Titan: %s" % choice)
		else:
			_hud_placeholder("Titan drop (placeholder)")
		titan_hold = false
	if titan_hold and not titan_pressed and titan_hold_time > 0.1:
		titan_hold = false
		if titan_radial_open:
			_show_titan_radial(false)
			titan_radial_open = false
	_titan_down = titan_pressed

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

func _set_blink_marker_visible(visible: bool) -> void:
	if blink_marker:
		blink_marker.visible = visible

func _show_gun_radial(visible: bool) -> void:
	if hud and hud.has_method("show_gun_radial"):
		hud.show_gun_radial(visible)
	_set_radial_mouse(visible)

func _show_titan_radial(visible: bool) -> void:
	if hud and hud.has_method("show_titan_radial"):
		hud.show_titan_radial(visible)
	_set_radial_mouse(visible)

func _set_radial_mouse(visible: bool) -> void:
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if not get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _hud_hint(text: String) -> void:
	if hud and hud.has_method("show_hint"):
		hud.show_hint(text)
	else:
		print(text)

func _hud_placeholder(text: String) -> void:
	if hud and hud.has_method("log_placeholder"):
		hud.log_placeholder(text)
	else:
		_hud_hint(text)

func _log(message: String) -> void:
	if not DebugConfig.LOGGING:
		return
	var logger = get_node_or_null("/root/Logger")
	if logger and logger.has_method("info"):
		logger.info("[Player] " + message)
	else:
		print("[Player] " + message)

func _try_start_wallrun(input_dir: Vector2) -> void:
	if wallrunning:
		return
	var horiz_speed = Vector3(velocity.x, 0, velocity.z).length()
	if input_dir.length() < 0.1 and horiz_speed < wallrun_min_speed:
		return
	if horiz_speed < wallrun_min_speed:
		return
	var hit = _get_wallrun_hit()
	if hit and hit.has("normal"):
		if wallrun_cooldown > 0.0 and wallrun_intent <= 0.0 and last_wall_normal != Vector3.ZERO:
			var dot = hit["normal"].dot(last_wall_normal)
			if dot > 0.8:
				return
		var desired = Vector3.ZERO
		if input_dir.length() > 0.1:
			desired = (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
		else:
			desired = Vector3(velocity.x, 0, velocity.z)
		var wall_dir = _compute_wallrun_dir(hit["normal"], desired)
		if wall_dir == Vector3.ZERO:
			return
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
		wallrun_entry_speed = max(Vector3(velocity.x, 0, velocity.z).length(), wallrun_min_speed)
		wallrun_entry_dir = Vector3(velocity.x, 0, velocity.z).normalized()
		wallrun_intent = 0.0
		velocity.y = max(velocity.y, 0.8)
		var horiz = Vector3(velocity.x, 0, velocity.z)
		var target = wall_dir * wallrun_entry_speed
		horiz = horiz.move_toward(target, wallrun_accel * get_physics_process_delta_time())
		velocity.x = horiz.x
		velocity.z = horiz.z

func _compute_wallrun_dir(normal: Vector3, desired: Vector3) -> Vector3:
	if desired.length() < 0.1:
		return Vector3.ZERO
	var desired_dir = desired.normalized()
	var wall_dir = normal.cross(Vector3.UP).normalized()
	if wall_dir.dot(desired_dir) < 0.0:
		wall_dir = -wall_dir
	return wall_dir

func _try_start_climb() -> bool:
	if climbing or wallrunning or sliding or is_prone:
		return false
	var space = get_world_3d().direct_space_state
	var forward = -global_transform.basis.z
	var chest = global_transform.origin + Vector3(0, max(0.6, base_capsule_height * 0.5), 0)
	var wall_to = chest + forward * climb_check_distance
	var wall_params = PhysicsRayQueryParameters3D.create(chest, wall_to)
	wall_params.exclude = [self]
	var wall_hit = space.intersect_ray(wall_params)
	if not wall_hit or not wall_hit.has("normal"):
		return false
	var wall_normal: Vector3 = wall_hit["normal"]
	if abs(wall_normal.dot(Vector3.UP)) > 0.2:
		return false

	var top_from = wall_hit.get("position", wall_to) + Vector3.UP * climb_height
	var top_to = top_from + Vector3.DOWN * (climb_height + 0.6)
	var top_params = PhysicsRayQueryParameters3D.create(top_from, top_to)
	top_params.exclude = [self]
	var top_hit = space.intersect_ray(top_params)
	if not top_hit or not top_hit.has("position") or not top_hit.has("normal"):
		return false
	var top_normal: Vector3 = top_hit["normal"]
	if top_normal.dot(Vector3.UP) < 0.7:
		return false

	var target = top_hit["position"]
	target += Vector3.UP * (base_capsule_height * 0.5 + base_capsule_radius + 0.02)
	target += forward * climb_forward_offset

	# Ensure head clearance
	var head_from = target + Vector3.UP * climb_min_clearance
	var head_to = head_from + Vector3.UP * climb_min_clearance
	var head_params = PhysicsRayQueryParameters3D.create(head_from, head_to)
	head_params.exclude = [self]
	var head_hit = space.intersect_ray(head_params)
	if head_hit:
		return false

	climbing = true
	climb_target = target
	velocity = Vector3.ZERO
	return true

func _update_climb(delta: float) -> void:
	var to_target = climb_target - global_transform.origin
	if to_target.length() < 0.05:
		climbing = false
		return
	var step = climb_speed * delta
	global_position = global_position.move_toward(climb_target, step)

func _stop_wallrun(jumped: bool = false) -> void:
	wallrunning = false
	wallrun_timer = 0.0
	wallrun_elapsed = 0.0
	wallrun_entry_speed = 0.0
	wallrun_entry_dir = Vector3.ZERO
	if wallrun_normal != Vector3.ZERO:
		last_wall_normal = wallrun_normal
		wallrun_cooldown = wallrun_reentry_delay
	wallrun_normal = Vector3.ZERO
	if jumped:
		wallrun_intent = 0.0

func _get_wallrun_hit() -> Dictionary:
	var space = get_world_3d().direct_space_state
	var left = -global_transform.basis.x
	var right = global_transform.basis.x
	var origin_low = global_transform.origin + Vector3(0, wallrun_ray_height, 0)
	var origin_high = global_transform.origin + Vector3(0, wallrun_ray_height_top, 0)
	var params_left_low = PhysicsRayQueryParameters3D.create(origin_low, origin_low + left * wallrun_ray_length)
	params_left_low.exclude = [self]
	var hit_left_low = space.intersect_ray(params_left_low)
	if hit_left_low and _is_wall_surface(hit_left_low):
		return hit_left_low
	var params_right_low = PhysicsRayQueryParameters3D.create(origin_low, origin_low + right * wallrun_ray_length)
	params_right_low.exclude = [self]
	var hit_right_low = space.intersect_ray(params_right_low)
	if hit_right_low and _is_wall_surface(hit_right_low):
		return hit_right_low
	var params_left_high = PhysicsRayQueryParameters3D.create(origin_high, origin_high + left * wallrun_ray_length)
	params_left_high.exclude = [self]
	var hit_left_high = space.intersect_ray(params_left_high)
	if hit_left_high and _is_wall_surface(hit_left_high):
		return hit_left_high
	var params_right_high = PhysicsRayQueryParameters3D.create(origin_high, origin_high + right * wallrun_ray_length)
	params_right_high.exclude = [self]
	var hit_right_high = space.intersect_ray(params_right_high)
	if hit_right_high and _is_wall_surface(hit_right_high):
		return hit_right_high
	return {}

func _is_wall_surface(hit: Dictionary) -> bool:
	if not hit.has("normal"):
		return false
	var normal: Vector3 = hit["normal"]
	return abs(normal.dot(Vector3.UP)) < 0.3

func _toggle_pause() -> void:
	if pause_menu == null:
		pause_menu = get_tree().get_first_node_in_group("pause_menu")
	if pause_menu and pause_menu.has_method("toggle"):
		pause_menu.toggle()
	else:
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
		if target and target.is_in_group("player") and safezone_system and safezone_system.has_method("is_pvp_allowed"):
			if not safezone_system.is_pvp_allowed(self, target):
				_log("PvP blocked by safe zone.")
				return
		if target and target.has_method("take_damage"):
			target.take_damage(fire_damage)
			_on_hit(result)

func _apply_recoil() -> void:
	recoil_offset = clamp(recoil_offset - recoil_strength, -recoil_max, recoil_max)
	if gun and gun.has_method("kick"):
		gun.kick(recoil_strength)

func _on_hit(result: Dictionary) -> void:
	if hud and hud.has_method("show_hitmarker"):
		hud.show_hitmarker()
	_play_beep(hit_audio, hit_stream, 1200.0, 0.06, -10.0)
	if result.has("position"):
		var hit_pos: Vector3 = result["position"]
		var hit_normal: Vector3 = Vector3.ZERO
		if result.has("normal"):
			hit_normal = result["normal"]
		_spawn_hit_vfx(hit_pos, hit_normal)

func _update_recoil(delta: float) -> void:
	if cam == null:
		return
	recoil_offset = lerp(recoil_offset, 0.0, 1.0 - exp(-recoil_return_speed * delta))
	_apply_camera_pitch()

func _update_wallrun_roll(delta: float) -> void:
	if cam == null:
		return
	var target_roll := 0.0
	if wallrunning and wallrun_normal != Vector3.ZERO:
		var wall_on_right = wallrun_normal.dot(global_transform.basis.x) > 0.0
		target_roll = -wallrun_roll if wall_on_right else wallrun_roll
	cam.rotation.z = lerp(cam.rotation.z, target_roll, 1.0 - exp(-wallrun_roll_speed * delta))

func _setup_feedback() -> void:
	hit_audio = AudioStreamPlayer.new()
	hit_stream = AudioStreamGenerator.new()
	hit_stream.mix_rate = 44100
	hit_stream.buffer_length = 0.2
	hit_audio.stream = hit_stream
	hit_audio.volume_db = -8.0
	add_child(hit_audio)

	hurt_audio = AudioStreamPlayer.new()
	hurt_stream = AudioStreamGenerator.new()
	hurt_stream.mix_rate = 44100
	hurt_stream.buffer_length = 0.2
	hurt_audio.stream = hurt_stream
	hurt_audio.volume_db = -6.0
	add_child(hurt_audio)

	hit_vfx_material = StandardMaterial3D.new()
	hit_vfx_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hit_vfx_material.albedo_color = Color(1.0, 0.8, 0.3, 0.95)
	hit_vfx_material.emission = Color(1.0, 0.6, 0.2, 1.0)
	hit_vfx_material.emission_energy_multiplier = 1.6
	hit_vfx_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func _play_beep(player: AudioStreamPlayer, stream: AudioStreamGenerator, freq: float, duration: float, volume_db: float) -> void:
	if player == null or stream == null:
		return
	player.volume_db = volume_db
	player.play()
	var playback = player.get_stream_playback()
	if playback == null:
		return
	playback.clear_buffer()
	var rate = stream.mix_rate
	var frames = int(rate * duration)
	var data := PackedVector2Array()
	data.resize(frames)
	var phase = 0.0
	var inc = TAU * freq / rate
	for i in range(frames):
		var env = 1.0 - (float(i) / float(frames))
		var sample = sin(phase) * 0.22 * env
		data[i] = Vector2(sample, sample)
		phase += inc
	playback.push_buffer(data)

func _spawn_hit_vfx(pos: Vector3, normal: Vector3) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = hit_vfx_scale
	mesh.height = hit_vfx_scale * 2.0
	var fx := MeshInstance3D.new()
	fx.mesh = mesh
	fx.material_override = hit_vfx_material
	fx.global_position = pos + (normal * 0.03)
	if get_parent():
		get_parent().add_child(fx)
	var tween := fx.create_tween()
	tween.tween_property(fx, "scale", Vector3.ONE * 0.6, hit_vfx_lifetime * 0.5).from(Vector3.ONE * 1.2)
	tween.tween_property(fx, "scale", Vector3.ZERO, hit_vfx_lifetime * 0.5)
	tween.tween_callback(fx.queue_free)

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
	if is_dead:
		return
	current_health = max(0.0, current_health - amount)
	if hud and hud.has_method("show_damage_flash"):
		hud.show_damage_flash()
	_play_beep(hurt_audio, hurt_stream, 220.0, 0.12, -6.0)
	if current_health <= 0.0:
		_die()

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	current_health = 0.0
	velocity = Vector3.ZERO
	_hud_hint("You died")
	emit_signal("died")
	var timer = get_tree().create_timer(respawn_delay)
	timer.timeout.connect(_respawn)

func _respawn() -> void:
	is_dead = false
	current_health = max_health
	is_crouching = false
	is_prone = false
	sliding = false
	wallrunning = false
	global_transform = spawn_transform
	velocity = Vector3.ZERO
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
