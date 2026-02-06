extends Control
signal play_pressed

@onready var play_button: Button = $VBox/Play
@onready var faction_button: Button = $VBox/Faction
@onready var faction_status: Label = $VBox/FactionStatus
@onready var options_button: Button = $VBox/Options
@onready var exit_button: Button = $VBox/Exit

var faction_scene: PackedScene = preload("res://scenes/FactionSelect.tscn")

func _ready() -> void:
	play_button.pressed.connect(_on_play)
	faction_button.pressed.connect(_on_faction)
	options_button.pressed.connect(_on_options)
	exit_button.pressed.connect(_on_exit)
	SaveManager.faction_changed.connect(_on_faction_changed)
	_refresh_faction_status()

func _on_play() -> void:
	play_pressed.emit()

func _on_options() -> void:
	# Placeholder: hook options later
	pass

func _on_exit() -> void:
	get_tree().quit()

func _on_faction() -> void:
	var overlay = faction_scene.instantiate()
	add_child(overlay)

func _on_faction_changed(_faction_id: String) -> void:
	_refresh_faction_status()

func _refresh_faction_status() -> void:
	var faction_id = SaveManager.get_faction_id()
	faction_status.text = "Faction: %s" % FactionData.get_display_name(faction_id)
