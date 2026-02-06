extends Control

@onready var resume_button: Button = $Panel/VBox/ResumeButton
@onready var quit_button: Button = $Panel/VBox/QuitButton

var is_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle()
		get_viewport().set_input_as_handled()

func open() -> void:
	if is_open:
		return
	is_open = true
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close() -> void:
	if not is_open:
		return
	is_open = false
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func toggle() -> void:
	if is_open:
		close()
	else:
		open()

func _on_resume_pressed() -> void:
	close()

func _on_quit_pressed() -> void:
	get_tree().quit()
