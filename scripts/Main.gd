extends Node

@onready var title_scene: PackedScene = preload("res://scenes/TitleScreen.tscn")
@onready var gameplay_scene: PackedScene = preload("res://scenes/Gameplay.tscn")
@onready var tutorial_scene: PackedScene = preload("res://scenes/Tutorial.tscn")

var current_scene: Node

func _ready() -> void:
	if DebugConfig.BOOT_TO_GAMEPLAY:
		_show_gameplay()
	else:
		_show_title()

func _show_title():
	_clear_current()
	current_scene = title_scene.instantiate()
	add_child(current_scene)
	current_scene.sandbox_pressed.connect(_show_gameplay)
	current_scene.tutorial_pressed.connect(_show_tutorial)

func _show_gameplay() -> void:
	_clear_current()
	current_scene = gameplay_scene.instantiate()
	add_child(current_scene)

func _show_tutorial() -> void:
	_clear_current()
	current_scene = tutorial_scene.instantiate()
	add_child(current_scene)

func _clear_current() -> void:
	if current_scene:
		current_scene.queue_free()
		current_scene = null
