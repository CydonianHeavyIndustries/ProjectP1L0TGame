extends Node
class_name SafeZoneSystem

signal node_safezone_changed(node: Node, in_safezone: bool, zones: Array)

var _node_zones: Dictionary = {}

func _ready() -> void:
	add_to_group("safezone_system")
	_register_existing_zones()

func _register_existing_zones() -> void:
	for zone in get_tree().get_nodes_in_group("safe_zone"):
		if zone is Area3D:
			_register_zone(zone)

func _register_zone(zone: Area3D) -> void:
	if zone.is_connected("body_entered", _on_zone_body_entered):
		return
	zone.body_entered.connect(_on_zone_body_entered.bind(zone))
	zone.body_exited.connect(_on_zone_body_exited.bind(zone))

func _on_zone_body_entered(body: Node, zone: SafeZoneArea) -> void:
	if not body:
		return
	var zones: Array = _node_zones.get(body, [])
	var zone_id = zone.zone_id
	if zone_id not in zones:
		zones.append(zone_id)
	_node_zones[body] = zones
	emit_signal("node_safezone_changed", body, true, zones)

func _on_zone_body_exited(body: Node, zone: SafeZoneArea) -> void:
	if not body or not _node_zones.has(body):
		return
	var zones: Array = _node_zones[body]
	zones.erase(zone.zone_id)
	if zones.is_empty():
		_node_zones.erase(body)
		emit_signal("node_safezone_changed", body, false, [])
	else:
		_node_zones[body] = zones
		emit_signal("node_safezone_changed", body, true, zones)

func is_node_in_safezone(node: Node) -> bool:
	return _node_zones.has(node)

func get_node_zones(node: Node) -> Array:
	return _node_zones.get(node, [])

func is_pvp_allowed(shooter: Node, target: Node) -> bool:
	if is_node_in_safezone(shooter):
		return false
	if is_node_in_safezone(target):
		return false
	return true
