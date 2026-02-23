extends Node

signal points_changed(player: Node, total: int)
signal match_ended(reason: String)

const MATCH_POINT_CAP := 900
const MATCH_TIME_SECONDS := 20 * 60

const POINTS := {
	"player_kill": 5,
	"player_execute": 8,
	"grunt_kill": 1,
	"grunt_execute": 2,
	"upgraded_grunt_kill": 2,
	"upgraded_grunt_execute": 3,
	"dwarf_titan_kill": 4,
	"dwarf_titan_execute": 7,
	"titan_kill": 8,
	"titan_execute": 12,
	"titan_kill_and_survive": 15
}

var _elapsed := 0.0
var _player_points := {}
var _player_breakdown := {}
var _sources: Array = []
var _history: Array = []
var _ended := false

func _ready() -> void:
	add_to_group("point_system")
	set_process(true)

func _process(delta: float) -> void:
	if _ended:
		return
	_elapsed += delta
	if _elapsed >= MATCH_TIME_SECONDS:
		_end_match("time_limit")

func award(event_id: String, player: Node, context: Dictionary = {}) -> int:
	if _ended:
		return 0
	if player == null:
		return 0
	_register_source(event_id)
	var amount := int(context.get("points_override", POINTS.get(event_id, 0)))
	if amount <= 0:
		return 0
	var id := player.get_instance_id()
	var total := int(_player_points.get(id, 0)) + amount
	_player_points[id] = total
	var breakdown: Dictionary = _player_breakdown.get(id, {})
	breakdown[event_id] = int(breakdown.get(event_id, 0)) + amount
	_player_breakdown[id] = breakdown
	_history.append({
		"time": _elapsed,
		"event": event_id,
		"amount": amount,
		"player_id": id,
		"context": context
	})
	emit_signal("points_changed", player, total)
	if total >= MATCH_POINT_CAP:
		_end_match("point_cap")
	return amount

func get_player_points(player: Node) -> int:
	if player == null:
		return 0
	return int(_player_points.get(player.get_instance_id(), 0))

func get_player_breakdown(player: Node) -> Dictionary:
	if player == null:
		return {}
	return _player_breakdown.get(player.get_instance_id(), {}).duplicate(true)

func get_sources() -> Array:
	return _sources.duplicate()

func get_history() -> Array:
	return _history.duplicate(true)

func reset_match() -> void:
	_elapsed = 0.0
	_player_points.clear()
	_player_breakdown.clear()
	_sources.clear()
	_history.clear()
	_ended = false

func _register_source(event_id: String) -> void:
	if _sources.has(event_id):
		return
	_sources.append(event_id)

func _end_match(reason: String) -> void:
	if _ended:
		return
	_ended = true
	emit_signal("match_ended", reason)
