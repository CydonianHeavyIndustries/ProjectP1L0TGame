extends Control

@onready var main_panel: Control = $Panel
@onready var loadout_panel: Control = $LoadoutPanel
@onready var resume_button: Button = $Panel/VBox/ResumeButton
@onready var loadout_button: Button = $Panel/VBox/LoadoutButton
@onready var quit_button: Button = $Panel/VBox/QuitButton
@onready var loadout_back_button: Button = $LoadoutPanel/LoadoutVBox/Header/BackButton
@onready var loadout_slots_grid: GridContainer = $LoadoutPanel/LoadoutVBox/LoadoutSlots
@onready var loadout_category_list: VBoxContainer = $LoadoutPanel/LoadoutVBox/Body/CategoryPanel/CategoryMargin/CategoryList
@onready var loadout_items_title: Label = $LoadoutPanel/LoadoutVBox/Body/ItemsPanel/ItemsMargin/ItemsVBox/ItemsTitle
@onready var loadout_items_grid: GridContainer = $LoadoutPanel/LoadoutVBox/Body/ItemsPanel/ItemsMargin/ItemsVBox/ItemsScroll/ItemsGrid
@onready var selected_item_label: Label = $LoadoutPanel/SelectedItemLabel
@onready var grenade_info_panel: Panel = $LoadoutPanel/GrenadeInfoPanel
@onready var grenade_info_title: Label = $LoadoutPanel/GrenadeInfoPanel/GrenadeInfoMargin/GrenadeInfoVBox/GrenadeInfoTitle
@onready var grenade_info_desc: Label = $LoadoutPanel/GrenadeInfoPanel/GrenadeInfoMargin/GrenadeInfoVBox/GrenadeInfoDesc
@onready var grenade_info_close: Button = $LoadoutPanel/GrenadeInfoPanel/GrenadeInfoMargin/GrenadeInfoVBox/GrenadeInfoClose
@onready var placeholder_buttons: Array[Button] = [
	$Panel/VBox/SettingsButton,
	$Panel/VBox/ControlsButton,
	$Panel/VBox/AudioButton,
	$Panel/VBox/GraphicsButton,
	$Panel/VBox/CreditsButton
]

const LOADOUT_SLOT_COUNT := 10
const LAST_SELECTED_KEY := "__last_selected__"
const LOADOUT_CATEGORIES := [
	"Primary Weapon",
	"Secondary Weapon",
	"Anti-Titan",
	"Grenade",
	"Boost",
	"Main Ability",
	"Enhancement 1",
	"Enhancement 2",
	"Enhancement 3",
	"Animations"
]

const ENHANCEMENT_POOL := ["Perk A", "Perk B", "Perk C", "Perk D", "Perk E", "Perk F", "Perk G", "Perk H", "Perk I"]

const LOADOUT_ITEMS := {
	"Primary Weapon": ["Rifle", "SMG", "LMG", "Shotgun", "Sniper"],
	"Secondary Weapon": ["Pistol", "Auto Pistol", "Revolver"],
	"Anti-Titan": ["Rocket", "Laser", "Mine", "Charge Shot"],
	"Grenade": ["Frag", "Arc", "Smoke", "Thermite"],
	"Boost": ["Amped Weapons", "Holo Pilot", "Ticks", "Battery Backup"],
	"Main Ability": ["Grapple", "Stim", "Cloak", "Phase"],
	"Animations": ["Default", "Alt 1", "Alt 2"]
}

const GRENADE_INFO := {
	"Frag": "Standard explosive grenade with a timed fuse.",
	"Arc": "Disables electronics and slows targets in a small radius.",
	"Smoke": "Creates a smoke screen for concealment.",
	"Thermite": "Burns an area over time with high damage."
}

var is_open := false
var loadout_slot_group := ButtonGroup.new()
var loadout_slot_buttons: Array[Button] = []
var loadout_category_group := ButtonGroup.new()
var loadout_category_buttons := {}
var current_loadout_category := ""
var current_loadout_slot := 0
var loadout_data: Array = []

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
	if loadout_button:
		loadout_button.pressed.connect(_on_loadout_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if loadout_back_button:
		loadout_back_button.pressed.connect(_show_main_panel)
	if grenade_info_close:
		grenade_info_close.pressed.connect(_hide_grenade_info)
	for button in placeholder_buttons:
		if button:
			button.pressed.connect(func(): _on_placeholder_pressed(button.text))
	_setup_loadout_menu()
	_show_main_panel()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_open and loadout_panel and loadout_panel.visible:
			_show_main_panel()
		else:
			toggle()
		get_viewport().set_input_as_handled()

func open() -> void:
	if is_open:
		return
	is_open = true
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_show_main_panel()

func close() -> void:
	if not is_open:
		return
	is_open = false
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_show_main_panel()

func toggle() -> void:
	if is_open:
		close()
	else:
		open()

func _on_resume_pressed() -> void:
	close()

func _on_loadout_pressed() -> void:
	_show_loadout_panel()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_placeholder_pressed(label: String) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("log_placeholder"):
		hud.log_placeholder(label)
	else:
		print("Not Implemented:", label)

func _show_main_panel() -> void:
	if main_panel:
		main_panel.visible = true
	if loadout_panel:
		loadout_panel.visible = false
	_hide_grenade_info()

func _show_loadout_panel() -> void:
	if main_panel:
		main_panel.visible = false
	if loadout_panel:
		loadout_panel.visible = true
	if current_loadout_category == "":
		_select_loadout_category(LOADOUT_CATEGORIES[0])

func _setup_loadout_menu() -> void:
	_init_loadout_data()
	_build_loadout_slots()
	_build_loadout_categories()
	if LOADOUT_CATEGORIES.size() > 0:
		_select_loadout_category(LOADOUT_CATEGORIES[0])
	_select_loadout_slot(0)

func _init_loadout_data() -> void:
	loadout_data.clear()
	for slot in range(LOADOUT_SLOT_COUNT):
		var data := {}
		for category in LOADOUT_CATEGORIES:
			data[category] = ""
		data[LAST_SELECTED_KEY] = ""
		loadout_data.append(data)

func _build_loadout_slots() -> void:
	if loadout_slots_grid == null:
		return
	loadout_slot_buttons.clear()
	var index := 0
	for child in loadout_slots_grid.get_children():
		if child is Button:
			var button := child as Button
			button.button_group = loadout_slot_group
			button.toggle_mode = true
			button.text = "Loadout %d" % (index + 1)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.pressed.connect(_on_loadout_slot_pressed.bind(index))
			loadout_slot_buttons.append(button)
			index += 1

func _build_loadout_categories() -> void:
	if loadout_category_list == null:
		return
	for child in loadout_category_list.get_children():
		child.queue_free()
	loadout_category_buttons.clear()
	for category in LOADOUT_CATEGORIES:
		var button := Button.new()
		button.text = category
		button.toggle_mode = true
		button.button_group = loadout_category_group
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_category_pressed.bind(category))
		loadout_category_list.add_child(button)
		loadout_category_buttons[category] = button
	_refresh_category_buttons()

func _on_category_pressed(category: String) -> void:
	_select_loadout_category(category)

func _select_loadout_category(category: String) -> void:
	current_loadout_category = category
	var button = loadout_category_buttons.get(category, null)
	if button:
		button.button_pressed = true
	if loadout_items_title:
		loadout_items_title.text = category
	_populate_loadout_items(category)
	_update_selected_item_label(_get_current_loadout().get(category, ""))
	if category != "Grenade":
		_hide_grenade_info()

func _populate_loadout_items(category: String) -> void:
	if loadout_items_grid == null:
		return
	for child in loadout_items_grid.get_children():
		child.queue_free()
	var items: Array = _get_items_for_category(category)
	for item in items:
		var button := Button.new()
		button.text = str(item)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_loadout_item_pressed.bind(category, str(item)))
		loadout_items_grid.add_child(button)

func _on_loadout_item_pressed(category: String, item: String) -> void:
	var data = _get_current_loadout()
	data[category] = item
	data[LAST_SELECTED_KEY] = item
	_update_category_button_text(category, item)
	_update_selected_item_label(item)
	if category == "Grenade":
		_show_grenade_info(item)
	_on_placeholder_pressed("Loadout: %s -> %s" % [category, item])

func _get_items_for_category(category: String) -> Array:
	if category.begins_with("Enhancement"):
		return ENHANCEMENT_POOL
	return LOADOUT_ITEMS.get(category, [])

func _get_current_loadout() -> Dictionary:
	if loadout_data.is_empty():
		return {}
	return loadout_data[current_loadout_slot]

func _on_loadout_slot_pressed(index: int) -> void:
	_select_loadout_slot(index)

func _select_loadout_slot(index: int) -> void:
	if loadout_data.is_empty():
		return
	current_loadout_slot = clamp(index, 0, loadout_data.size() - 1)
	if current_loadout_slot < loadout_slot_buttons.size():
		loadout_slot_buttons[current_loadout_slot].button_pressed = true
	_refresh_category_buttons()
	_update_selected_item_label(_get_current_loadout().get(LAST_SELECTED_KEY, ""))

func _refresh_category_buttons() -> void:
	var data = _get_current_loadout()
	for category in LOADOUT_CATEGORIES:
		_update_category_button_text(category, data.get(category, ""))

func _update_category_button_text(category: String, selection: String) -> void:
	var button = loadout_category_buttons.get(category, null)
	if button == null:
		return
	if selection == "":
		button.text = category
	else:
		button.text = "%s: %s" % [category, selection]

func _update_selected_item_label(text: String) -> void:
	if selected_item_label:
		selected_item_label.text = text

func _show_grenade_info(item: String) -> void:
	if grenade_info_panel == null:
		return
	grenade_info_panel.visible = true
	if grenade_info_title:
		grenade_info_title.text = "Grenade: %s" % item
	if grenade_info_desc:
		grenade_info_desc.text = GRENADE_INFO.get(item, "No information available yet.")

func _hide_grenade_info() -> void:
	if grenade_info_panel:
		grenade_info_panel.visible = false
