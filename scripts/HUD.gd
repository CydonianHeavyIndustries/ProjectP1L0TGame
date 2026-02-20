extends Control

@onready var hp_label: Label = Label.new()
@onready var ammo_label: Label = Label.new()
@onready var speed_label: Label = Label.new()
@onready var crosshair: Label = Label.new()
@onready var hint_label: Label = Label.new()
@onready var interact_label: Label = Label.new()
@onready var hitmarker: Label = Label.new()
@onready var damage_flash: ColorRect = ColorRect.new()
@onready var gun_radial: Label = Label.new()
@onready var titan_radial: Label = Label.new()
@onready var skill_tree_panel: Panel = Panel.new()
@onready var skill_tree_label: Label = Label.new()

var hint_timer := 0.0
var hitmarker_timer := 0.0
var damage_flash_timer := 0.0
var reload_progress := 0.0
var grenade_cd := 0.0
var blink_cd := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("hud")

	add_child(damage_flash)
	damage_flash.anchor_right = 1.0
	damage_flash.anchor_bottom = 1.0
	damage_flash.color = Color(1.0, 0.12, 0.12, 0.0)
	damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(hp_label)
	hp_label.position = Vector2(22, 18)
	_style_label(hp_label, 16)

	add_child(ammo_label)
	ammo_label.position = Vector2(22, 42)
	_style_label(ammo_label, 16)

	add_child(speed_label)
	speed_label.position = Vector2(get_viewport_rect().size.x - 180, 18)
	_style_label(speed_label, 14)

	add_child(crosshair)
	crosshair.text = "+"
	_style_label(crosshair, 22)
	_recenter_crosshair()

	add_child(hitmarker)
	hitmarker.text = "X"
	_style_label(hitmarker, 18, Color(1.0, 0.65, 0.35, 1.0))
	hitmarker.visible = false

	add_child(hint_label)
	_style_label(hint_label, 16)
	hint_label.visible = false

	add_child(interact_label)
	_style_label(interact_label, 16, Color(0.75, 0.95, 1.0, 1.0))
	interact_label.visible = false

	add_child(gun_radial)
	gun_radial.text = "R radial: 1 Rifle | 2 Sniper | 3 Rocket | 4 Pistol | 5 Sword"
	gun_radial.visible = false
	_style_label(gun_radial, 14)

	add_child(titan_radial)
	titan_radial.text = "V radial: 1 Follow | 2 Guard"
	titan_radial.visible = false
	_style_label(titan_radial, 14)

	add_child(skill_tree_panel)
	skill_tree_panel.visible = false
	skill_tree_panel.size = Vector2(360, 220)
	skill_tree_panel.position = (get_viewport_rect().size * 0.5) - (skill_tree_panel.size * 0.5)
	skill_tree_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.02, 0.06, 0.1, 0.93)
	sb.border_color = Color(0.24, 0.84, 1.0, 0.95)
	sb.set_border_width_all(2)
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	skill_tree_panel.add_theme_stylebox_override("panel", sb)

	skill_tree_panel.add_child(skill_tree_label)
	skill_tree_label.text = "Skill Tree Placeholder\n\nNot implemented yet"
	skill_tree_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skill_tree_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	skill_tree_label.anchor_right = 1.0
	skill_tree_label.anchor_bottom = 1.0
	_style_label(skill_tree_label, 18)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if crosshair:
			_recenter_crosshair()
		if speed_label:
			speed_label.position = Vector2(get_viewport_rect().size.x - 180, 18)
		if hint_label:
			hint_label.position = Vector2((get_viewport_rect().size.x * 0.5) - 240, get_viewport_rect().size.y - 86)
		if interact_label:
			interact_label.position = Vector2((get_viewport_rect().size.x * 0.5) - 240, (get_viewport_rect().size.y * 0.5) + 46)
		if gun_radial:
			gun_radial.position = Vector2((get_viewport_rect().size.x * 0.5) - 250, (get_viewport_rect().size.y * 0.5) + 78)
		if titan_radial:
			titan_radial.position = Vector2((get_viewport_rect().size.x * 0.5) - 140, (get_viewport_rect().size.y * 0.5) + 108)
		if skill_tree_panel:
			skill_tree_panel.position = (get_viewport_rect().size * 0.5) - (skill_tree_panel.size * 0.5)

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("local_player")
	if player:
		hp_label.text = "HP: %d" % int(player.current_health)
		ammo_label.text = "Ammo: %d / %d" % [int(player.ammo_in_mag), int(player.reserve_ammo)]
		var vel := player.velocity as Vector3
		speed_label.text = "SPD: %.1f" % Vector2(vel.x, vel.z).length()

	if hint_timer > 0.0:
		hint_timer = max(0.0, hint_timer - delta)
		hint_label.visible = hint_timer > 0.0

	if hitmarker_timer > 0.0:
		hitmarker_timer = max(0.0, hitmarker_timer - delta)
		hitmarker.visible = hitmarker_timer > 0.0

	if damage_flash_timer > 0.0:
		damage_flash_timer = max(0.0, damage_flash_timer - delta)
		damage_flash.color.a = 0.25 * (damage_flash_timer / 0.16)
	else:
		damage_flash.color.a = 0.0

func show_hint(text: String) -> void:
	hint_label.text = text
	hint_label.visible = true
	hint_timer = 2.0

func log_placeholder(text: String) -> void:
	show_hint("Not Implemented: %s" % text)

func show_hitmarker() -> void:
	hitmarker.visible = true
	hitmarker_timer = 0.1

func show_damage_flash() -> void:
	damage_flash_timer = 0.16
	damage_flash.color.a = 0.25

func show_gun_radial(show: bool) -> void:
	gun_radial.visible = show

func get_gun_radial_choice() -> String:
	var center := get_viewport_rect().size * 0.5
	var mouse := get_viewport().get_mouse_position()
	var dir := mouse - center
	if dir.length() < 10.0:
		return ""
	var a := wrapf(atan2(dir.y, dir.x), 0.0, TAU)
	if a < TAU * 0.2:
		return "rifle"
	if a < TAU * 0.4:
		return "sniper"
	if a < TAU * 0.6:
		return "rocket"
	if a < TAU * 0.8:
		return "pistol"
	return "sword"

func show_titan_radial(show: bool) -> void:
	titan_radial.visible = show

func get_titan_radial_choice() -> String:
	var center := get_viewport_rect().size * 0.5
	var mouse := get_viewport().get_mouse_position()
	return "guard" if mouse.x >= center.x else "follow"

func show_skill_tree(show: bool) -> void:
	skill_tree_panel.visible = show

func set_reload_progress(value: float) -> void:
	reload_progress = clamp(value, 0.0, 1.0)

func set_cooldowns(grenade_value: float, blink_value: float) -> void:
	grenade_cd = max(0.0, grenade_value)
	blink_cd = max(0.0, blink_value)

func set_interact_prompt(text: String, visible: bool) -> void:
	interact_label.text = text
	interact_label.visible = visible

func _style_label(label: Label, size: int, color: Color = Color(0.66, 0.9, 1.0, 1.0)) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)

func _recenter_crosshair() -> void:
	if crosshair == null or hitmarker == null:
		return
	crosshair.position = (get_viewport_rect().size * 0.5) - Vector2(6, 10)
	hitmarker.position = (get_viewport_rect().size * 0.5) - Vector2(7, 11)
