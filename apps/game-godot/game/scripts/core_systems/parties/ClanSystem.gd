extends Node
class_name ClanSystem

signal clan_updated(clan_data: Dictionary)

func _ready() -> void:
	SaveManager.clan_changed.connect(_on_clan_changed)

func get_clan_data() -> Dictionary:
	return SaveManager.get_clan_data()

func create_placeholder_clan() -> void:
	var clan_id = "clan_%d" % Time.get_unix_time_from_system()
	SaveManager.set_clan_id(clan_id, "local_player")

func leave_clan() -> void:
	SaveManager.clear_clan()

func _on_clan_changed(clan_data: Dictionary) -> void:
	emit_signal("clan_updated", clan_data)
