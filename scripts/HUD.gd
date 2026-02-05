extends Control

@onready var hp_label: Label = Label.new()
@onready var ammo_label: Label = Label.new()
@onready var crosshair: Label = Label.new()

func _ready() -> void:
	add_child(hp_label)
	hp_label.text = "HP: 100"
	hp_label.position = Vector2(20, 20)

	add_child(ammo_label)
	ammo_label.text = "Ammo: 0 / 0"
	ammo_label.position = Vector2(20, 42)

	add_child(crosshair)
	crosshair.text = "+"
	crosshair.position = get_viewport_rect().size / 2

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		hp_label.text = "HP: %d" % int(player.current_health)
		ammo_label.text = "Ammo: %d / %d" % [int(player.ammo_in_mag), int(player.reserve_ammo)]
