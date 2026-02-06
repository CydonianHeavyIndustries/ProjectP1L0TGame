extends CanvasLayer

@export var max_lines := 12
@export var visible_on_start := true

@onready var log_label: RichTextLabel = $Panel/Margins/LogLabel

func _ready() -> void:
	visible = visible_on_start
	if Logger:
		Logger.log_added.connect(_on_log_added)
		_refresh()

func _on_log_added(_line: String) -> void:
	_refresh()

func _refresh() -> void:
	if not Logger:
		return
	var lines = Logger.get_recent_lines(max_lines)
	log_label.text = "\n".join(lines)
