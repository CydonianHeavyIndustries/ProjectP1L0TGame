extends Node

signal save_loaded
signal save_written
signal faction_changed(new_faction_id: String)
signal party_changed(party_data: Dictionary)
signal clan_changed(clan_data: Dictionary)
signal economy_changed
signal spaceship_home_changed(home_data: Dictionary)

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 1

var _save_data: Dictionary = {}
var _dirty := false
var _save_queued := false

func _ready() -> void:
	load_or_create()

func load_or_create() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var text = file.get_as_text()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			_save_data = _merge_defaults(parsed)
		else:
			_save_data = _default_save()
	else:
		_save_data = _default_save()
		save_now()

	_dirty = false
	emit_signal("save_loaded")

	_log("Save loaded. Version %s" % str(_save_data.get("version", -1)))

func save_now() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(_save_data, "\t"))
	_dirty = false
	emit_signal("save_written")
	_log("Save written to %s" % SAVE_PATH)

func _log(message: String) -> void:
	if not DebugConfig.LOGGING:
		return
	var logger = get_node_or_null("/root/Logger")
	if logger and logger.has_method("info"):
		logger.info("[SaveManager] " + message)
	else:
		print("[SaveManager] " + message)

func queue_save() -> void:
	_dirty = true
	if not DebugConfig.AUTO_SAVE_ON_CHANGE:
		return
	if _save_queued:
		return
	_save_queued = true
	call_deferred("_save_deferred")

func _save_deferred() -> void:
	_save_queued = false
	if _dirty:
		save_now()

func get_save_data_copy() -> Dictionary:
	return _save_data.duplicate(true)

func get_faction_id() -> String:
	return _save_data.get("player", {}).get("faction_id", "chii")

func set_faction_id(faction_id: String) -> void:
	if faction_id == get_faction_id():
		return
	_save_data["player"]["faction_id"] = faction_id
	queue_save()
	emit_signal("faction_changed", faction_id)

func get_party_data() -> Dictionary:
	return _save_data.get("party", {})

func set_party_id(party_id: String, leader_id: String = "") -> void:
	_save_data["party"]["party_id"] = party_id
	_save_data["party"]["leader_id"] = leader_id
	queue_save()
	emit_signal("party_changed", get_party_data())

func clear_party() -> void:
	_save_data["party"] = _default_save().get("party", {}).duplicate(true)
	queue_save()
	emit_signal("party_changed", get_party_data())

func get_clan_data() -> Dictionary:
	return _save_data.get("clan", {})

func set_clan_id(clan_id: String, leader_id: String = "") -> void:
	_save_data["clan"]["clan_id"] = clan_id
	_save_data["clan"]["leader_id"] = leader_id
	queue_save()
	emit_signal("clan_changed", get_clan_data())

func clear_clan() -> void:
	_save_data["clan"] = _default_save().get("clan", {}).duplicate(true)
	queue_save()
	emit_signal("clan_changed", get_clan_data())

func get_currency() -> Dictionary:
	return _save_data.get("player", {}).get("currency", {})

func add_credits(amount: int) -> void:
	var currency = get_currency()
	currency["credits"] = currency.get("credits", 0) + amount
	_save_data["player"]["currency"] = currency
	queue_save()
	emit_signal("economy_changed")

func spend_credits(amount: int) -> bool:
	var currency = get_currency()
	var credits = currency.get("credits", 0)
	if credits < amount:
		return false
	currency["credits"] = credits - amount
	_save_data["player"]["currency"] = currency
	queue_save()
	emit_signal("economy_changed")
	return true

func get_inventory() -> Dictionary:
	return _save_data.get("player", {}).get("inventory", {})

func set_inventory_items(items: Array) -> void:
	_save_data["player"]["inventory"]["items"] = items
	queue_save()
	emit_signal("economy_changed")

func get_spaceship_home() -> Dictionary:
	return _save_data.get("spaceship_home", {})

func get_spaceship_home_transform() -> Transform3D:
	var home = get_spaceship_home()
	var pos = _vec3_from_dict(home.get("position", {}), Vector3(0, 1.5, 6))
	var rot = _vec3_from_dict(home.get("rotation", {}), Vector3.ZERO)
	return Transform3D(Basis.from_euler(rot), pos)

func set_spaceship_home_transform(transform: Transform3D) -> void:
	var home = get_spaceship_home()
	home["position"] = _vec3_to_dict(transform.origin)
	home["rotation"] = _vec3_to_dict(transform.basis.get_euler())
	_save_data["spaceship_home"] = home
	queue_save()
	emit_signal("spaceship_home_changed", home)

func set_home_permissions(allowed_party_ids: Array, allowed_clan_ids: Array, allowed_player_ids: Array) -> void:
	var home = get_spaceship_home()
	home["permissions"]["allowed_party_ids"] = allowed_party_ids
	home["permissions"]["allowed_clan_ids"] = allowed_clan_ids
	home["permissions"]["allowed_player_ids"] = allowed_player_ids
	_save_data["spaceship_home"] = home
	queue_save()
	emit_signal("spaceship_home_changed", home)

static func _vec3_to_dict(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

static func _vec3_from_dict(data: Dictionary, fallback: Vector3) -> Vector3:
	if data.is_empty():
		return fallback
	return Vector3(
		float(data.get("x", fallback.x)),
		float(data.get("y", fallback.y)),
		float(data.get("z", fallback.z))
	)

func _default_save() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"player": {
			"display_name": "Pilot",
			"faction_id": "chii",
			"inventory": {
				"capacity": 40,
				"items": []
			},
			"currency": {
				"credits": 0
			}
		},
		"party": {
			"party_id": "",
			"leader_id": "",
			"members": []
		},
		"clan": {
			"clan_id": "",
			"leader_id": "",
			"members": []
		},
		"spaceship_home": {
			"home_id": "starter_hab",
			"position": _vec3_to_dict(Vector3(0, 1.5, 6)),
			"rotation": _vec3_to_dict(Vector3.ZERO),
			"permissions": {
				"allowed_party_ids": [],
				"allowed_clan_ids": [],
				"allowed_player_ids": []
			}
		}
	}

func _merge_defaults(loaded: Dictionary) -> Dictionary:
	var defaults = _default_save()
	return _deep_merge(defaults, loaded)

func _deep_merge(base: Dictionary, override: Dictionary) -> Dictionary:
	var merged = base.duplicate(true)
	for key in override.keys():
		if merged.has(key) and merged[key] is Dictionary and override[key] is Dictionary:
			merged[key] = _deep_merge(merged[key], override[key])
		else:
			merged[key] = override[key]
	return merged
