extends Node
class_name ClanSystem

signal clan_updated(clan_data: Dictionary)

func _save_manager() -> Node:
	return get_node_or_null("/root/SaveManager")

func _ready() -> void:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_signal("clan_changed"):
		save_manager.clan_changed.connect(_on_clan_changed)

func get_clan_data() -> Dictionary:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("get_clan_data"):
		return save_manager.get_clan_data()
	return {}

func create_placeholder_clan() -> void:
	var clan_id = "clan_%d" % Time.get_unix_time_from_system()
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("set_clan_id"):
		save_manager.set_clan_id(clan_id, "local_player")

func leave_clan() -> void:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("clear_clan"):
		save_manager.clear_clan()

func _on_clan_changed(clan_data: Dictionary) -> void:
	emit_signal("clan_updated", clan_data)
