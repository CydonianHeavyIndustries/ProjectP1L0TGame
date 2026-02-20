extends Node
class_name FactionSystem

signal faction_updated(faction_id: String)

const FACTION_DATA = preload("res://scripts/core_systems/factions/FactionData.gd")

func _save_manager() -> Node:
	return get_node_or_null("/root/SaveManager")

func _ready() -> void:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_signal("faction_changed"):
		save_manager.faction_changed.connect(_on_faction_changed)

func get_current_faction_id() -> String:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("get_faction_id"):
		return save_manager.get_faction_id()
	return "chii"

func get_current_faction_data() -> Dictionary:
	return FACTION_DATA.get_by_id(get_current_faction_id())

func set_current_faction(faction_id: String) -> void:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("set_faction_id"):
		save_manager.set_faction_id(faction_id)

func _on_faction_changed(faction_id: String) -> void:
	emit_signal("faction_updated", faction_id)
