extends Control

@onready var hp_label: Label = Label.new()
@onready var ammo_label: Label = Label.new()
@onready var crosshair: Label = Label.new()
@onready var hint_label: Label = Label.new()
@onready var gun_radial: Control = Control.new()
@onready var titan_radial: Control = Control.new()
@onready var health_back: ColorRect = ColorRect.new()
@onready var health_fill: ColorRect = ColorRect.new()
@onready var reload_back: ColorRect = ColorRect.new()
@onready var reload_fill: ColorRect = ColorRect.new()
@onready var grenade_label: Label = Label.new()
@onready var grenade_back: ColorRect = ColorRect.new()
@onready var grenade_fill: ColorRect = ColorRect.new()
@onready var blink_label: Label = Label.new()
@onready var blink_back: ColorRect = ColorRect.new()
@onready var blink_fill: ColorRect = ColorRect.new()

var hint_timer := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("hud")
	add_child(hp_label)
	hp_label.text = "HP: 100"
	hp_label.position = Vector2(20, 20)

	add_child(ammo_label)
	ammo_label.text = "Ammo: 0 / 0"
	ammo_label.position = Vector2(20, 42)

	add_child(crosshair)
	crosshair.text = "+"
	crosshair.position = (get_viewport_rect().size / 2) - Vector2(4, 6)

	add_child(hint_label)
	hint_label.visible = false
	hint_label.position = Vector2(20, 64)
	hint_label.modulate = Color(0.75, 0.85, 1.0, 1.0)

	_setup_health_bar()
	_setup_reload_bar()
	_setup_cooldown_bars()

	gun_radial = _build_radial_menu("GUN MENU", ["Primary", "Secondary", "Tertiary", "Melee", "Extras", "Back"])
	titan_radial = _build_radial_menu("TITAN COMMAND", ["Drop", "Recall", "Follow", "Hold", "Assist", "Back"])
	gun_radial.visible = false
	titan_radial.visible = false

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		hp_label.text = "HP: %d" % int(player.current_health)
		ammo_label.text = "Ammo: %d / %d" % [int(player.ammo_in_mag), int(player.reserve_ammo)]
		var ratio := 1.0
		if player.max_health > 0.0:
			ratio = float(player.current_health) / float(player.max_health)
		_update_health_bar(ratio)

		_update_reload_bar(player.reload_progress, player.is_reloading)
		_update_cooldown_bar(grenade_fill, grenade_label, "G", player.grenade_cooldown, player.grenade_cooldown_time)
		_update_cooldown_bar(blink_fill, blink_label, "MMB", player.blink_cooldown, player.blink_cooldown_time)

	if hint_timer > 0.0:
		hint_timer = max(0.0, hint_timer - _delta)
		if hint_timer <= 0.0:
			hint_label.visible = false

	var viewport_center = get_viewport_rect().size / 2
	crosshair.position = viewport_center - Vector2(4, 6)

func show_hint(text: String) -> void:
	hint_label.text = text
	hint_label.visible = true
	hint_timer = 1.4

func show_gun_radial(show: bool) -> void:
	gun_radial.visible = show

func show_titan_radial(show: bool) -> void:
	titan_radial.visible = show

func _setup_health_bar() -> void:
	add_child(health_back)
	health_back.anchor_left = 0.5
	health_back.anchor_right = 0.5
	health_back.anchor_top = 0.0
	health_back.anchor_bottom = 0.0
	health_back.offset_left = -180
	health_back.offset_right = 180
	health_back.offset_top = 10
	health_back.offset_bottom = 22
	health_back.color = Color(0.1, 0.12, 0.16, 0.9)
	health_back.add_child(health_fill)
	health_fill.anchor_left = 0.0
	health_fill.anchor_right = 0.0
	health_fill.anchor_top = 0.0
	health_fill.anchor_bottom = 1.0
	health_fill.offset_left = 0.0
	health_fill.offset_right = 360.0
	health_fill.offset_top = 0.0
	health_fill.offset_bottom = 0.0
	health_fill.color = Color(0.2, 1.0, 0.3, 0.9)

func _setup_reload_bar() -> void:
	add_child(reload_back)
	reload_back.anchor_left = 0.5
	reload_back.anchor_right = 0.5
	reload_back.anchor_top = 1.0
	reload_back.anchor_bottom = 1.0
	reload_back.offset_left = -120
	reload_back.offset_right = 120
	reload_back.offset_top = -64
	reload_back.offset_bottom = -54
	reload_back.color = Color(0.08, 0.08, 0.1, 0.85)
	reload_back.visible = false
	reload_back.add_child(reload_fill)
	reload_fill.anchor_left = 0.0
	reload_fill.anchor_right = 0.0
	reload_fill.anchor_top = 0.0
	reload_fill.anchor_bottom = 1.0
	reload_fill.offset_left = 0.0
	reload_fill.offset_right = 240.0
	reload_fill.color = Color(0.3, 0.7, 1.0, 0.9)

func _setup_cooldown_bars() -> void:
	add_child(grenade_back)
	grenade_back.anchor_left = 1.0
	grenade_back.anchor_right = 1.0
	grenade_back.anchor_top = 1.0
	grenade_back.anchor_bottom = 1.0
	grenade_back.offset_left = -160
	grenade_back.offset_right = -40
	grenade_back.offset_top = -64
	grenade_back.offset_bottom = -48
	grenade_back.color = Color(0.08, 0.08, 0.1, 0.85)
	grenade_back.add_child(grenade_fill)
	grenade_fill.anchor_left = 0.0
	grenade_fill.anchor_right = 0.0
	grenade_fill.anchor_top = 0.0
	grenade_fill.anchor_bottom = 1.0
	grenade_fill.offset_left = 0.0
	grenade_fill.offset_right = 120.0
	grenade_fill.color = Color(0.9, 0.55, 0.2, 0.9)
	add_child(grenade_label)
	grenade_label.text = "G"
	grenade_label.anchor_left = 1.0
	grenade_label.anchor_right = 1.0
	grenade_label.anchor_top = 1.0
	grenade_label.anchor_bottom = 1.0
	grenade_label.offset_left = -190
	grenade_label.offset_right = -120
	grenade_label.offset_top = -70
	grenade_label.offset_bottom = -54

	add_child(blink_back)
	blink_back.anchor_left = 1.0
	blink_back.anchor_right = 1.0
	blink_back.anchor_top = 1.0
	blink_back.anchor_bottom = 1.0
	blink_back.offset_left = -160
	blink_back.offset_right = -40
	blink_back.offset_top = -44
	blink_back.offset_bottom = -28
	blink_back.color = Color(0.08, 0.08, 0.1, 0.85)
	blink_back.add_child(blink_fill)
	blink_fill.anchor_left = 0.0
	blink_fill.anchor_right = 0.0
	blink_fill.anchor_top = 0.0
	blink_fill.anchor_bottom = 1.0
	blink_fill.offset_left = 0.0
	blink_fill.offset_right = 120.0
	blink_fill.color = Color(0.3, 0.8, 1.0, 0.9)
	add_child(blink_label)
	blink_label.text = "MMB"
	blink_label.anchor_left = 1.0
	blink_label.anchor_right = 1.0
	blink_label.anchor_top = 1.0
	blink_label.anchor_bottom = 1.0
	blink_label.offset_left = -198
	blink_label.offset_right = -120
	blink_label.offset_top = -50
	blink_label.offset_bottom = -32

func _update_health_bar(ratio: float) -> void:
	ratio = clamp(ratio, 0.0, 1.0)
	health_fill.offset_right = 360.0 * ratio

func _update_reload_bar(progress: float, active: bool) -> void:
	reload_back.visible = active
	if not active:
		return
	reload_fill.offset_right = 240.0 * clamp(progress, 0.0, 1.0)

func _update_cooldown_bar(fill: ColorRect, label: Label, label_text: String, time_left: float, total: float) -> void:
	if total <= 0.0:
		total = 1.0
	var ratio: float = 1.0 - clampf(time_left / total, 0.0, 1.0)
	fill.offset_right = 120.0 * ratio
	var base_color := Color(0.9, 0.55, 0.2, 0.9)
	var ready_color := Color(0.9, 0.75, 0.35, 0.9)
	if label_text == "MMB":
		base_color = Color(0.3, 0.8, 1.0, 0.9)
		ready_color = Color(0.5, 0.9, 1.0, 0.9)
	if time_left <= 0.0:
		label.text = "%s READY" % label_text
		fill.color = ready_color
	else:
		label.text = "%s %.1f" % [label_text, time_left]
		fill.color = base_color

func _build_radial_menu(title: String, slots: Array) -> Control:
	var root := Control.new()
	root.anchors_preset = Control.PRESET_CENTER
	root.offset_left = -150
	root.offset_top = -150
	root.offset_right = 150
	root.offset_bottom = 150
	add_child(root)

	var bg := Panel.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.05, 0.08, 0.8)
	style.border_color = Color(0.2, 0.8, 1.0, 0.8)
	style.border_width_all = 2
	style.corner_radius_all = 150
	bg.add_theme_stylebox_override("panel", style)
	root.add_child(bg)

	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.anchor_right = 1.0
	title_label.anchor_bottom = 1.0
	root.add_child(title_label)

	var center = Vector2(150, 150)
	var radius = 95.0
	for i in range(slots.size()):
		var slot_label := Label.new()
		slot_label.text = str(slots[i])
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot_label.custom_minimum_size = Vector2(90, 20)
		var angle = (TAU * float(i) / float(slots.size())) - (PI / 2.0)
		var pos = center + Vector2(cos(angle), sin(angle)) * radius
		slot_label.position = pos - (slot_label.custom_minimum_size * 0.5)
		root.add_child(slot_label)

	return root
