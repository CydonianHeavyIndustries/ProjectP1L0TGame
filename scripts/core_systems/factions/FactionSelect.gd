extends Control
class_name FactionSelect

signal faction_selected(faction_id: String)

const FACTION_DATA = preload("res://scripts/core_systems/factions/FactionData.gd")

@onready var buttons_container: VBoxContainer = $Panel/Margins/VBox/Buttons
@onready var description_label: Label = $Panel/Margins/VBox/Description
@onready var current_label: Label = $Panel/Margins/VBox/Current
@onready var close_button: Button = $Panel/Margins/VBox/Close

func _save_manager() -> Node:
	return get_node_or_null("/root/SaveManager")

func _ready() -> void:
	_build_buttons()
	_update_current_label()
	close_button.pressed.connect(_on_close)
	var save_manager = _save_manager()
	if save_manager and save_manager.has_signal("faction_changed"):
		save_manager.faction_changed.connect(_on_faction_changed)

func _build_buttons() -> void:
	for faction in FACTION_DATA.FACTIONS:
		var button := Button.new()
		button.text = "%s — %s" % [faction.get("display_name", ""), faction.get("tagline", "")]
		button.pressed.connect(_on_faction_pressed.bind(faction.get("id", "")))
		buttons_container.add_child(button)

func _on_faction_pressed(faction_id: String) -> void:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("set_faction_id"):
		save_manager.set_faction_id(faction_id)
	faction_selected.emit(faction_id)
	_update_description(faction_id)

func _update_description(faction_id: String) -> void:
	var data = FACTION_DATA.get_by_id(faction_id)
	description_label.text = data.get("description", "")

func _update_current_label() -> void:
	var current := "chii"
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("get_faction_id"):
		current = save_manager.get_faction_id()
	current_label.text = "Current: %s" % FACTION_DATA.get_display_name(current)
	_update_description(current)

func _on_faction_changed(_faction_id: String) -> void:
	_update_current_label()

func _on_close() -> void:
	queue_free()
