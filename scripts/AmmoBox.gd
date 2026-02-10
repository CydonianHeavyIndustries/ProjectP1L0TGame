extends Node3D

@export var interact_action := "interact"
@export var hint_text := "Press E to refill ammo"
@export var used_text := "Ammo refilled + loadout ready"
@export var interact_prompt := "Press E to refill ammo"

var _player: Node = null

@onready var area: Area3D = $Area

func _ready() -> void:
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if _player == null:
		return
	if Input.is_action_just_pressed(interact_action):
		_apply_ammo()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body
		_show_hint(hint_text)

func _on_body_exited(body: Node) -> void:
	if body == _player:
		_player = null

func _apply_ammo() -> void:
	if _player == null:
		return
	if _player.has_method("refill_ammo"):
		_player.refill_ammo()
	if _player.has_method("open_loadout"):
		_player.open_loadout()
	_show_hint(used_text)

func _show_hint(text: String) -> void:
	if _player and _player.has_method("_hud_hint"):
		_player._hud_hint(text)

func get_interact_prompt() -> String:
	return interact_prompt
