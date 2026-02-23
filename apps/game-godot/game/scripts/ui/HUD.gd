extends Control

const CHII_LOGO := preload("res://assets/ui/chii_logo.png")

@onready var logo: TextureRect = TextureRect.new()
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
	add_child(logo)
	logo.texture = CHII_LOGO
	logo.position = Vector2(16, 14)
	logo.custom_minimum_size = Vector2(60, 60)
	logo.size = Vector2(60, 60)
	logo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.modulate = Color(1, 1, 1, 0.75)

	add_child(hp_label)
	hp_label.text = "HP: 100"
	hp_label.position = Vector2(84, 24)

	add_child(ammo_label)
	ammo_label.text = "Ammo: 0 / 0"
	ammo_label.position = Vector2(84, 46)

	add_child(crosshair)
	crosshair.text = "+"
	_recenter_crosshair()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_recenter_crosshair()

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("local_player")
	if player:
		hp_label.text = "HP: %d" % int(player.current_health)
		ammo_label.text = "Ammo: %d / %d" % [int(player.ammo_in_mag), int(player.reserve_ammo)]

func _recenter_crosshair() -> void:
	crosshair.position = (get_viewport_rect().size * 0.5) - Vector2(4, 10)
