extends Control

@onready var hp_label: Label = Label.new()
@onready var ammo_label: Label = Label.new()
@onready var faction_label: Label = Label.new()
@onready var credits_label: Label = Label.new()
@onready var inventory_label: Label = Label.new()
@onready var party_label: Label = Label.new()
@onready var clan_label: Label = Label.new()
@onready var safezone_label: Label = Label.new()
@onready var crosshair: Label = Label.new()

var faction_scene: PackedScene = preload("res://scenes/FactionSelect.tscn")
var safezone_system: Node

func _ready() -> void:
	var y := 20.0
	_add_label(hp_label, y, "HP: 100")
	y += 22
	_add_label(ammo_label, y, "Ammo: 0 / 0")
	y += 22
	_add_label(faction_label, y, "Faction: Unassigned")
	y += 22
	_add_label(credits_label, y, "Credits: 0")
	y += 22
	_add_label(inventory_label, y, "Inventory: 0 / 0")
	y += 22
	_add_label(party_label, y, "Party: None")
	y += 22
	_add_label(clan_label, y, "Clan: None")
	y += 22
	_add_label(safezone_label, y, "Safe Zone: Unknown")

	add_child(crosshair)
	crosshair.text = "+"
	crosshair.position = get_viewport_rect().size / 2

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		hp_label.text = "HP: %d" % int(player.current_health)
		ammo_label.text = "Ammo: %d / %d" % [int(player.ammo_in_mag), int(player.reserve_ammo)]
		_update_safezone(player)

	faction_label.text = "Faction: %s" % FactionData.get_display_name(SaveManager.get_faction_id())
	credits_label.text = "Credits: %d" % int(SaveManager.get_currency().get("credits", 0))
	var inventory = SaveManager.get_inventory()
	var capacity = int(inventory.get("capacity", 0))
	var items: Array = inventory.get("items", [])
	var total := 0
	for stack in items:
		total += int(stack.get("qty", 0))
	inventory_label.text = "Inventory: %d / %d" % [total, capacity]

	var party_id = SaveManager.get_party_data().get("party_id", "")
	party_label.text = "Party: %s" % (party_id if party_id != "" else "None")
	var clan_id = SaveManager.get_clan_data().get("clan_id", "")
	clan_label.text = "Clan: %s" % (clan_id if clan_id != "" else "None")

	crosshair.position = get_viewport_rect().size / 2

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_faction"):
		_open_faction_select()

func _open_faction_select() -> void:
	if get_tree().get_first_node_in_group("faction_select_ui"):
		return
	var overlay = faction_scene.instantiate()
	overlay.add_to_group("faction_select_ui")
	add_child(overlay)

func _add_label(label: Label, y: float, initial_text: String) -> void:
	add_child(label)
	label.text = initial_text
	label.position = Vector2(20, y)

func _update_safezone(player: Node) -> void:
	if not safezone_system:
		safezone_system = get_tree().get_first_node_in_group("safezone_system")
	if safezone_system and safezone_system.has_method("is_node_in_safezone"):
		var in_safezone = safezone_system.is_node_in_safezone(player)
		safezone_label.text = "Safe Zone: %s" % ("ON" if in_safezone else "OFF")
	else:
		safezone_label.text = "Safe Zone: Unknown"
