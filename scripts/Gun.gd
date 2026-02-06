extends Node3D

@export var mag_eject_offset := Vector3(0.22, -0.38, 0.12)
@export var mag_eject_rotation := Vector3(-0.6, 0.0, -0.4)
@export var mag_anim_time := 0.28

@onready var mag: Node3D = $Mag

var _mag_home := Vector3.ZERO
var _mag_home_rot := Vector3.ZERO
var _reload_tween: Tween

func _ready() -> void:
	if mag:
		_mag_home = mag.position
		_mag_home_rot = mag.rotation

func start_reload(total_time: float) -> void:
	if mag == null:
		return
	if _reload_tween:
		_reload_tween.kill()
	_reload_tween = create_tween()
	var out_time: float = min(mag_anim_time, total_time * 0.25)
	var back_time: float = out_time
	var hold_time: float = max(0.0, total_time - out_time - back_time)
	_reload_tween.tween_property(mag, "position", _mag_home + mag_eject_offset, out_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_reload_tween.parallel().tween_property(mag, "rotation", _mag_home_rot + mag_eject_rotation, out_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if hold_time > 0.0:
		_reload_tween.tween_interval(hold_time)
	_reload_tween.tween_property(mag, "position", _mag_home, back_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_reload_tween.parallel().tween_property(mag, "rotation", _mag_home_rot, back_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
