extends Control

@onready var resume_button: Button = $Panel/VBox/ResumeButton
@onready var quit_button: Button = $Panel/VBox/QuitButton
@onready var placeholder_buttons: Array[Button] = [
	$Panel/VBox/SettingsButton,
	$Panel/VBox/ControlsButton,
	$Panel/VBox/AudioButton,
	$Panel/VBox/GraphicsButton,
	$Panel/VBox/CreditsButton
]

var is_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	set_process_unhandled_input(true)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	visible = false
	add_to_group("pause_menu")
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	for button in placeholder_buttons:
		if button:
			button.pressed.connect(func(): _on_placeholder_pressed(button.text))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
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

func _on_placeholder_pressed(label: String) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("log_placeholder"):
		hud.log_placeholder(label)
	else:
		print("Not Implemented:", label)
