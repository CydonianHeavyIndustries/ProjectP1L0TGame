extends Node
class_name FactionSystem

signal faction_updated(faction_id: String)

func _ready() -> void:
	SaveManager.faction_changed.connect(_on_faction_changed)

func get_current_faction_id() -> String:
	return SaveManager.get_faction_id()

func get_current_faction_data() -> Dictionary:
	return FactionData.get_by_id(get_current_faction_id())

func set_current_faction(faction_id: String) -> void:
	SaveManager.set_faction_id(faction_id)

func _on_faction_changed(faction_id: String) -> void:
	emit_signal("faction_updated", faction_id)
