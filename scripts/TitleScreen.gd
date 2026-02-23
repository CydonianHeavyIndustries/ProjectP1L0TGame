extends Control
signal sandbox_pressed
signal tutorial_pressed

@onready var sandbox_button: Button = $VBox/Sandbox
@onready var tutorial_button: Button = $VBox/Tutorial
@onready var exit_button: Button = $VBox/Exit

func _ready() -> void:
	sandbox_button.pressed.connect(_on_sandbox)
	tutorial_button.pressed.connect(_on_tutorial)
	exit_button.pressed.connect(_on_exit)

func _on_sandbox() -> void:
	sandbox_pressed.emit()

func _on_tutorial() -> void:
	tutorial_pressed.emit()

func _on_exit() -> void:
	get_tree().quit()
