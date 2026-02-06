extends Control

@onready var hp_label: Label = Label.new()
@onready var ammo_label: Label = Label.new()
@onready var crosshair: Label = Label.new()
@onready var hint_label: Label = Label.new()
@onready var gun_radial: Panel = Panel.new()
@onready var titan_radial: Panel = Panel.new()

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
	crosshair.position = get_viewport_rect().size / 2

	add_child(hint_label)
	hint_label.visible = false
	hint_label.position = Vector2(20, 64)
	hint_label.modulate = Color(0.75, 0.85, 1.0, 1.0)

	_setup_radial_panel(gun_radial, "GUN MENU (HOLD R)")
	_setup_radial_panel(titan_radial, "TITAN COMMAND (HOLD V)")
	gun_radial.visible = false
	titan_radial.visible = false

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		hp_label.text = "HP: %d" % int(player.current_health)
		ammo_label.text = "Ammo: %d / %d" % [int(player.ammo_in_mag), int(player.reserve_ammo)]

	if hint_timer > 0.0:
		hint_timer = max(0.0, hint_timer - _delta)
		if hint_timer <= 0.0:
			hint_label.visible = false

func show_hint(text: String) -> void:
	hint_label.text = text
	hint_label.visible = true
	hint_timer = 1.4

func show_gun_radial(show: bool) -> void:
	gun_radial.visible = show

func show_titan_radial(show: bool) -> void:
	titan_radial.visible = show

func _setup_radial_panel(panel: Panel, title: String) -> void:
	panel.anchors_preset = Control.PRESET_CENTER
	panel.offset_left = -160
	panel.offset_top = -60
	panel.offset_right = 160
	panel.offset_bottom = 60

	var label := Label.new()
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	panel.add_child(label)
	add_child(panel)
