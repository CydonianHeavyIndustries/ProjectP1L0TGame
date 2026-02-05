extends Control
signal play_pressed

@onready var play_button: Button = $VBox/Play
@onready var options_button: Button = $VBox/Options
@onready var exit_button: Button = $VBox/Exit

func _ready() -> void:
	play_button.pressed.connect(_on_play)
	options_button.pressed.connect(_on_options)
	exit_button.pressed.connect(_on_exit)

func _on_play() -> void:
	play_pressed.emit()

func _on_options() -> void:
	# Placeholder: hook options later
	pass

func _on_exit() -> void:
	get_tree().quit()
