extends Control
class_name FactionSelect

signal faction_selected(faction_id: String)

@onready var buttons_container: VBoxContainer = $Panel/Margins/VBox/Buttons
@onready var description_label: Label = $Panel/Margins/VBox/Description
@onready var current_label: Label = $Panel/Margins/VBox/Current
@onready var close_button: Button = $Panel/Margins/VBox/Close

func _ready() -> void:
	_build_buttons()
	_update_current_label()
	close_button.pressed.connect(_on_close)
	SaveManager.faction_changed.connect(_on_faction_changed)

func _build_buttons() -> void:
	for faction in FactionData.FACTIONS:
		var button := Button.new()
		button.text = "%s — %s" % [faction.get("display_name", ""), faction.get("tagline", "")]
		button.pressed.connect(_on_faction_pressed.bind(faction.get("id", "")))
		buttons_container.add_child(button)

func _on_faction_pressed(faction_id: String) -> void:
	SaveManager.set_faction_id(faction_id)
	faction_selected.emit(faction_id)
	_update_description(faction_id)

func _update_description(faction_id: String) -> void:
	var data = FactionData.get_by_id(faction_id)
	description_label.text = data.get("description", "")

func _update_current_label() -> void:
	var current = SaveManager.get_faction_id()
	current_label.text = "Current: %s" % FactionData.get_display_name(current)
	_update_description(current)

func _on_faction_changed(faction_id: String) -> void:
	_update_current_label()

func _on_close() -> void:
	queue_free()
