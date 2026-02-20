extends Control

var is_open := false
var resume_button: Button
var quit_button: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_unhandled_input(true)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	add_to_group("pause_menu")

	resume_button = get_node_or_null("Panel/VBox/ResumeButton")
	quit_button = get_node_or_null("Panel/VBox/QuitButton")

	if resume_button == null or quit_button == null:
		_build_fallback_ui()
		resume_button = get_node_or_null("Panel/VBox/ResumeButton")
		quit_button = get_node_or_null("Panel/VBox/QuitButton")

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

func _build_fallback_ui() -> void:
	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.color = Color(0.0, 0.0, 0.0, 0.55)
	add_child(dim)

	var panel := Panel.new()
	panel.name = "Panel"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -190
	panel.offset_top = -130
	panel.offset_right = 190
	panel.offset_bottom = 130
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 16
	vbox.offset_top = 16
	vbox.offset_right = -16
	vbox.offset_bottom = -16
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)

	resume_button = Button.new()
	resume_button.name = "ResumeButton"
	resume_button.text = "Resume"
	vbox.add_child(resume_button)

	quit_button = Button.new()
	quit_button.name = "QuitButton"
	quit_button.text = "Quit to Desktop"
	vbox.add_child(quit_button)
