extends Node
class_name PartySystem

signal party_updated(party_data: Dictionary)

func _save_manager() -> Node:
	return get_node_or_null("/root/SaveManager")

func _ready() -> void:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_signal("party_changed"):
		save_manager.party_changed.connect(_on_party_changed)

func get_party_data() -> Dictionary:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("get_party_data"):
		return save_manager.get_party_data()
	return {}

func create_placeholder_party() -> void:
	var party_id = "party_%d" % Time.get_unix_time_from_system()
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("set_party_id"):
		save_manager.set_party_id(party_id, "local_player")

func leave_party() -> void:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("clear_party"):
		save_manager.clear_party()

func _on_party_changed(party_data: Dictionary) -> void:
	emit_signal("party_updated", party_data)
