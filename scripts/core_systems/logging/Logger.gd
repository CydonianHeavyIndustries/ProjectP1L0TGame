extends Node

signal log_added(line: String)

const LOG_DIR := "user://logs"
const LOG_PATH := "user://logs/latest.log"
const MAX_LINES := 200

var _lines: Array[String] = []
var _file: FileAccess

func _ready() -> void:
	_open_log_file()
	info("Logger started.")

func _open_log_file() -> void:
	var absolute_dir = ProjectSettings.globalize_path(LOG_DIR)
	DirAccess.make_dir_recursive_absolute(absolute_dir)
	_file = FileAccess.open(LOG_PATH, FileAccess.WRITE)

func get_recent_lines(count: int) -> Array[String]:
	var out: Array[String] = []
	var start = maxi(_lines.size() - count, 0)
	for i in range(start, _lines.size()):
		out.append(_lines[i])
	return out

func info(message: String) -> void:
	_append("INFO", message)

func warn(message: String) -> void:
	_append("WARN", message)

func error(message: String) -> void:
	_append("ERROR", message)

func debug(message: String) -> void:
	_append("DEBUG", message)

func _append(level: String, message: String) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	var line = "%s [%s] %s" % [timestamp, level, message]
	_lines.append(line)
	if _lines.size() > MAX_LINES:
		_lines.pop_front()

	if _file:
		_file.store_line(line)
		_file.flush()

	match level:
		"ERROR":
			push_error(line)
		"WARN":
			push_warning(line)
		_:
			print(line)

	emit_signal("log_added", line)
