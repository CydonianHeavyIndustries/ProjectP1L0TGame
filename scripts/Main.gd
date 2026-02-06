extends Node

@onready var title_scene: PackedScene = preload("res://scenes/TitleScreen.tscn")
@onready var gameplay_scene: PackedScene = preload("res://scenes/Gameplay.tscn")

var current_scene: Node

func _ready() -> void:
	_show_gameplay()

func _show_title() -> void:
	_clear_current()
	current_scene = title_scene.instantiate()
	add_child(current_scene)
	current_scene.play_pressed.connect(_show_gameplay)

func _show_gameplay() -> void:
	_clear_current()
	current_scene = gameplay_scene.instantiate()
	add_child(current_scene)

func _clear_current() -> void:
	if current_scene:
		current_scene.queue_free()
		current_scene = null
