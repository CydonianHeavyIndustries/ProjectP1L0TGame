extends Node
class_name PartySystem

signal party_updated(party_data: Dictionary)

func _ready() -> void:
	SaveManager.party_changed.connect(_on_party_changed)

func get_party_data() -> Dictionary:
	return SaveManager.get_party_data()

func create_placeholder_party() -> void:
	var party_id = "party_%d" % Time.get_unix_time_from_system()
	SaveManager.set_party_id(party_id, "local_player")

func leave_party() -> void:
	SaveManager.clear_party()

func _on_party_changed(party_data: Dictionary) -> void:
	emit_signal("party_updated", party_data)
