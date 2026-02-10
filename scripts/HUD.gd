extends Control

class VisorOverlay:
	extends Control
	var edge_color := Color(0.2, 0.9, 1.0, 0.9)
	var glow_color := Color(0.1, 0.7, 1.0, 0.35)

	func _ready() -> void:
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_redraw()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			queue_redraw()

	func _draw() -> void:
		var w: float = size.x
		var h: float = size.y
		var line_w: float = 2.0
		var heavy_w: float = 3.0
		var inset: float = 12.0
		var step: float = 12.0

		var p0: Vector2 = Vector2(w * 0.04, h * 0.12)
		var p1: Vector2 = Vector2(w * 0.12, h * 0.06)
		var p2: Vector2 = Vector2(w * 0.50, h * 0.04)
		var p3: Vector2 = Vector2(w * 0.88, h * 0.06)
		var p4: Vector2 = Vector2(w * 0.96, h * 0.12)
		var p5: Vector2 = Vector2(w * 0.96, h * 0.86)
		var p5b: Vector2 = Vector2(w * 0.96 - step, h * 0.86 + step)
		var p5c: Vector2 = Vector2(w * 0.96 - step, h * 0.86 + step * 3.0)
		var p6: Vector2 = Vector2(w * 0.90, h * 0.94)
		var p7: Vector2 = Vector2(w * 0.10, h * 0.94)
		var p8c: Vector2 = Vector2(w * 0.04 + step, h * 0.86 + step * 3.0)
		var p8b: Vector2 = Vector2(w * 0.04 + step, h * 0.86 + step)
		var p8: Vector2 = Vector2(w * 0.04, h * 0.86)

		var outer: PackedVector2Array = PackedVector2Array([p0, p1, p2, p3, p4, p5, p5b, p5c, p6, p7, p8c, p8b, p8, p0])
		var glow_outer := Color(glow_color.r, glow_color.g, glow_color.b, glow_color.a * 0.7)
		draw_polyline(outer, glow_outer, heavy_w * 2.6, true)
		draw_polyline(outer, edge_color, heavy_w, true)

		var base_points: Array[Vector2] = [p0, p1, p2, p3, p4, p5, p6, p7, p8]
		var inner: PackedVector2Array = PackedVector2Array()
		for i in range(base_points.size()):
			var p: Vector2 = base_points[i]
			var ix: float = p.x
			var iy: float = p.y
			if p.x < w * 0.5:
				ix += inset
			elif p.x > w * 0.5:
				ix -= inset
			if p.y < h * 0.5:
				iy += inset
			elif p.y > h * 0.5:
				iy -= inset
			inner.append(Vector2(ix, iy))
		inner.append(inner[0])
		draw_polyline(inner, Color(glow_color.r, glow_color.g, glow_color.b, glow_color.a * 0.35), line_w * 2.0, true)
		draw_polyline(inner, edge_color, line_w, true)

		# Seams
		draw_line(Vector2(w * 0.5, h * 0.04), Vector2(w * 0.5, h * 0.15), edge_color, 1.0)
		draw_line(Vector2(w * 0.18, h * 0.08), Vector2(w * 0.24, h * 0.13), edge_color, 1.0)
		draw_line(Vector2(w * 0.82, h * 0.08), Vector2(w * 0.76, h * 0.13), edge_color, 1.0)

		# Side vents
		var tick_count: int = 5
		for i in range(tick_count):
			var t: float = float(i) / float(tick_count - 1)
			var y: float = lerp(h * 0.22, h * 0.40, t)
			draw_line(Vector2(w * 0.065, y), Vector2(w * 0.065, y + 8.0), edge_color, 1.0)
			draw_line(Vector2(w * 0.935, y), Vector2(w * 0.935, y + 8.0), edge_color, 1.0)

class RadarDisplay:
	extends Control
	var radius := 120.0
	var edge_color := Color(0.18, 0.92, 1.0, 0.95)
	var glow_color := Color(0.1, 0.75, 1.0, 0.35)
	var sweep := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = Vector2(260.0, 260.0)
		set_process(true)

	func _process(delta: float) -> void:
		sweep = fmod(sweep + delta * 0.8, TAU)
		queue_redraw()

	func _draw() -> void:
		var center: Vector2 = size * 0.5
		var dim := Color(edge_color.r, edge_color.g, edge_color.b, edge_color.a * 0.35)
		draw_arc(center, radius, 0.0, TAU, 96, edge_color, 2.0)
		draw_arc(center, radius * 0.82, 0.0, TAU, 72, dim, 1.0)
		draw_arc(center, radius * 0.6, 0.0, TAU, 64, edge_color, 1.0)
		draw_arc(center, radius * 0.35, 0.0, TAU, 48, dim, 1.0)
		draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), dim, 1.0)
		draw_line(center + Vector2(0, -radius), center + Vector2(0, radius), dim, 1.0)
		for i in range(24):
			var a: float = TAU * float(i) / 24.0
			var dir: Vector2 = Vector2(cos(a), sin(a))
			var tick_start: Vector2 = center + dir * (radius + 2.0)
			var tick_end: Vector2 = center + dir * (radius + 8.0)
			draw_line(tick_start, tick_end, Color(edge_color.r, edge_color.g, edge_color.b, edge_color.a * 0.45), 1.0)
		var sweep_end: Vector2 = center + Vector2(cos(sweep), sin(sweep)) * radius
		draw_line(center, sweep_end, Color(glow_color.r, glow_color.g, glow_color.b, glow_color.a * 0.6), 1.0)
		# static blips
		draw_circle(center + Vector2(22, -14), 2.0, edge_color)
		draw_circle(center + Vector2(-28, 18), 2.0, edge_color)

class PanelDetail:
	extends Control
	var mode := ""
	var edge_color := Color(0.18, 0.92, 1.0, 0.75)
	var accent_color := Color(0.22, 1.0, 0.86, 0.55)

	func _ready() -> void:
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_redraw()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			queue_redraw()

	func _draw() -> void:
		var w: float = size.x
		var h: float = size.y
		if w <= 2.0 or h <= 2.0:
			return
		var thin: float = 1.0
		var dim: Color = Color(edge_color.r, edge_color.g, edge_color.b, edge_color.a * 0.35)
		if mode == "health":
			var margin: float = 8.0
			var tick_len: float = 6.0
			var top_count: int = 9
			for i in range(top_count):
				var t: float = 0.0
				if top_count > 1:
					t = float(i) / float(top_count - 1)
				var x: float = lerp(margin, w - margin, t)
				draw_line(Vector2(x, 2.0), Vector2(x, 2.0 + tick_len), dim, thin)
			var bottom_count: int = 6
			for i in range(bottom_count):
				var t2: float = 0.0
				if bottom_count > 1:
					t2 = float(i) / float(bottom_count - 1)
				var xb: float = lerp(margin + 14.0, w - margin - 14.0, t2)
				draw_line(Vector2(xb, h - 2.0), Vector2(xb, h - 2.0 - tick_len), dim, thin)
			draw_line(Vector2(margin, 2.0), Vector2(margin + 46.0, 2.0), accent_color, 2.0)
			draw_line(Vector2(w - margin - 46.0, h - 2.0), Vector2(w - margin, h - 2.0), dim, thin)
			draw_line(Vector2(w * 0.5 - 36.0, h * 0.5 - 8.0), Vector2(w * 0.5 + 36.0, h * 0.5 - 8.0), dim, thin)
			draw_line(Vector2(w - margin, 2.0), Vector2(w - margin - 22.0, 10.0), dim, thin)
			draw_line(Vector2(margin, h - 2.0), Vector2(margin + 22.0, h - 10.0), dim, thin)
		elif mode == "ammo":
			var corner: float = 12.0
			draw_line(Vector2(2.0, 2.0), Vector2(2.0 + corner, 2.0), dim, thin)
			draw_line(Vector2(2.0, 2.0), Vector2(2.0, 2.0 + corner), dim, thin)
			draw_line(Vector2(w - 2.0 - corner, 2.0), Vector2(w - 2.0, 2.0), dim, thin)
			draw_line(Vector2(w - 2.0, 2.0), Vector2(w - 2.0, 2.0 + corner), dim, thin)
			draw_line(Vector2(2.0, h - 2.0), Vector2(2.0 + corner, h - 2.0), dim, thin)
			draw_line(Vector2(2.0, h - 2.0 - corner), Vector2(2.0, h - 2.0), dim, thin)
			draw_line(Vector2(w - 2.0 - corner, h - 2.0), Vector2(w - 2.0, h - 2.0), dim, thin)
			draw_line(Vector2(w - 2.0, h - 2.0 - corner), Vector2(w - 2.0, h - 2.0), dim, thin)
			var top_count2: int = 5
			for i in range(top_count2):
				var t3: float = 0.0
				if top_count2 > 1:
					t3 = float(i) / float(top_count2 - 1)
				var xt: float = lerp(18.0, w - 18.0, t3)
				draw_line(Vector2(xt, 2.0), Vector2(xt, 6.0), dim, thin)
			draw_line(Vector2(10.0, 22.0), Vector2(72.0, 22.0), accent_color, 2.0)
			var side_count: int = 4
			for i in range(side_count):
				var t4: float = 0.0
				if side_count > 1:
					t4 = float(i) / float(side_count - 1)
				var y: float = lerp(18.0, h - 18.0, t4)
				draw_line(Vector2(w - 8.0, y), Vector2(w - 2.0, y), dim, thin)
		elif mode == "cooldown":
			var corner2: float = 10.0
			draw_line(Vector2(2.0, 2.0), Vector2(2.0 + corner2, 2.0), dim, thin)
			draw_line(Vector2(2.0, 2.0), Vector2(2.0, 2.0 + corner2), dim, thin)
			draw_line(Vector2(w - 2.0 - corner2, 2.0), Vector2(w - 2.0, 2.0), dim, thin)
			draw_line(Vector2(w - 2.0, 2.0), Vector2(w - 2.0, 2.0 + corner2), dim, thin)
			draw_line(Vector2(2.0, h - 2.0), Vector2(2.0 + corner2, h - 2.0), dim, thin)
			draw_line(Vector2(2.0, h - 2.0 - corner2), Vector2(2.0, h - 2.0), dim, thin)
			draw_line(Vector2(w - 2.0 - corner2, h - 2.0), Vector2(w - 2.0, h - 2.0), dim, thin)
			draw_line(Vector2(w - 2.0, h - 2.0 - corner2), Vector2(w - 2.0, h - 2.0), dim, thin)
			draw_line(Vector2(w * 0.2, h * 0.2), Vector2(w * 0.8, h * 0.8), dim, thin)
@onready var grid_overlay: TextureRect = TextureRect.new()
@onready var micro_grid_overlay: TextureRect = TextureRect.new()
@onready var hatch_overlay: TextureRect = TextureRect.new()
@onready var scan_overlay: TextureRect = TextureRect.new()
@onready var noise_overlay: TextureRect = TextureRect.new()
@onready var visor_overlay: VisorOverlay = VisorOverlay.new()
@onready var vignette: ColorRect = ColorRect.new()
@onready var radar_display: RadarDisplay = RadarDisplay.new()
@onready var radar_label: Label = Label.new()
@onready var ammo_panel: Panel = Panel.new()
@onready var ammo_detail: PanelDetail = PanelDetail.new()
@onready var ammo_surface: TextureRect = TextureRect.new()
@onready var ammo_gloss: TextureRect = TextureRect.new()
@onready var hp_label: Label = Label.new()
@onready var ammo_label: Label = Label.new()
@onready var ammo_primary_label: Label = Label.new()
@onready var ammo_reserve_label: Label = Label.new()
@onready var ammo_sep: ColorRect = ColorRect.new()
@onready var speed_label: Label = Label.new()
@onready var pos_label: Label = Label.new()
@onready var aim_label: Label = Label.new()
@onready var level_label: Label = Label.new()
@onready var xp_back: ColorRect = ColorRect.new()
@onready var xp_fill: ColorRect = ColorRect.new()
@onready var interact_panel: Panel = Panel.new()
@onready var interact_label: Label = Label.new()
@onready var info_panel: Panel = Panel.new()
@onready var chii_label: Label = Label.new()
@onready var crosshair_dot: ColorRect = ColorRect.new()
@onready var crosshair_left: ColorRect = ColorRect.new()
@onready var crosshair_right: ColorRect = ColorRect.new()
@onready var crosshair_up: ColorRect = ColorRect.new()
@onready var crosshair_down: ColorRect = ColorRect.new()
@onready var hitmarker: Label = Label.new()
@onready var hint_label: Label = Label.new()
@onready var gun_radial: Control = Control.new()
@onready var titan_radial: Control = Control.new()
@onready var health_frame: Panel = Panel.new()
@onready var health_detail: PanelDetail = PanelDetail.new()
@onready var health_surface: TextureRect = TextureRect.new()
@onready var health_gloss: TextureRect = TextureRect.new()
@onready var health_back: ColorRect = ColorRect.new()
@onready var health_fill: ColorRect = ColorRect.new()
@onready var reload_frame: Panel = Panel.new()
@onready var reload_back: ColorRect = ColorRect.new()
@onready var reload_fill: ColorRect = ColorRect.new()
@onready var cooldown_panel: Control = Control.new()
@onready var cooldown_surface: TextureRect = TextureRect.new()
@onready var cooldown_gloss: TextureRect = TextureRect.new()
@onready var grenade_label: Label = Label.new()
@onready var cooldown_detail: PanelDetail = PanelDetail.new()
@onready var grenade_frame: Panel = Panel.new()
@onready var grenade_back: ColorRect = ColorRect.new()
@onready var grenade_fill: ColorRect = ColorRect.new()
@onready var blink_label: Label = Label.new()
@onready var blink_frame: Panel = Panel.new()
@onready var blink_back: ColorRect = ColorRect.new()
@onready var blink_fill: ColorRect = ColorRect.new()
@onready var utility_label: Label = Label.new()
@onready var utility_frame: Panel = Panel.new()
@onready var utility_back: ColorRect = ColorRect.new()
@onready var utility_fill: ColorRect = ColorRect.new()
@onready var damage_flash: ColorRect = ColorRect.new()
@onready var hit_audio: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var hurt_audio: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var skill_menu: Control = Control.new()

var hint_timer := 0.0
var hitmarker_timer := 0.0
var damage_flash_timer := 0.0
var _health_fill_max := 0.0
var _xp_fill_max := 0.0
var _reload_fill_max := 0.0
var _cooldown_fill_max := 0.0
var _gun_radial_center := Vector2.ZERO
var _titan_radial_center := Vector2.ZERO
var _interact_range := 2.8
var _armor_pips: Array = []
var _hud_hatch_tex: Texture2D
var _hud_scan_tex: Texture2D
var _hud_noise_tex: Texture2D
var _panel_tex: Texture2D
var _panel_gloss_tex: Texture2D
var _micro_grid_tex: Texture2D

const HUD_BG := Color(0.031, 0.075, 0.102, 0.35)
const HUD_EDGE := Color(0.365, 0.914, 1.0, 0.75)
const HUD_TEXT := Color(0.9, 0.97, 1.0, 0.95)
const HUD_DIM := Color(0.46, 0.84, 0.88, 0.7)
const HUD_ACCENT := Color(0.165, 0.847, 0.761, 0.55)
const HUD_WARN := Color(1.0, 0.604, 0.416, 0.45)
const HUD_GLOW := Color(0.486, 0.949, 1.0, 0.35)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_to_group("hud")
	_setup_global_overlay()
	_setup_visor_overlay()
	add_child(damage_flash)
	damage_flash.anchor_left = 0.0
	damage_flash.anchor_top = 0.0
	damage_flash.anchor_right = 1.0
	damage_flash.anchor_bottom = 1.0
	damage_flash.offset_left = 0.0
	damage_flash.offset_top = 0.0
	damage_flash.offset_right = 0.0
	damage_flash.offset_bottom = 0.0
	damage_flash.color = Color(1.0, 0.1, 0.1, 0.0)
	damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(hit_audio)
	add_child(hurt_audio)
	_setup_info_panel()
	_setup_ammo_panel()
	_setup_radar()

	pos_label.visible = false
	aim_label.visible = false

	_setup_crosshair_lines()

	add_child(hitmarker)
	hitmarker.text = "X"
	hitmarker.visible = false
	_style_label(hitmarker, 16, HUD_WARN, true)

	add_child(hint_label)
	hint_label.visible = false
	hint_label.anchor_left = 0.0
	hint_label.anchor_right = 0.0
	hint_label.anchor_top = 1.0
	hint_label.anchor_bottom = 1.0
	hint_label.position = Vector2(24, -78)
	_style_label(hint_label, 11, HUD_DIM)

	_setup_interact_prompt()

	_setup_health_bar()
	_setup_reload_bar()
	_setup_cooldown_bars()
	_setup_skill_tree()

	gun_radial = _build_radial_menu("GUN MENU", ["Primary", "Secondary", "Tertiary", "Melee", "Extras", "Back"])
	titan_radial = _build_radial_menu("TITAN COMMAND", ["Drop", "Recall", "Follow", "Hold", "Assist", "Back"])
	gun_radial.visible = false
	titan_radial.visible = false
	_apply_layout()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_layout()

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		hp_label.text = "HP %d" % int(player.current_health)
		ammo_primary_label.text = "%d" % int(player.ammo_in_mag)
		ammo_reserve_label.text = "%d" % int(player.reserve_ammo)
		var horiz_speed = Vector3(player.velocity.x, 0, player.velocity.z).length()
		speed_label.text = "SPD: %.1f" % horiz_speed
		var pos = player.global_transform.origin
		pos_label.text = "POS: %.2f, %.2f, %.2f m" % [pos.x, pos.y, pos.z]
		if player.aim_point_valid:
			var aim_pos = player.aim_point
			aim_label.text = "AIM: %.2f, %.2f, %.2f m" % [aim_pos.x, aim_pos.y, aim_pos.z]
		else:
			aim_label.text = "AIM: --"
		level_label.text = "LVL %d | XP %d / %d" % [int(player.current_level), int(player.current_xp), int(player.xp_to_next)]
		var ratio := 1.0
		if player.max_health > 0.0:
			ratio = float(player.current_health) / float(player.max_health)
		_update_health_bar(ratio)
		var xp_ratio := 0.0
		if player.xp_to_next > 0:
			xp_ratio = float(player.current_xp) / float(player.xp_to_next)
		_update_xp_bar(xp_ratio)

		_update_reload_bar(player.reload_progress, player.is_reloading)
		_update_cooldown_bar(grenade_fill, grenade_label, "G", player.grenade_cooldown, player.grenade_cooldown_time)
		_update_cooldown_bar(blink_fill, blink_label, "MMB", player.blink_cooldown, player.blink_cooldown_time)

	if hint_timer > 0.0:
		hint_timer = max(0.0, hint_timer - _delta)
		if hint_timer <= 0.0:
			hint_label.visible = false

	var viewport_center = get_viewport_rect().size / 2
	hitmarker.position = viewport_center - Vector2(6, 8)
	_update_crosshair_lines(viewport_center)
	_update_interact_prompt(viewport_center)
	if hitmarker_timer > 0.0:
		hitmarker_timer = max(0.0, hitmarker_timer - _delta)
		var t = hitmarker_timer / 0.12
		hitmarker.scale = Vector2(1.0, 1.0) * (1.0 + (0.4 * t))
		hitmarker.modulate = Color(HUD_WARN.r, HUD_WARN.g, HUD_WARN.b, clamp(t, 0.0, 1.0))
		if hitmarker_timer <= 0.0:
			hitmarker.visible = false
	if damage_flash_timer > 0.0:
		damage_flash_timer = max(0.0, damage_flash_timer - _delta)
		var t_flash = damage_flash_timer / 0.2
		damage_flash.color = Color(1.0, 0.1, 0.1, 0.35 * clamp(t_flash, 0.0, 1.0))
	else:
		damage_flash.color = Color(1.0, 0.1, 0.1, 0.0)
	# Radials are positioned once when opened to avoid dragging with the cursor.

func show_hint(text: String) -> void:
	hint_label.text = text
	hint_label.visible = true
	hint_timer = 1.4

func show_gun_radial(show: bool) -> void:
	gun_radial.visible = show
	if show:
		_gun_radial_center = get_viewport().get_mouse_position()
		_position_radial_at(gun_radial, _gun_radial_center)

func show_titan_radial(show: bool) -> void:
	titan_radial.visible = show
	if show:
		_titan_radial_center = get_viewport().get_mouse_position()
		_position_radial_at(titan_radial, _titan_radial_center)

func show_hitmarker() -> void:
	hitmarker.visible = true
	hitmarker_timer = 0.12
	_play_tone(hit_audio, 1200.0, 0.05, -8.0)

func show_damage_flash() -> void:
	damage_flash_timer = 0.2
	damage_flash.color = Color(1.0, 0.1, 0.1, 0.35)
	_play_tone(hurt_audio, 220.0, 0.1, -6.0)

func get_gun_radial_choice() -> String:
	return _get_radial_choice(gun_radial)

func get_titan_radial_choice() -> String:
	return _get_radial_choice(titan_radial)

func log_placeholder(label: String) -> void:
	show_hint("%s (Not Implemented)" % label)
	print("Not Implemented:", label)

func _setup_info_panel() -> void:
	add_child(info_panel)
	info_panel.visible = false
	info_panel.anchor_left = 0.0
	info_panel.anchor_top = 0.0
	info_panel.anchor_right = 0.0
	info_panel.anchor_bottom = 0.0
	info_panel.offset_left = 18
	info_panel.offset_top = 14
	info_panel.offset_right = 320
	info_panel.offset_bottom = 170
	info_panel.add_theme_stylebox_override("panel", _make_frame_style())

	add_child(chii_label)
	chii_label.text = "CHII // PILOT SYSTEMS"
	chii_label.position = Vector2(26, 20)
	_style_label(chii_label, 11, HUD_DIM)

	var status := Label.new()
	status.text = "CORE ONLINE"
	status.position = Vector2(28, 134)
	_style_label(status, 11, HUD_ACCENT)
	info_panel.add_child(status)

	_add_tech_ticks(info_panel, HUD_EDGE)
	_add_glow_bar(info_panel, Vector2(10, 146), Vector2(140, 2), HUD_ACCENT)
	_add_glow_bar(info_panel, Vector2(220, 26), Vector2(70, 2), HUD_EDGE)

func _setup_crosshair_lines() -> void:
	add_child(crosshair_dot)
	add_child(crosshair_left)
	add_child(crosshair_right)
	add_child(crosshair_up)
	add_child(crosshair_down)
	crosshair_dot.color = HUD_EDGE
	crosshair_left.color = HUD_EDGE
	crosshair_right.color = HUD_EDGE
	crosshair_up.color = HUD_EDGE
	crosshair_down.color = HUD_EDGE
	crosshair_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crosshair_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crosshair_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crosshair_up.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crosshair_down.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _update_crosshair_lines(center: Vector2) -> void:
	var dot_size := 4.0
	var tick_len := 6.0
	var tick_thick := 1.0
	var gap := 4.0

	crosshair_dot.size = Vector2(dot_size, dot_size)
	crosshair_dot.position = center - Vector2(dot_size * 0.5, dot_size * 0.5)

	crosshair_left.size = Vector2(tick_len, tick_thick)
	crosshair_right.size = Vector2(tick_len, tick_thick)
	crosshair_up.size = Vector2(tick_thick, tick_len)
	crosshair_down.size = Vector2(tick_thick, tick_len)

	crosshair_left.position = center + Vector2(-(gap + tick_len), -tick_thick * 0.5)
	crosshair_right.position = center + Vector2(gap, -tick_thick * 0.5)
	crosshair_up.position = center + Vector2(-tick_thick * 0.5, -(gap + tick_len))
	crosshair_down.position = center + Vector2(-tick_thick * 0.5, gap)

func _setup_interact_prompt() -> void:
	add_child(interact_panel)
	interact_panel.visible = false
	interact_panel.anchor_left = 0.5
	interact_panel.anchor_right = 0.5
	interact_panel.anchor_top = 0.5
	interact_panel.anchor_bottom = 0.5
	interact_panel.offset_left = -170
	interact_panel.offset_right = 170
	interact_panel.offset_top = 30
	interact_panel.offset_bottom = 66
	interact_panel.add_theme_stylebox_override("panel", _make_interact_style())
	interact_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	interact_panel.add_child(interact_label)
	interact_label.text = "Press E to interact"
	interact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interact_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	interact_label.anchor_left = 0.0
	interact_label.anchor_right = 1.0
	interact_label.anchor_top = 0.0
	interact_label.anchor_bottom = 1.0
	_style_label(interact_label, 12, HUD_TEXT)

	var key_tag := Label.new()
	key_tag.text = "[E]"
	key_tag.position = Vector2(12, 8)
	_style_label(key_tag, 12, HUD_ACCENT)
	interact_panel.add_child(key_tag)

	var left_bracket := ColorRect.new()
	left_bracket.color = HUD_EDGE
	left_bracket.position = Vector2(6, 6)
	left_bracket.size = Vector2(2, 22)
	interact_panel.add_child(left_bracket)
	var right_bracket := ColorRect.new()
	right_bracket.color = HUD_EDGE
	right_bracket.anchor_left = 1.0
	right_bracket.anchor_top = 0.0
	right_bracket.anchor_right = 1.0
	right_bracket.anchor_bottom = 0.0
	right_bracket.position = Vector2(-8, 6)
	right_bracket.size = Vector2(2, 22)
	interact_panel.add_child(right_bracket)
	_add_glow_bar(interact_panel, Vector2(8, 34), Vector2(60, 2), HUD_EDGE)

func _update_interact_prompt(center: Vector2) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		interact_panel.visible = false
		return
	var player_pos = player.global_transform.origin
	var best: Node3D = null
	var best_dist = _interact_range
	for node in get_tree().get_nodes_in_group("interactable"):
		if node is Node3D:
			var dist = (node as Node3D).global_transform.origin.distance_to(player_pos)
			if dist < best_dist:
				best_dist = dist
				best = node
	if best:
		var prompt := "Press E to interact"
		if best.has_method("get_interact_prompt"):
			prompt = best.get_interact_prompt()
		else:
			var raw = best.get("interact_prompt")
			if raw != null and str(raw) != "":
				prompt = str(raw)
		interact_label.text = prompt
		interact_panel.visible = true
		var size = interact_panel.size
		if size == Vector2.ZERO:
			size = Vector2(340, 36)
		interact_panel.position = center + Vector2(-size.x * 0.5, 30)
	else:
		interact_panel.visible = false

func _setup_health_bar() -> void:
	_ensure_textures()
	add_child(health_frame)
	health_frame.add_theme_stylebox_override("panel", _make_frame_style())
	health_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE

	health_surface.texture = _panel_tex
	health_surface.stretch_mode = TextureRect.STRETCH_TILE
	health_surface.modulate = Color(0.22, 0.86, 1.0, 0.2)
	health_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_frame.add_child(health_surface)

	health_gloss.texture = _panel_gloss_tex
	health_gloss.stretch_mode = TextureRect.STRETCH_SCALE
	health_gloss.modulate = Color(0.25, 0.9, 1.0, 0.12)
	health_gloss.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_frame.add_child(health_gloss)

	_add_tech_ticks(health_frame, HUD_EDGE)

	_armor_pips.clear()
	for i in range(3):
		var pip := ColorRect.new()
		pip.color = HUD_EDGE
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		health_frame.add_child(pip)
		_armor_pips.append(pip)

	health_frame.add_child(health_back)
	health_back.color = HUD_BG
	health_back.clip_contents = true
	health_back.mouse_filter = Control.MOUSE_FILTER_IGNORE

	health_back.add_child(health_fill)
	health_fill.color = HUD_ACCENT
	health_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE

	health_frame.add_child(xp_back)
	xp_back.color = HUD_BG
	xp_back.clip_contents = true
	xp_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	xp_back.add_child(xp_fill)
	xp_fill.color = HUD_EDGE
	xp_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE

	health_detail.mode = "health"
	health_detail.edge_color = HUD_EDGE
	health_detail.accent_color = HUD_ACCENT
	health_frame.add_child(health_detail)

	_add_corner_notches(health_frame, HUD_ACCENT)

	health_frame.add_child(hp_label)
	hp_label.text = "HP 100"
	_style_label(hp_label, 22, HUD_TEXT)

	health_frame.add_child(level_label)
	level_label.text = "LVL 1 | XP 0 / 100"
	_style_label(level_label, 12, HUD_DIM)

func _setup_reload_bar() -> void:
	add_child(reload_frame)
	reload_frame.anchor_left = 0.5
	reload_frame.anchor_right = 0.5
	reload_frame.anchor_top = 1.0
	reload_frame.anchor_bottom = 1.0
	reload_frame.offset_left = -120
	reload_frame.offset_right = 120
	reload_frame.offset_top = -70
	reload_frame.offset_bottom = -52
	reload_frame.add_theme_stylebox_override("panel", _make_frame_style())
	reload_frame.visible = false

	reload_frame.add_child(reload_back)
	reload_back.anchor_left = 0.0
	reload_back.anchor_right = 1.0
	reload_back.anchor_top = 0.0
	reload_back.anchor_bottom = 1.0
	reload_back.offset_left = 2
	reload_back.offset_right = -2
	reload_back.offset_top = 2
	reload_back.offset_bottom = -2
	reload_back.color = HUD_BG

	reload_back.add_child(reload_fill)
	reload_fill.anchor_left = 0.0
	reload_fill.anchor_right = 0.0
	reload_fill.anchor_top = 0.0
	reload_fill.anchor_bottom = 1.0
	reload_fill.offset_left = 0.0
	reload_fill.offset_right = 236.0
	reload_fill.color = Color(0.3, 0.75, 1.0, 0.95)
	_reload_fill_max = 236.0

func _setup_cooldown_bars() -> void:
	_ensure_textures()
	add_child(cooldown_panel)
	cooldown_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	cooldown_surface.texture = _panel_tex
	cooldown_surface.stretch_mode = TextureRect.STRETCH_TILE
	cooldown_surface.modulate = Color(0.2, 0.8, 0.95, 0.12)
	cooldown_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cooldown_panel.add_child(cooldown_surface)

	cooldown_gloss.texture = _panel_gloss_tex
	cooldown_gloss.stretch_mode = TextureRect.STRETCH_SCALE
	cooldown_gloss.modulate = Color(0.25, 0.9, 1.0, 0.08)
	cooldown_gloss.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cooldown_panel.add_child(cooldown_gloss)

	_build_cooldown_slot(grenade_frame, grenade_label, grenade_fill, "G", HUD_WARN)
	_build_cooldown_slot(blink_frame, blink_label, blink_fill, "MMB", Color(0.3, 0.8, 1.0, 0.95))
	_build_cooldown_slot(utility_frame, utility_label, utility_fill, "Q", HUD_ACCENT)

	cooldown_panel.add_child(grenade_frame)
	cooldown_panel.add_child(blink_frame)
	cooldown_panel.add_child(utility_frame)

	cooldown_detail.mode = "cooldown"
	cooldown_detail.edge_color = HUD_EDGE
	cooldown_detail.accent_color = HUD_ACCENT
	cooldown_panel.add_child(cooldown_detail)

	_cooldown_fill_max = 56.0

func _setup_ammo_panel() -> void:
	_ensure_textures()
	add_child(ammo_panel)
	ammo_panel.add_theme_stylebox_override("panel", _make_frame_style())
	ammo_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	ammo_surface.texture = _panel_tex
	ammo_surface.stretch_mode = TextureRect.STRETCH_TILE
	ammo_surface.modulate = Color(0.2, 0.86, 1.0, 0.18)
	ammo_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ammo_panel.add_child(ammo_surface)

	ammo_gloss.texture = _panel_gloss_tex
	ammo_gloss.stretch_mode = TextureRect.STRETCH_SCALE
	ammo_gloss.modulate = Color(0.25, 0.9, 1.0, 0.12)
	ammo_gloss.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ammo_panel.add_child(ammo_gloss)

	_add_tech_ticks(ammo_panel, HUD_EDGE)

	ammo_detail.mode = "ammo"
	ammo_detail.edge_color = HUD_EDGE
	ammo_detail.accent_color = HUD_ACCENT
	ammo_panel.add_child(ammo_detail)

	_add_corner_notches(ammo_panel, HUD_ACCENT)

	ammo_panel.add_child(ammo_label)
	ammo_label.text = "AMMO"
	ammo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_style_label(ammo_label, 12, HUD_DIM)

	ammo_panel.add_child(ammo_primary_label)
	ammo_primary_label.text = "0"
	ammo_primary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_style_label(ammo_primary_label, 46, HUD_TEXT)

	ammo_panel.add_child(ammo_reserve_label)
	ammo_reserve_label.text = "0"
	ammo_reserve_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_style_label(ammo_reserve_label, 20, HUD_DIM)

	ammo_panel.add_child(ammo_sep)
	ammo_sep.color = HUD_EDGE
	ammo_sep.mouse_filter = Control.MOUSE_FILTER_IGNORE

	ammo_panel.add_child(speed_label)
	speed_label.text = "SPD: 0.0"
	speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_style_label(speed_label, 11, HUD_DIM)

func _setup_radar() -> void:
	add_child(radar_display)
	radar_display.edge_color = HUD_EDGE
	radar_display.glow_color = HUD_GLOW

	add_child(radar_label)
	radar_label.text = "RADAR"
	_style_label(radar_label, 11, HUD_DIM)

func _setup_global_overlay() -> void:
	_ensure_textures()
	add_child(grid_overlay)
	grid_overlay.anchor_left = 0.0
	grid_overlay.anchor_top = 0.0
	grid_overlay.anchor_right = 1.0
	grid_overlay.anchor_bottom = 1.0
	grid_overlay.offset_left = 0
	grid_overlay.offset_top = 0
	grid_overlay.offset_right = 0
	grid_overlay.offset_bottom = 0
	grid_overlay.stretch_mode = TextureRect.STRETCH_TILE
	grid_overlay.texture = _make_grid_texture(256, 24, 6)
	grid_overlay.modulate = Color(0.2, 0.55, 0.75, 0.08)
	grid_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(micro_grid_overlay)
	micro_grid_overlay.anchor_left = 0.0
	micro_grid_overlay.anchor_top = 0.0
	micro_grid_overlay.anchor_right = 1.0
	micro_grid_overlay.anchor_bottom = 1.0
	micro_grid_overlay.offset_left = 0
	micro_grid_overlay.offset_top = 0
	micro_grid_overlay.offset_right = 0
	micro_grid_overlay.offset_bottom = 0
	micro_grid_overlay.stretch_mode = TextureRect.STRETCH_TILE
	micro_grid_overlay.texture = _micro_grid_tex
	micro_grid_overlay.modulate = Color(0.2, 0.65, 0.85, 0.05)
	micro_grid_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(hatch_overlay)
	hatch_overlay.anchor_left = 0.0
	hatch_overlay.anchor_top = 0.0
	hatch_overlay.anchor_right = 1.0
	hatch_overlay.anchor_bottom = 1.0
	hatch_overlay.offset_left = 0
	hatch_overlay.offset_top = 0
	hatch_overlay.offset_right = 0
	hatch_overlay.offset_bottom = 0
	hatch_overlay.stretch_mode = TextureRect.STRETCH_TILE
	hatch_overlay.texture = _hud_hatch_tex
	hatch_overlay.modulate = Color(0.28, 0.8, 1.0, 0.12)
	hatch_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(scan_overlay)
	scan_overlay.anchor_left = 0.0
	scan_overlay.anchor_top = 0.0
	scan_overlay.anchor_right = 1.0
	scan_overlay.anchor_bottom = 1.0
	scan_overlay.offset_left = 0
	scan_overlay.offset_top = 0
	scan_overlay.offset_right = 0
	scan_overlay.offset_bottom = 0
	scan_overlay.stretch_mode = TextureRect.STRETCH_TILE
	scan_overlay.texture = _hud_scan_tex
	scan_overlay.modulate = Color(0.3, 0.85, 1.0, 0.1)
	scan_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(noise_overlay)
	noise_overlay.anchor_left = 0.0
	noise_overlay.anchor_top = 0.0
	noise_overlay.anchor_right = 1.0
	noise_overlay.anchor_bottom = 1.0
	noise_overlay.offset_left = 0
	noise_overlay.offset_top = 0
	noise_overlay.offset_right = 0
	noise_overlay.offset_bottom = 0
	noise_overlay.stretch_mode = TextureRect.STRETCH_TILE
	noise_overlay.texture = _hud_noise_tex
	noise_overlay.modulate = Color(0.4, 0.9, 1.0, 0.08)
	noise_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(vignette)
	vignette.anchor_left = 0.0
	vignette.anchor_top = 0.0
	vignette.anchor_right = 1.0
	vignette.anchor_bottom = 1.0
	vignette.offset_left = 0
	vignette.offset_top = 0
	vignette.offset_right = 0
	vignette.offset_bottom = 0
	vignette.color = Color(0.0, 0.0, 0.0, 0.18)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _setup_visor_overlay() -> void:
	visor_overlay.edge_color = HUD_EDGE
	visor_overlay.glow_color = HUD_GLOW
	add_child(visor_overlay)

func _add_corner_notches(panel: Control, color: Color) -> void:
	if panel == null:
		return
	var notch := Vector2(18, 2)
	var notch_v := Vector2(2, 18)
	var tl_h := ColorRect.new()
	tl_h.color = color
	tl_h.position = Vector2(8, 8)
	tl_h.size = notch
	panel.add_child(tl_h)
	var tl_v := ColorRect.new()
	tl_v.color = color
	tl_v.position = Vector2(8, 8)
	tl_v.size = notch_v
	panel.add_child(tl_v)
	var tr_h := ColorRect.new()
	tr_h.color = color
	tr_h.anchor_left = 1.0
	tr_h.anchor_top = 0.0
	tr_h.anchor_right = 1.0
	tr_h.anchor_bottom = 0.0
	tr_h.position = Vector2(-26, 8)
	tr_h.size = notch
	panel.add_child(tr_h)
	var tr_v := ColorRect.new()
	tr_v.color = color
	tr_v.anchor_left = 1.0
	tr_v.anchor_top = 0.0
	tr_v.anchor_right = 1.0
	tr_v.anchor_bottom = 0.0
	tr_v.position = Vector2(-10, 8)
	tr_v.size = notch_v
	panel.add_child(tr_v)
	var bl_h := ColorRect.new()
	bl_h.color = color
	bl_h.anchor_left = 0.0
	bl_h.anchor_top = 1.0
	bl_h.anchor_right = 0.0
	bl_h.anchor_bottom = 1.0
	bl_h.position = Vector2(8, -10)
	bl_h.size = notch
	panel.add_child(bl_h)
	var bl_v := ColorRect.new()
	bl_v.color = color
	bl_v.anchor_left = 0.0
	bl_v.anchor_top = 1.0
	bl_v.anchor_right = 0.0
	bl_v.anchor_bottom = 1.0
	bl_v.position = Vector2(8, -26)
	bl_v.size = notch_v
	panel.add_child(bl_v)
	var br_h := ColorRect.new()
	br_h.color = color
	br_h.anchor_left = 1.0
	br_h.anchor_top = 1.0
	br_h.anchor_right = 1.0
	br_h.anchor_bottom = 1.0
	br_h.position = Vector2(-26, -10)
	br_h.size = notch
	panel.add_child(br_h)
	var br_v := ColorRect.new()
	br_v.color = color
	br_v.anchor_left = 1.0
	br_v.anchor_top = 1.0
	br_v.anchor_right = 1.0
	br_v.anchor_bottom = 1.0
	br_v.position = Vector2(-10, -26)
	br_v.size = notch_v
	panel.add_child(br_v)

func _make_ring_texture(size: int, thickness: int, color: Color) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var center = Vector2(size * 0.5, size * 0.5)
	var outer = (size * 0.5) - 2.0
	var inner = outer - thickness
	for y in range(size):
		for x in range(size):
			var d = center.distance_to(Vector2(x, y))
			if d <= outer and d >= inner:
				img.set_pixel(x, y, color)
	var tex := ImageTexture.create_from_image(img)
	return tex

func _make_grid_texture(size: int, spacing: int, dot: int) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in range(size):
		for x in range(size):
			if x % spacing == 0 or y % spacing == 0:
				img.set_pixel(x, y, Color(0.1, 0.6, 0.8, 0.25))
			elif (x % dot == 0 and y % dot == 0):
				img.set_pixel(x, y, Color(0.1, 0.6, 0.8, 0.18))
	var tex := ImageTexture.create_from_image(img)
	return tex

func _make_hatch_texture(size: int, spacing: int, thickness: int, alpha: float, cross: bool = false) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var safe_spacing: int = maxi(1, spacing)
	var safe_thickness: int = clampi(thickness, 1, safe_spacing)
	var offset: int = size * 4
	for y in range(size):
		for x in range(size):
			var on_line: bool = ((x + y) % safe_spacing) < safe_thickness
			if cross:
				on_line = on_line or (((x - y + offset) % safe_spacing) < safe_thickness)
			if on_line:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	var tex := ImageTexture.create_from_image(img)
	return tex

func _make_scanline_texture(size: int, spacing: int, thickness: int, alpha: float) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var safe_spacing: int = maxi(1, spacing)
	var safe_thickness: int = clampi(thickness, 1, safe_spacing)
	for y in range(size):
		if (y % safe_spacing) < safe_thickness:
			for x in range(size):
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	var tex := ImageTexture.create_from_image(img)
	return tex

func _make_noise_texture(size: int, density: float, alpha_min: float, alpha_max: float) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	var d: float = clampf(density, 0.0, 1.0)
	var a0: float = clampf(alpha_min, 0.0, 1.0)
	var a1: float = clampf(alpha_max, 0.0, 1.0)
	if a1 < a0:
		var tmp: float = a0
		a0 = a1
		a1 = tmp
	for y in range(size):
		for x in range(size):
			if rng.randf() <= d:
				var a: float = lerp(a0, a1, rng.randf())
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, a))
	var tex := ImageTexture.create_from_image(img)
	return tex

func _make_panel_texture(size: int, spacing: int, thickness: int) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var safe_spacing: int = maxi(1, spacing)
	var safe_thickness: int = clampi(thickness, 1, safe_spacing)
	var offset: int = size * 4
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	for y in range(size):
		for x in range(size):
			var on_line: bool = ((x + y) % safe_spacing) < safe_thickness
			on_line = on_line or (((x - y + offset) % safe_spacing) < safe_thickness)
			var alpha: float = 0.0
			if on_line:
				alpha = 0.28
			if rng.randf() < 0.08:
				alpha = maxf(alpha, 0.18)
			if alpha > 0.0:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	var tex := ImageTexture.create_from_image(img)
	return tex

func _make_gradient_texture(width: int, height: int, top: Color, bottom: Color) -> Texture2D:
	var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y in range(height):
		var t := float(y) / float(max(1, height - 1))
		var col := top.lerp(bottom, t)
		for x in range(width):
			img.set_pixel(x, y, col)
	var tex := ImageTexture.create_from_image(img)
	return tex

func _ensure_textures() -> void:
	if _hud_hatch_tex == null:
		_hud_hatch_tex = _make_hatch_texture(96, 18, 1, 0.18, true)
	if _hud_scan_tex == null:
		_hud_scan_tex = _make_scanline_texture(128, 6, 1, 0.2)
	if _hud_noise_tex == null:
		_hud_noise_tex = _make_noise_texture(128, 0.06, 0.08, 0.18)
	if _panel_tex == null:
		_panel_tex = _make_panel_texture(96, 14, 1)
	if _panel_gloss_tex == null:
		_panel_gloss_tex = _make_gradient_texture(128, 64, Color(1.0, 1.0, 1.0, 0.18), Color(1.0, 1.0, 1.0, 0.0))
	if _micro_grid_tex == null:
		_micro_grid_tex = _make_grid_texture(128, 12, 4)

func _setup_skill_tree() -> void:
	add_child(skill_menu)
	skill_menu.visible = false
	skill_menu.anchor_left = 0.5
	skill_menu.anchor_right = 0.5
	skill_menu.anchor_top = 0.5
	skill_menu.anchor_bottom = 0.5
	skill_menu.offset_left = -220
	skill_menu.offset_right = 220
	skill_menu.offset_top = -180
	skill_menu.offset_bottom = 180
	skill_menu.mouse_filter = Control.MOUSE_FILTER_STOP

	var panel := Panel.new()
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 1.0
	panel.add_theme_stylebox_override("panel", _make_frame_style())
	skill_menu.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.anchor_left = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_top = 0.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 18
	vbox.offset_right = -18
	vbox.offset_top = 18
	vbox.offset_bottom = -18
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "SKILL TREE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(title, 16, HUD_TEXT)
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Placeholder nodes (K to close)"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(subtitle, 12, HUD_DIM)
	vbox.add_child(subtitle)

	for skill in ["Mobility I", "Wallrun Mastery", "Grapple Boost", "Zipline Sync", "Titan Drop Ready"]:
		var row := Label.new()
		row.text = "- " + skill
		_style_label(row, 12, HUD_ACCENT)
		vbox.add_child(row)

func show_skill_tree(show: bool) -> void:
	skill_menu.visible = show

func _update_health_bar(ratio: float) -> void:
	ratio = clamp(ratio, 0.0, 1.0)
	health_fill.offset_left = 0.0
	health_fill.offset_right = _health_fill_max * ratio

func _update_xp_bar(ratio: float) -> void:
	ratio = clamp(ratio, 0.0, 1.0)
	xp_fill.offset_left = 0.0
	xp_fill.offset_right = _xp_fill_max * ratio

func _update_reload_bar(progress: float, active: bool) -> void:
	reload_frame.visible = active
	if not active:
		return
	reload_fill.offset_right = _reload_fill_max * clamp(progress, 0.0, 1.0)

func _update_cooldown_bar(fill: ColorRect, label: Label, label_text: String, time_left: float, total: float) -> void:
	if total <= 0.0:
		total = 1.0
	var ratio: float = 1.0 - clampf(time_left / total, 0.0, 1.0)
	fill.offset_right = _cooldown_fill_max * ratio
	var base_color := HUD_WARN
	var ready_color := Color(1.0, 0.82, 0.45, 0.95)
	if label_text == "MMB":
		base_color = Color(0.3, 0.8, 1.0, 0.95)
		ready_color = Color(0.55, 0.95, 1.0, 0.95)
	if time_left <= 0.0:
		label.text = "%s" % label_text
		fill.color = ready_color
	else:
		label.text = "%s %.1f" % [label_text, time_left]
		fill.color = base_color

func _build_radial_menu(title: String, slots: Array) -> Control:
	var root := Control.new()
	root.anchors_preset = Control.PRESET_TOP_LEFT
	root.size = Vector2(300, 300)
	root.position = Vector2.ZERO
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var bg := Panel.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = HUD_BG
	style.border_color = HUD_EDGE
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 150
	style.corner_radius_top_right = 150
	style.corner_radius_bottom_right = 150
	style.corner_radius_bottom_left = 150
	style.shadow_color = Color(0.0, 0.5, 0.8, 0.18)
	style.shadow_size = 6
	bg.add_theme_stylebox_override("panel", style)
	root.add_child(bg)

	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.anchor_right = 1.0
	title_label.anchor_bottom = 1.0
	_style_label(title_label, 14, HUD_TEXT)
	root.add_child(title_label)

	var center = Vector2(150, 150)
	var radius = 95.0
	for i in range(slots.size()):
		var slot_label := Label.new()
		slot_label.text = str(slots[i])
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot_label.custom_minimum_size = Vector2(90, 20)
		_style_label(slot_label, 12, HUD_DIM)
		var angle = (TAU * float(i) / float(slots.size())) - (PI / 2.0)
		var pos = center + Vector2(cos(angle), sin(angle)) * radius
		slot_label.position = pos - (slot_label.custom_minimum_size * 0.5)
		root.add_child(slot_label)
	root.set_meta("slots", slots)

	return root

func _position_radial_at(menu: Control, center: Vector2) -> void:
	if menu == null:
		return
	var viewport_size = get_viewport_rect().size
	var menu_size = menu.size
	if menu_size == Vector2.ZERO:
		menu_size = Vector2(300, 300)
	var target = center - (menu_size * 0.5)
	target.x = clamp(target.x, 0.0, max(0.0, viewport_size.x - menu_size.x))
	target.y = clamp(target.y, 0.0, max(0.0, viewport_size.y - menu_size.y))
	menu.position = target

func _get_radial_choice(menu: Control) -> String:
	if menu == null:
		return ""
	if not menu.has_meta("slots"):
		return ""
	var slots: Array = menu.get_meta("slots") as Array
	if slots.is_empty():
		return ""
	var menu_size = menu.size
	if menu_size == Vector2.ZERO:
		menu_size = Vector2(300, 300)
	var center = menu.position + (menu_size * 0.5)
	var mouse_pos = get_viewport().get_mouse_position()
	var dir = mouse_pos - center
	if dir.length() < 12.0:
		return str(slots[0])
	var angle = atan2(dir.y, dir.x) + (PI / 2.0)
	if angle < 0.0:
		angle += TAU
	var step = TAU / float(slots.size())
	var idx = int(floor(angle / step)) % slots.size()
	return str(slots[idx])

func _play_tone(player: AudioStreamPlayer, freq: float, duration: float, volume_db: float) -> void:
	if player == null:
		return
	if player.stream == null or not (player.stream is AudioStreamGenerator):
		var gen := AudioStreamGenerator.new()
		gen.mix_rate = 44100
		gen.buffer_length = 0.2
		player.stream = gen
	player.volume_db = volume_db
	player.play()
	var playback = player.get_stream_playback()
	if playback == null:
		return
	playback.clear_buffer()
	var gen_stream := player.stream as AudioStreamGenerator
	var rate = gen_stream.mix_rate
	var frames = int(rate * duration)
	var data := PackedVector2Array()
	data.resize(frames)
	var phase := 0.0
	var inc: float = TAU * freq / float(rate)
	for i in range(frames):
		var env = 1.0 - (float(i) / float(frames))
		var sample = sin(phase) * 0.22 * env
		data[i] = Vector2(sample, sample)
		phase += inc
	playback.push_buffer(data)

func _add_tech_ticks(panel: Control, color: Color) -> void:
	if panel == null:
		return
	var tick_size = Vector2(10, 2)
	var tick_v = Vector2(2, 10)
	var tl_h := ColorRect.new()
	tl_h.color = color
	tl_h.position = Vector2(6, 6)
	tl_h.size = tick_size
	panel.add_child(tl_h)
	var tl_v := ColorRect.new()
	tl_v.color = color
	tl_v.position = Vector2(6, 6)
	tl_v.size = tick_v
	panel.add_child(tl_v)
	var br_h := ColorRect.new()
	br_h.color = color
	br_h.anchor_left = 1.0
	br_h.anchor_top = 1.0
	br_h.anchor_right = 1.0
	br_h.anchor_bottom = 1.0
	br_h.position = Vector2(-18, -8)
	br_h.size = tick_size
	panel.add_child(br_h)
	var br_v := ColorRect.new()
	br_v.color = color
	br_v.anchor_left = 1.0
	br_v.anchor_top = 1.0
	br_v.anchor_right = 1.0
	br_v.anchor_bottom = 1.0
	br_v.position = Vector2(-8, -18)
	br_v.size = tick_v
	panel.add_child(br_v)

func _add_glow_bar(panel: Control, pos: Vector2, size: Vector2, color: Color) -> void:
	if panel == null:
		return
	var bar := ColorRect.new()
	bar.color = color
	bar.position = pos
	bar.size = size
	panel.add_child(bar)

func _build_cooldown_slot(slot: Control, label: Label, fill: ColorRect, label_text: String, fill_color: Color) -> void:
	if slot == null:
		return
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.color = fill_color
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(fill)

	var ring := TextureRect.new()
	ring.texture = _make_ring_texture(56, 2, HUD_EDGE)
	ring.stretch_mode = TextureRect.STRETCH_SCALE
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(ring)
	slot.set_meta("ring", ring)

	var ticks: Array = []
	for i in range(4):
		var tick := ColorRect.new()
		tick.color = HUD_EDGE
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(tick)
		ticks.append(tick)
	slot.set_meta("ticks", ticks)

	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_label(label, 12, HUD_TEXT)
	slot.add_child(label)

func _layout_cooldown_slot(slot: Control, label: Label, fill: ColorRect, size: Vector2, scale: float) -> void:
	if slot == null:
		return
	slot.size = size
	var ring: TextureRect = slot.get_meta("ring") as TextureRect
	if ring != null:
		ring.position = Vector2.ZERO
		ring.size = size

	fill.anchor_left = 0.0
	fill.anchor_right = 0.0
	fill.anchor_top = 1.0
	fill.anchor_bottom = 1.0
	fill.offset_left = 0.0
	fill.offset_right = size.x
	var fill_h := 6.0 * scale
	fill.offset_top = -fill_h
	fill.offset_bottom = 0.0

	label.anchor_left = 0.0
	label.anchor_right = 1.0
	label.anchor_top = 0.0
	label.anchor_bottom = 1.0
	label.offset_left = 0.0
	label.offset_right = 0.0
	label.offset_top = 0.0
	label.offset_bottom = 0.0

	var ticks: Array = slot.get_meta("ticks") as Array
	if ticks.size() == 4:
		var t_len: float = 6.0 * scale
		var t_thick: float = 1.0 * scale
		if t_thick < 1.0:
			t_thick = 1.0
		(ticks[0] as ColorRect).size = Vector2(t_len, t_thick)
		(ticks[0] as ColorRect).position = Vector2((size.x - t_len) * 0.5, 0.0)
		(ticks[1] as ColorRect).size = Vector2(t_thick, t_len)
		(ticks[1] as ColorRect).position = Vector2(size.x - t_thick, (size.y - t_len) * 0.5)
		(ticks[2] as ColorRect).size = Vector2(t_len, t_thick)
		(ticks[2] as ColorRect).position = Vector2((size.x - t_len) * 0.5, size.y - t_thick)
		(ticks[3] as ColorRect).size = Vector2(t_thick, t_len)
		(ticks[3] as ColorRect).position = Vector2(0.0, (size.y - t_len) * 0.5)

func _apply_layout() -> void:
	var vp: Vector2 = get_viewport_rect().size
	if vp == Vector2.ZERO:
		return
	var w: float = vp.x
	var h: float = vp.y
	var scale: float = min(w / 1920.0, h / 1080.0)
	if scale <= 0.0:
		scale = 1.0

	var safe_x: float = w * 0.04
	var safe_y: float = h * 0.04

	# Health (top center)
	var health_size: Vector2 = Vector2(420, 74) * scale
	var health_pos: Vector2 = Vector2(w * 0.5 - health_size.x * 0.5, h * 0.085 - health_size.y * 0.5)
	health_frame.anchor_left = 0.0
	health_frame.anchor_top = 0.0
	health_frame.anchor_right = 0.0
	health_frame.anchor_bottom = 0.0
	health_frame.position = health_pos
	health_frame.size = health_size
	health_surface.anchor_left = 0.0
	health_surface.anchor_top = 0.0
	health_surface.anchor_right = 0.0
	health_surface.anchor_bottom = 0.0
	health_surface.position = Vector2(2.0 * scale, 2.0 * scale)
	health_surface.size = health_size - Vector2(4.0 * scale, 4.0 * scale)
	health_gloss.anchor_left = 0.0
	health_gloss.anchor_top = 0.0
	health_gloss.anchor_right = 0.0
	health_gloss.anchor_bottom = 0.0
	health_gloss.position = health_surface.position
	health_gloss.size = health_surface.size

	var bar_size: Vector2 = Vector2(360, 12) * scale
	var bar_x: float = (health_size.x - bar_size.x) * 0.5
	var bar_y: float = (health_size.y * 0.5) - (bar_size.y * 0.5) + (12.0 * scale)
	health_back.anchor_left = 0.0
	health_back.anchor_top = 0.0
	health_back.anchor_right = 0.0
	health_back.anchor_bottom = 0.0
	health_back.position = Vector2(bar_x, bar_y)
	health_back.size = bar_size
	health_fill.anchor_left = 0.0
	health_fill.anchor_right = 0.0
	health_fill.anchor_top = 0.0
	health_fill.anchor_bottom = 1.0
	health_fill.offset_left = 0.0
	health_fill.offset_right = bar_size.x
	health_fill.offset_top = 0.0
	health_fill.offset_bottom = 0.0
	_health_fill_max = bar_size.x

	var pip_size: Vector2 = Vector2(12, 12) * scale
	var pip_gap: float = 8.0 * scale
	var pip_total: float = pip_size.x * 3.0 + pip_gap * 2.0
	var pip_start_x: float = bar_x - pip_gap - pip_total
	var pip_y: float = bar_y + (bar_size.y - pip_size.y) * 0.5
	for i in range(min(_armor_pips.size(), 3)):
		var pip = _armor_pips[i]
		pip.size = pip_size
		pip.position = Vector2(pip_start_x + float(i) * (pip_size.x + pip_gap), pip_y)

	var xp_size: Vector2 = Vector2(420, 6) * scale
	var xp_y: float = (health_size.y * 0.5) - (xp_size.y * 0.5) + (28.0 * scale)
	xp_back.anchor_left = 0.0
	xp_back.anchor_top = 0.0
	xp_back.anchor_right = 0.0
	xp_back.anchor_bottom = 0.0
	xp_back.position = Vector2((health_size.x - xp_size.x) * 0.5, xp_y)
	xp_back.size = xp_size
	xp_fill.anchor_left = 0.0
	xp_fill.anchor_right = 0.0
	xp_fill.anchor_top = 0.0
	xp_fill.anchor_bottom = 1.0
	xp_fill.offset_left = 0.0
	xp_fill.offset_right = xp_size.x
	xp_fill.offset_top = 0.0
	xp_fill.offset_bottom = 0.0
	_xp_fill_max = xp_size.x

	hp_label.anchor_left = 0.0
	hp_label.anchor_right = 0.0
	hp_label.anchor_top = 0.0
	hp_label.anchor_bottom = 0.0
	hp_label.position = Vector2(bar_x, bar_y - (20.0 * scale))

	level_label.anchor_left = 0.0
	level_label.anchor_right = 0.0
	level_label.anchor_top = 0.0
	level_label.anchor_bottom = 0.0
	level_label.position = Vector2(bar_x + bar_size.x - (200.0 * scale), bar_y - (20.0 * scale))
	level_label.size = Vector2(200.0 * scale, 16.0 * scale)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# Ammo (top right)
	var ammo_size: Vector2 = Vector2(260, 110) * scale
	ammo_panel.anchor_left = 0.0
	ammo_panel.anchor_top = 0.0
	ammo_panel.anchor_right = 0.0
	ammo_panel.anchor_bottom = 0.0
	ammo_panel.position = Vector2(w - safe_x - ammo_size.x, safe_y + (10.0 * scale))
	ammo_panel.size = ammo_size
	ammo_surface.anchor_left = 0.0
	ammo_surface.anchor_top = 0.0
	ammo_surface.anchor_right = 0.0
	ammo_surface.anchor_bottom = 0.0
	ammo_surface.position = Vector2(2.0 * scale, 2.0 * scale)
	ammo_surface.size = ammo_size - Vector2(4.0 * scale, 4.0 * scale)
	ammo_gloss.anchor_left = 0.0
	ammo_gloss.anchor_top = 0.0
	ammo_gloss.anchor_right = 0.0
	ammo_gloss.anchor_bottom = 0.0
	ammo_gloss.position = ammo_surface.position
	ammo_gloss.size = ammo_surface.size

	var pad: float = 8.0 * scale
	ammo_label.position = Vector2(pad, 8.0 * scale)
	ammo_primary_label.position = Vector2(pad, 2.0 * scale)
	ammo_primary_label.size = Vector2(ammo_size.x - pad * 2.0, 54.0 * scale)
	ammo_reserve_label.size = Vector2(80.0 * scale, 22.0 * scale)
	ammo_reserve_label.position = Vector2(ammo_size.x - pad - ammo_reserve_label.size.x, 60.0 * scale)
	var sep_h: float = 52.0 * scale
	ammo_sep.size = Vector2(max(1.0, 1.0 * scale), sep_h)
	ammo_sep.position = Vector2(ammo_reserve_label.position.x - (12.0 * scale), 34.0 * scale)
	speed_label.position = Vector2(pad, ammo_size.y - (20.0 * scale))
	speed_label.size = Vector2(ammo_size.x - pad * 2.0, 16.0 * scale)
	speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# Radar (bottom left)
	var radar_size: Vector2 = Vector2(260, 260) * scale
	radar_display.anchor_left = 0.0
	radar_display.anchor_top = 0.0
	radar_display.anchor_right = 0.0
	radar_display.anchor_bottom = 0.0
	radar_display.position = Vector2(safe_x + (24.0 * scale), h - safe_y - (24.0 * scale) - radar_size.y)
	radar_display.size = radar_size
	radar_display.custom_minimum_size = radar_size

	radar_label.anchor_left = 0.0
	radar_label.anchor_top = 0.0
	radar_label.anchor_right = 0.0
	radar_label.anchor_bottom = 0.0
	radar_label.position = Vector2(safe_x + (40.0 * scale), h - safe_y - (24.0 * scale) - radar_size.y - (18.0 * scale))

	# Cooldowns (bottom right)
	var slot_size: float = 56.0 * scale
	var slot_gap: float = 12.0 * scale
	var panel_w: float = slot_size
	var panel_h: float = slot_size * 3.0 + slot_gap * 2.0
	cooldown_panel.anchor_left = 0.0
	cooldown_panel.anchor_top = 0.0
	cooldown_panel.anchor_right = 0.0
	cooldown_panel.anchor_bottom = 0.0
	cooldown_panel.position = Vector2(w - safe_x - (24.0 * scale) - panel_w, h - safe_y - (24.0 * scale) - panel_h)
	cooldown_panel.size = Vector2(panel_w, panel_h)
	cooldown_surface.anchor_left = 0.0
	cooldown_surface.anchor_top = 0.0
	cooldown_surface.anchor_right = 0.0
	cooldown_surface.anchor_bottom = 0.0
	cooldown_surface.position = Vector2(2.0 * scale, 2.0 * scale)
	cooldown_surface.size = Vector2(panel_w, panel_h) - Vector2(4.0 * scale, 4.0 * scale)
	cooldown_gloss.anchor_left = 0.0
	cooldown_gloss.anchor_top = 0.0
	cooldown_gloss.anchor_right = 0.0
	cooldown_gloss.anchor_bottom = 0.0
	cooldown_gloss.position = cooldown_surface.position
	cooldown_gloss.size = cooldown_surface.size

	grenade_frame.position = Vector2(0, 0)
	blink_frame.position = Vector2(0, slot_size + slot_gap)
	utility_frame.position = Vector2(0, (slot_size + slot_gap) * 2.0)

	_layout_cooldown_slot(grenade_frame, grenade_label, grenade_fill, Vector2(slot_size, slot_size), scale)
	_layout_cooldown_slot(blink_frame, blink_label, blink_fill, Vector2(slot_size, slot_size), scale)
	_layout_cooldown_slot(utility_frame, utility_label, utility_fill, Vector2(slot_size, slot_size), scale)
	_cooldown_fill_max = slot_size

	# Reload bar (bottom center)
	var reload_size: Vector2 = Vector2(240, 18) * scale
	reload_frame.anchor_left = 0.0
	reload_frame.anchor_top = 0.0
	reload_frame.anchor_right = 0.0
	reload_frame.anchor_bottom = 0.0
	reload_frame.position = Vector2(w * 0.5 - reload_size.x * 0.5, h - safe_y - (70.0 * scale))
	reload_frame.size = reload_size
	reload_back.anchor_left = 0.0
	reload_back.anchor_top = 0.0
	reload_back.anchor_right = 0.0
	reload_back.anchor_bottom = 0.0
	reload_back.position = Vector2(2.0 * scale, 2.0 * scale)
	reload_back.size = reload_size - Vector2(4.0 * scale, 4.0 * scale)
	reload_fill.anchor_left = 0.0
	reload_fill.anchor_right = 0.0
	reload_fill.anchor_top = 0.0
	reload_fill.anchor_bottom = 1.0
	reload_fill.offset_left = 0.0
	reload_fill.offset_right = reload_back.size.x
	reload_fill.offset_top = 0.0
	reload_fill.offset_bottom = 0.0
	_reload_fill_max = reload_back.size.x

func _make_frame_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = HUD_BG
	style.border_color = HUD_EDGE
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0.0, 0.5, 0.8, 0.15)
	style.shadow_size = 3
	return style

func _make_interact_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.08, 0.12, 0.65)
	style.border_color = HUD_EDGE
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0.0, 0.7, 1.0, 0.12)
	style.shadow_size = 4
	return style

func _style_label(label: Label, font_size: int, color: Color, crosshair_mode: bool = false) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_font_size_override("font_size", font_size)
	if crosshair_mode:
		label.add_theme_constant_override("outline_size", 2)
