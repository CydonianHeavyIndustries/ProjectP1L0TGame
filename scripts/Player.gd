extends CharacterBody3D
signal died

@export var walk_speed := 7.2
@export var sprint_speed := 20.5
@export var crouch_speed := 5.4
@export var prone_speed := 3.0
@export var jump_velocity := 8.8
@export var double_jump_velocity := 7.8
@export var max_air_jumps := 1
@export var slide_speed := 24.0
@export var slide_time := 0.55
@export var slide_friction := 1.7
@export var gravity := 14.0
@export var gravity_fall_multiplier := 2.2
@export var gravity_jump_cut_multiplier := 1.8
@export var max_health := 100.0
@export var accel_ground := 65.0
@export var accel_air := 20.0
@export var air_reverse_accel_multiplier := 1.8
@export var decel_ground := 110.0
@export var decel_air := 12.0
@export var input_smooth := 10.0
@export var coyote_time := 0.12
@export var air_control := 0.8
@export var crouch_cam_offset := -0.5
@export var prone_cam_offset := -0.7
@export var cam_height_lerp := 10.0
@export var look_pitch_min := -1.3
@export var look_pitch_max := 1.3
@export var crouch_capsule_height := 0.85
@export var prone_capsule_height := 0.6
@export var jump_buffer_time := 0.12
@export var wallrun_speed := 13.0
@export var wallrun_accel := 55.0
@export var wallrun_blend_time := 0.2
@export var wallrun_duration := 1.35
@export var wallrun_min_speed := 4.5
@export var wallrun_push := 6.5
@export var wallrun_jump_speed := 18.5
@export var walljump_alignment_min_multiplier := 0.45
@export var wallrun_jump_up := 7.5
@export var wallrun_stick_time := 0.2
@export var wallrun_gravity_start := 2.4
@export var wallrun_gravity_end := 17.0
@export var wallrun_gravity_curve := 1.25
@export var wallrun_stick_gravity := 0.2
@export var wallrun_stick_force := 32.0
@export var wallrun_up_cap := 0.12
@export var wallrun_vertical_smooth := 22.0
@export var wallrun_entry_vertical_boost := 0.8
@export var wallrun_entry_vertical_smooth := 18.0
@export var wallrun_ray_length := 0.75
@export var wallrun_contact_gap := 0.05
@export var wallrun_ray_height := 0.4
@export var wallrun_ray_height_top := 1.1
@export var wallrun_roll := 0.26
@export var wallrun_roll_speed := 12.0
@export var wallrun_reentry_delay := 0.75
@export var wallrun_intent_time := 0.25
@export var wallrun_chain_time := 0.35
@export var wallrun_steer_speed := 10.0
@export var climb_check_distance := 1.2
@export var climb_height := 1.7
@export var climb_forward_offset := 0.7
@export var climb_speed := 7.0
@export var climb_min_clearance := 0.45
@export var climb_vertical_height := 1.1
@export var climb_vertical_forward := 0.25
@export var grapple_range := 26.0
@export var grapple_speed := 28.0
@export var grapple_cooldown_time := 2.5
@export var grapple_min_distance := 1.2
@export var zipline_speed := 14.0
@export var zipline_cooldown_time := 1.0
@export var xp_base := 100
@export var xp_growth := 1.25
@export var fire_rate := 8.0
@export var fire_damage := 25.0
@export var fire_range := 60.0
@export var bullet_speed := 35.0
@export var bullet_lifetime := 0.8
@export var bullet_tracer_color := Color(1.0, 0.85, 0.3, 0.9)
@export var bullet_tracer_radius := 0.035
@export var recoil_strength := 0.01
@export var recoil_return_speed := 18.0
@export var recoil_max := 0.2
@export var mag_size := 24
@export var reserve_ammo := 120
@export var reload_time := 1.2
@export var network_smoothing := 14.0

var current_health := 100.0
var current_weapon := WEAPON_RIFLE
var weapon_configs := {}
var weapon_mag_store := {}
var weapon_reserve_store := {}
var weapon_mode := "hitscan"
var weapon_projectile_speed := 0.0
var weapon_projectile_lifetime := 0.0
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
var wallrun_chain_timer := 0.0
var wallrun_dir := Vector3.ZERO
var last_wall_normal := Vector3.ZERO
var wallrun_intent := 0.0
var wallrun_entry_speed := 0.0
var wallrun_entry_dir := Vector3.ZERO
var jump_buffer := 0.0
var climbing := false
var climb_target := Vector3.ZERO
var input_smoothed := Vector2.ZERO
var coyote_timer := 0.0
var air_jumps_left := 0
var is_crouching := false
var is_prone := false
var is_aiming := false
var grapple_active := false
var grapple_point := Vector3.ZERO
var grapple_cooldown := 0.0
var zipline_active := false
var zipline_dir := Vector3.ZERO
var zipline_cooldown := 0.0
var current_xp := 0
var current_level := 1
var xp_to_next := 100
var skill_menu_open := false
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
var aim_point := Vector3.ZERO
var aim_point_valid := false
var melee_timer := 0.0
var quick_melee_timer := 0.0
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
var _was_on_floor := true
var _pitch := 0.0

var local_control := false
var remote_target_position := Vector3.ZERO
var remote_target_yaw := 0.0
var remote_target_velocity := Vector3.ZERO

@onready var cam: Camera3D = $Camera
@onready var player_mesh: MeshInstance3D = $PlayerMesh

func _ready() -> void:
	current_health = max_health
	ammo_in_mag = mag_size
	remote_target_position = global_position
	remote_target_yaw = rotation.y

func configure_player(peer_id: int, is_local: bool, dedicated: bool = false) -> void:
	if peer_id > 0:
		set_multiplayer_authority(peer_id)

	local_control = is_local and not dedicated

	if local_control:
		if not is_in_group("local_player"):
			add_to_group("local_player")
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		cam.current = true
		player_mesh.visible = false
		visible = true
	else:
		if is_in_group("local_player"):
			remove_from_group("local_player")
		cam.current = false
		player_mesh.visible = true
		visible = not dedicated

	set_process(local_control)
	set_process_unhandled_input(local_control)

func _unhandled_input(event: InputEvent) -> void:
	if not local_control:
		return

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var look_sensitivity := 0.002
		rotate_y(-event.relative.x * look_sensitivity)
		_pitch = clamp(_pitch - event.relative.y * look_sensitivity, look_pitch_min, look_pitch_max)
		_apply_camera_pitch()

func _process(delta: float) -> void:
	if not local_control:
		return

	fire_cooldown = max(0.0, fire_cooldown - delta)
	grenade_cooldown = max(0.0, grenade_cooldown - delta)
	blink_cooldown = max(0.0, blink_cooldown - delta)
	grapple_cooldown = max(0.0, grapple_cooldown - delta)
	zipline_cooldown = max(0.0, zipline_cooldown - delta)
	melee_timer = max(0.0, melee_timer - delta)
	quick_melee_timer = max(0.0, quick_melee_timer - delta)

	if Input.is_action_just_pressed("debug_kill"):
		take_damage(max_health)
	if Input.is_action_just_pressed("skill_tree"):
		_toggle_skill_tree()
	if Input.is_action_just_pressed("grapple"):
		_try_start_grapple()
	if Input.is_action_just_pressed("interact"):
		var used = _try_start_zipline()
		if not used:
			pass

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

	var fire_pressed = Input.is_action_pressed("fire")
	if not reload_radial_open and not titan_radial_open and fire_pressed:
		_try_fire()

	if Input.is_action_just_pressed("melee"):
		if quick_melee_timer <= 0.0:
			quick_melee_timer = quick_melee_cooldown
			if gun and gun.has_method("start_melee"):
				gun.start_melee()
			_perform_melee()
		_hud_placeholder("Quick Melee")
	if Input.is_action_just_pressed("class_ability"):
		_hud_placeholder("Blink ability (hold MMB)")
	if Input.is_action_just_pressed("tactical"):
		_hud_placeholder("Grenade (placeholder)")
	if Input.is_action_just_pressed("special1"):
		_hud_placeholder("Special skill 1 (placeholder)")
	# Interact handled above (zipline/ammo box/etc).
	if Input.is_action_just_pressed("map"):
		_hud_placeholder("Map (placeholder)")
	if Input.is_action_just_pressed("quests"):
		_hud_placeholder("Quests & jobs (placeholder)")
	if Input.is_action_just_pressed("socials"):
		_hud_placeholder("Socials (placeholder)")
	if Input.is_action_just_pressed("inventory"):
		_hud_placeholder("Inventory (placeholder)")
	if Input.is_action_just_pressed("weapon_primary"):
		_equip_weapon(WEAPON_RIFLE)
	if Input.is_action_just_pressed("weapon_secondary"):
		_equip_weapon(WEAPON_SNIPER)
	if Input.is_action_just_pressed("weapon_tertiary"):
		_equip_weapon(WEAPON_ROCKET)
	if Input.is_action_just_pressed("weapon_melee") and not Input.is_action_pressed("melee"):
		_equip_weapon(WEAPON_PISTOL)
	if Input.is_action_just_pressed("weapon_extras") and not Input.is_action_pressed("melee"):
		_equip_weapon(WEAPON_SWORD)
	if Input.is_action_just_pressed("chat"):
		_hud_placeholder("Chat (placeholder)")
	if Input.is_action_just_pressed("mark_location"):
		var pos = global_transform.origin
		var msg = "MARK: %.2f, %.2f, %.2f" % [pos.x, pos.y, pos.z]
		_hud_placeholder(msg)
		_log(msg)

	var aim_pressed = Input.is_action_pressed("aim")
	is_aiming = aim_pressed and weapon_mode != "melee" and not is_reloading and not reload_hold and not reload_radial_open and not titan_radial_open and not sliding
	var target_fov = aim_fov if is_aiming else base_fov
	cam.fov = lerp(cam.fov, target_fov, 1.0 - exp(-aim_speed * delta))
	if gun_pivot:
		var target_pos = base_gun_pos + (aim_gun_offset if is_aiming else Vector3.ZERO)
		gun_pivot.position = gun_pivot.position.lerp(target_pos, 1.0 - exp(-aim_gun_lerp * delta))
	_update_recoil(delta)
	_update_wallrun_roll(delta)
	_update_aim_point()

func _physics_process(delta: float) -> void:
	if not local_control:
		_tick_remote(delta)
		return

	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	input_dir = input_dir.normalized()

	var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed

	if is_prone and (not on_floor or sliding):
		is_prone = false

	if is_prone and crouch_just_pressed:
		is_prone = false
		is_crouching = true
	var can_slide = on_floor and not sliding and not is_prone and (horizontal_speed >= slide_min_speed or input_dir.length() > 0.1)
	var wants_slide = sprint_pressed and crouch_just_pressed and can_slide
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

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var speed = walk_speed
	if is_prone:
		speed = prone_speed
	elif is_crouching:
		speed = crouch_speed
	elif sprint_pressed:
		speed = sprint_speed
	if not sliding:
		var accel = accel_ground if on_floor else accel_air
		var target_velocity = direction * speed
		var horizontal = Vector3(velocity.x, 0, velocity.z)
		if direction != Vector3.ZERO:
			var control = 1.0
			var applied_accel = accel
			if horizontal.length() > 0.01 and horizontal.normalized().dot(direction) < 0.0:
				# Counter-strafe should be the primary way to slow down.
				applied_accel *= air_reverse_accel_multiplier
			if not on_floor:
				control = air_control
			horizontal = horizontal.move_toward(target_velocity, applied_accel * control * delta)
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
			var wall_dir := wallrun_normal.cross(Vector3.UP).normalized()
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
				if wallrun_dir == Vector3.ZERO:
					wallrun_dir = desired_wall_dir
				var steer = 1.0 - exp(-wallrun_steer_speed * delta)
				wallrun_dir = wallrun_dir.slerp(desired_wall_dir, steer).normalized()
				var wall_horiz = Vector3(velocity.x, 0, velocity.z)
				var blend = 1.0
				if wallrun_blend_time > 0.0:
					blend = clamp(wallrun_elapsed / wallrun_blend_time, 0.0, 1.0)
				var entry_speed = max(wallrun_entry_speed, wallrun_min_speed)
				var target_speed = lerp(entry_speed, wallrun_speed, blend)
				var target = wallrun_dir * target_speed
				wall_horiz = wall_horiz.move_toward(target, wallrun_accel * delta)
				velocity.x = wall_horiz.x
				velocity.z = wall_horiz.z
				var stick_strength = wallrun_stick_force * clamp(blend, 0.2, 1.0)
				velocity += -wallrun_normal * stick_strength * delta
				if wallrun_elapsed < wallrun_stick_time:
					var stick_grav = wallrun_gravity_start * wallrun_stick_gravity
					var target_y = min(velocity.y, wallrun_up_cap) - stick_grav * delta
					velocity.y = move_toward(velocity.y, target_y, wallrun_vertical_smooth * delta)
				else:
					var t = clamp((wallrun_elapsed - wallrun_stick_time) / max(0.01, wallrun_duration - wallrun_stick_time), 0.0, 1.0)
					var curve = pow(t, wallrun_gravity_curve)
					var grav = lerp(wallrun_gravity_start, wallrun_gravity_end, curve)
					var target_y = min(velocity.y - grav * delta, wallrun_up_cap)
					velocity.y = move_toward(velocity.y, target_y, wallrun_vertical_smooth * delta)
				if jump_just_pressed:
					var horiz = Vector3(velocity.x, 0, velocity.z)
					var current_speed = horiz.length()
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
					var base_speed = max(current_speed, wallrun_jump_speed)
					var final_speed = base_speed
					if speed_scale > 1.0:
						final_speed = base_speed * speed_scale
					velocity = takeoff_dir * final_speed
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
			if not is_prone and (horizontal_speed >= wallrun_min_speed or wallrun_intent > 0.0):
				_try_start_wallrun(input_dir)
			if jump_request and air_jumps_left > 0 and not is_prone:
				air_jumps_left -= 1
				velocity.y = double_jump_velocity
				jump_buffer = 0.0
		elif jump_request and (on_floor or coyote_timer > 0.0):
			if is_prone:
				is_prone = false
				is_crouching = false
			velocity.y = jump_velocity
			jump_buffer = 0.0

	_apply_stance()

	move_and_slide()

	if multiplayer.has_multiplayer_peer():
		receive_network_state.rpc(global_position, rotation.y, velocity, current_health, ammo_in_mag, reserve_ammo)

func _tick_remote(delta: float) -> void:
	global_position = global_position.lerp(remote_target_position, min(1.0, network_smoothing * delta))
	rotation.y = lerp_angle(rotation.y, remote_target_yaw, min(1.0, network_smoothing * delta))
	velocity = remote_target_velocity

@rpc("any_peer", "call_remote", "unreliable")
func receive_network_state(position_value: Vector3, yaw_value: float, velocity_value: Vector3, health_value: float, mag_value: int, reserve_value: int) -> void:
	if local_control:
		return

	remote_target_position = position_value
	remote_target_yaw = yaw_value
	remote_target_velocity = velocity_value
	current_health = health_value
	ammo_in_mag = mag_value
	reserve_ammo = reserve_value

func _try_start_wallrun(direction: Vector3) -> void:
	if wallrunning:
		return
	cam.rotation.x = clamp(_pitch - recoil_offset, look_pitch_min, look_pitch_max)

func _autoplay_first_animation(root: Node) -> void:
	if root == null:
		return
	var players: Array = root.find_children("*", "AnimationPlayer", true, false)
	if players.is_empty():
		return
	var anim_player: AnimationPlayer = players[0] as AnimationPlayer
	if anim_player == null:
		return
	var anims: PackedStringArray = anim_player.get_animation_list()
	if anims.is_empty():
		return
	if not anim_player.is_playing():
		anim_player.play(anims[0])

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
	_ensure_key_action("melee", KEY_F)
	_ensure_key_action("tactical", KEY_G)
	_ensure_key_action("special1", KEY_Q)
	_ensure_key_action("prone", KEY_X)
	_ensure_key_action("titan_drop", KEY_V)
	_ensure_key_action("interact", KEY_E)
	_ensure_key_action("map", KEY_M)
	_ensure_key_action("quests", KEY_L)
	_ensure_key_action("socials", KEY_P)
	_ensure_key_action("chat", KEY_ENTER)
	_ensure_key_action("inventory", KEY_I)
	_ensure_key_action("weapon_primary", KEY_1)
	_ensure_key_action("weapon_secondary", KEY_2)
	_ensure_key_action("weapon_tertiary", KEY_3)
	_ensure_key_action("weapon_melee", KEY_4)
	_ensure_key_action("weapon_extras", KEY_5)
	_ensure_key_action("ui_cancel", KEY_ESCAPE)
	_ensure_key_action("fullscreen", KEY_F11)
	_ensure_key_action("mark_location", KEY_F6)
	_ensure_key_action("debug_kill", KEY_F9)
	_ensure_key_action("skill_tree", KEY_K)
	_ensure_key_action("grapple", KEY_H)
	_ensure_mouse_action("fire", MOUSE_BUTTON_LEFT)
	_ensure_mouse_action("aim", MOUSE_BUTTON_RIGHT)
	_ensure_mouse_action("class_ability", MOUSE_BUTTON_MIDDLE)

func _purge_conflicting_keybinds() -> void:
	# Ensure F is only used for fast melee.
	_remove_key_from_action("weapon_primary", KEY_F)
	_remove_key_from_action("weapon_secondary", KEY_F)
	_remove_key_from_action("weapon_tertiary", KEY_F)
	_remove_key_from_action("weapon_melee", KEY_F)
	_remove_key_from_action("weapon_extras", KEY_F)
	# Zipline should not be bound to Z anymore (use interact).
	_remove_key_from_action("zipline", KEY_Z)

func _remove_key_from_action(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		return
	var events := InputMap.action_get_events(action)
	for ev in events:
		if ev is InputEventKey and (ev.keycode == keycode or ev.physical_keycode == keycode):
			InputMap.action_erase_event(action, ev)

func _ensure_key_action(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var events := InputMap.action_get_events(action)
	for ev in events:
		if ev is InputEventKey and (ev.keycode == keycode or ev.physical_keycode == keycode):
			return
	var add := InputEventKey.new()
	add.keycode = keycode
	InputMap.action_add_event(action, add)

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
	var reload_pressed = Input.is_action_pressed("reload")
	var reload_just_pressed = Input.is_action_just_pressed("reload")
	var reload_just_released = Input.is_action_just_released("reload")
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

func _handle_titan_input(delta: float) -> void:
	var titan_pressed = Input.is_action_pressed("titan_drop")
	var titan_just_pressed = Input.is_action_just_pressed("titan_drop")
	var titan_just_released = Input.is_action_just_released("titan_drop")
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

func _update_aim_point() -> void:
	if cam == null:
		aim_point_valid = false
		return

	var space := get_world_3d().direct_space_state
	var origin := global_transform.origin
	var left := -global_transform.basis.x
	var right := global_transform.basis.x

	var params_left := PhysicsRayQueryParameters3D.create(origin, origin + left * 1.1)
	params_left.exclude = [self]
	var hit_left := space.intersect_ray(params_left)

	var params_right := PhysicsRayQueryParameters3D.create(origin, origin + right * 1.1)
	params_right.exclude = [self]
	var hit_right := space.intersect_ray(params_right)

	var hit = hit_left if hit_left else hit_right
	if hit and hit.has("normal"):
		wallrun_normal = hit["normal"]
		wallrunning = true
		wallrun_timer = wallrun_duration

func _init_weapon_configs() -> void:
	weapon_configs = {
		WEAPON_RIFLE: {
			"name": "Rifle",
			"visual": "rifle",
			"mode": "hitscan",
			"fire_rate": 8.0,
			"damage": 25.0,
			"mag": 24,
			"reserve": 120,
			"reload": 1.2,
			"aim_fov": 58.0,
			"recoil": 0.01,
			"recoil_max": 0.2,
			"bullet_speed": 35.0,
			"bullet_life": 0.8,
			"tracer_radius": 0.035
		},
		WEAPON_SNIPER: {
			"name": "Sniper",
			"visual": "sniper",
			"mode": "hitscan",
			"fire_rate": 1.1,
			"damage": 90.0,
			"mag": 5,
			"reserve": 20,
			"reload": 2.2,
			"aim_fov": 38.0,
			"recoil": 0.035,
			"recoil_max": 0.35,
			"bullet_speed": 60.0,
			"bullet_life": 1.1,
			"tracer_radius": 0.05
		},
		WEAPON_ROCKET: {
			"name": "Rocket",
			"visual": "rocket",
			"mode": "projectile",
			"fire_rate": 0.8,
			"damage": 120.0,
			"mag": 2,
			"reserve": 8,
			"reload": 2.6,
			"aim_fov": 60.0,
			"recoil": 0.02,
			"recoil_max": 0.25,
			"projectile_speed": 18.0,
			"projectile_life": 3.0
		},
		WEAPON_PISTOL: {
			"name": "Pistol",
			"visual": "pistol",
			"mode": "hitscan",
			"fire_rate": 6.0,
			"damage": 16.0,
			"mag": 12,
			"reserve": 60,
			"reload": 1.1,
			"aim_fov": 62.0,
			"recoil": 0.008,
			"recoil_max": 0.12,
			"bullet_speed": 30.0,
			"bullet_life": 0.7,
			"tracer_radius": 0.03
		},
		WEAPON_SWORD: {
			"name": "Sword",
			"visual": "sword",
			"mode": "melee",
			"fire_rate": 2.0,
			"damage": 55.0,
			"mag": 0,
			"reserve": 0,
			"reload": 0.0,
			"aim_fov": base_fov,
			"recoil": 0.0,
			"recoil_max": 0.0
		}
	}

func _store_current_ammo() -> void:
	weapon_mag_store[current_weapon] = ammo_in_mag
	weapon_reserve_store[current_weapon] = reserve_ammo

func _equip_weapon(weapon_id: int, initial: bool = false) -> void:
	if not weapon_configs.has(weapon_id):
		return
	if not initial and current_weapon == weapon_id:
		return
	if not initial:
		_store_current_ammo()
	current_weapon = weapon_id
	var cfg = weapon_configs[weapon_id]
	_apply_weapon_config(cfg)
	if gun and gun.has_method("set_weapon"):
		gun.set_weapon(cfg["visual"])
	_hud_placeholder("Weapon: %s" % cfg["name"])

func _apply_weapon_config(cfg: Dictionary) -> void:
	weapon_mode = cfg.get("mode", "hitscan")
	fire_rate = cfg.get("fire_rate", fire_rate)
	fire_damage = cfg.get("damage", fire_damage)
	mag_size = cfg.get("mag", mag_size)
	reload_time = cfg.get("reload", reload_time)
	aim_fov = cfg.get("aim_fov", aim_fov)
	recoil_strength = cfg.get("recoil", recoil_strength)
	recoil_max = cfg.get("recoil_max", recoil_max)
	if cfg.has("bullet_speed"):
		bullet_speed = cfg["bullet_speed"]
	if cfg.has("bullet_life"):
		bullet_lifetime = cfg["bullet_life"]
	if cfg.has("tracer_radius"):
		bullet_tracer_radius = cfg["tracer_radius"]
	weapon_projectile_speed = cfg.get("projectile_speed", 0.0)
	weapon_projectile_lifetime = cfg.get("projectile_life", 0.0)
	ammo_in_mag = weapon_mag_store.get(current_weapon, mag_size)
	reserve_ammo = weapon_reserve_store.get(current_weapon, cfg.get("reserve", reserve_ammo))
	if weapon_mode == "melee":
		melee_damage = cfg.get("damage", melee_damage)
		ammo_in_mag = 0
		reserve_ammo = 0
		is_aiming = false
	is_reloading = false
	reload_timer_remaining = 0.0
	reload_progress = 0.0

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
	if wallrun_cooldown > 0.0:
		return
	var horiz_speed = Vector3(velocity.x, 0, velocity.z).length()
	if horiz_speed < wallrun_min_speed:
		return
	var hit = _get_wallrun_hit()
	if not (hit and hit.has("normal")):
		return
	if last_wall_normal != Vector3.ZERO:
		var dot = hit["normal"].dot(last_wall_normal)
		if dot > 0.8:
			if wallrun_chain_timer > 0.0:
				return
			if wallrun_cooldown > 0.0 and wallrun_intent <= 0.0:
				return
	var desired = Vector3.ZERO
	if input_dir.length() > 0.1:
		desired = (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	else:
		desired = Vector3(velocity.x, 0, velocity.z)
	if desired.length() < 0.1:
		return
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
	wallrun_dir = wall_dir
	wallrun_intent = 0.0
	var entry_target_y = max(velocity.y, wallrun_entry_vertical_boost)
	velocity.y = move_toward(velocity.y, entry_target_y, wallrun_entry_vertical_smooth * get_physics_process_delta_time())
	var horiz = Vector3(velocity.x, 0, velocity.z)
	var target = wall_dir * wallrun_entry_speed
	horiz = horiz.move_toward(target, wallrun_accel * get_physics_process_delta_time())
	velocity.x = horiz.x
	velocity.z = horiz.z

func _compute_wallrun_dir(normal: Vector3, desired: Vector3) -> Vector3:
	if desired.length() < 0.1:
		return Vector3.ZERO
	var desired_flat = desired - normal * desired.dot(normal)
	if desired_flat.length() < 0.05:
		if wallrun_entry_dir.length() > 0.1:
			var entry_flat = wallrun_entry_dir - normal * wallrun_entry_dir.dot(normal)
			if entry_flat.length() > 0.05:
				return entry_flat.normalized()
		var fallback = normal.cross(Vector3.UP).normalized()
		return fallback
	return desired_flat.normalized()

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
	if top_hit and top_hit.has("position") and top_hit.has("normal"):
		var top_normal: Vector3 = top_hit["normal"]
		if top_normal.dot(Vector3.UP) >= 0.7:
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

	# Vertical climb fallback (no ledge)
	var vertical_target = global_transform.origin + Vector3.UP * climb_vertical_height + forward * climb_vertical_forward
	var clear_from = chest + forward * 0.1
	var clear_to = clear_from + Vector3.UP * (climb_vertical_height + 0.2)
	var clear_params = PhysicsRayQueryParameters3D.create(clear_from, clear_to)
	clear_params.exclude = [self]
	if space.intersect_ray(clear_params):
		return false
	climbing = true
	climb_target = vertical_target
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
	wallrun_dir = Vector3.ZERO
	if wallrun_normal != Vector3.ZERO:
		last_wall_normal = wallrun_normal
		wallrun_cooldown = wallrun_reentry_delay
	wallrun_chain_timer = wallrun_chain_time
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

func _toggle_skill_tree() -> void:
	skill_menu_open = not skill_menu_open
	if hud and hud.has_method("show_skill_tree"):
		hud.show_skill_tree(skill_menu_open)
	if skill_menu_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if not get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _xp_required_for(level: int) -> int:
	var base = max(10, xp_base)
	if level <= 1:
		return base
	return int(round(float(base) * pow(xp_growth, float(level - 1))))

func add_xp(amount: int) -> void:
	if amount <= 0:
		return
	current_xp += amount
	var leveled := false
	while current_xp >= xp_to_next:
		current_xp -= xp_to_next
		current_level += 1
		xp_to_next = _xp_required_for(current_level)
		leveled = true
	if leveled:
		_hud_hint("Level Up! Lv %d" % current_level)

func _try_start_grapple() -> void:
	if grapple_cooldown > 0.0 or grapple_active:
		return
	var from = cam.global_transform.origin
	var to = from + (-cam.global_transform.basis.z * grapple_range)
	var space = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	var hit = space.intersect_ray(params)
	if hit and hit.has("position"):
		grapple_point = hit["position"]
		grapple_active = true
		grapple_cooldown = grapple_cooldown_time
		_hud_hint("Grapple engaged")
	else:
		_hud_placeholder("Grapple (no target)")

func _update_grapple(delta: float) -> void:
	var to_point = grapple_point - global_transform.origin
	var distance = to_point.length()
	if distance <= grapple_min_distance:
		grapple_active = false
		return
	var dir = to_point / max(0.001, distance)
	velocity = dir * grapple_speed
	# soften vertical snap
	velocity.y = lerp(velocity.y, dir.y * grapple_speed, 1.0 - exp(-10.0 * delta))

func _try_start_zipline() -> bool:
	if zipline_cooldown > 0.0 or zipline_active:
		return false
	var zip = _find_nearest_zipline()
	if zip == null:
		return false
	var dir = zip.get_zipline_dir()
	if dir.length() < 0.1:
		return false
	zipline_dir = dir.normalized()
	zipline_active = true
	zipline_cooldown = zipline_cooldown_time
	_hud_hint("Zipline engaged")
	return true

func _update_zipline(delta: float) -> void:
	velocity = zipline_dir * zipline_speed
	velocity.y = lerp(velocity.y, 0.0, 1.0 - exp(-8.0 * delta))
	if Input.is_action_just_pressed("jump"):
		zipline_active = false

func _find_nearest_zipline() -> Node:
	var zips = get_tree().get_nodes_in_group("zipline")
	var best: Node = null
	var best_dist := 3.0
	for z in zips:
		if z is Node3D:
			var dist = (z as Node3D).global_transform.origin.distance_to(global_transform.origin)
			if dist < best_dist:
				best_dist = dist
				best = z
	return best

func _try_fire() -> void:
	if weapon_mode == "melee":
		if melee_timer > 0.0:
			return
		melee_timer = melee_cooldown
		if gun and gun.has_method("start_melee"):
			gun.start_melee()
		_perform_melee()
		return
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
	if weapon_mode == "projectile":
		_fire_projectile()
	else:
		_fire_hitscan()

func _fire_hitscan() -> void:
	var from := cam.global_transform.origin
	var to := from + (-cam.global_transform.basis.z * fire_range)
	var space := get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	var result := space.intersect_ray(params)
	if result and result.has("collider"):
		var target: Object = result["collider"]
		if target and target.has_method("take_damage"):
			target.take_damage(melee_damage)
			_on_hit(result)

func _apply_recoil() -> void:
	recoil_offset = clamp(recoil_offset + recoil_strength, 0.0, recoil_max)
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
	if weapon_mode == "melee" or mag_size <= 0:
		return
	if ammo_in_mag >= mag_size:
		return
	if reserve_ammo <= 0:
		return

	is_reloading = true
	var timer := get_tree().create_timer(reload_time)
	timer.timeout.connect(_finish_reload)

func _finish_reload() -> void:
	is_reloading = false
	var needed := mag_size - ammo_in_mag
	var take: int = min(needed, reserve_ammo)
	ammo_in_mag += take
	reserve_ammo -= take

func refill_ammo() -> void:
	for weapon_id in weapon_configs.keys():
		var cfg = weapon_configs[weapon_id]
		weapon_mag_store[weapon_id] = cfg.get("mag", mag_size)
		weapon_reserve_store[weapon_id] = cfg.get("reserve", reserve_ammo)
	ammo_in_mag = weapon_mag_store.get(current_weapon, mag_size)
	reserve_ammo = weapon_reserve_store.get(current_weapon, reserve_ammo)
	_hud_hint("Ammo refilled")

func open_loadout() -> void:
	_hud_placeholder("Loadout (placeholder)")

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
