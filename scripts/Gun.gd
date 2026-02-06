extends Node3D

@export var mag_eject_offset := Vector3(0.22, -0.38, 0.12)
@export var mag_eject_rotation := Vector3(-0.6, 0.0, -0.4)
@export var mag_anim_time := 0.28
@export var recoil_kick := Vector3(0.0, 0.0, 0.06)
@export var recoil_rot := Vector3(-0.04, 0.0, 0.0)
@export var recoil_time := 0.06
@export var melee_offset := Vector3(0.08, -0.04, -0.1)
@export var melee_rot := Vector3(-0.25, 0.1, 0.0)
@export var melee_time := 0.12

@onready var mag: Node3D = $Mag

var _mag_home := Vector3.ZERO
var _mag_home_rot := Vector3.ZERO
var _reload_tween: Tween
var _recoil_tween: Tween
var _melee_tween: Tween
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

func kick(_strength: float) -> void:
	if _recoil_tween:
		_recoil_tween.kill()
	_recoil_tween = create_tween()
	var start_pos = position
	var start_rot = rotation
	var kick_pos = start_pos + recoil_kick
	var kick_rot = start_rot + recoil_rot
	_recoil_tween.tween_property(self, "position", kick_pos, recoil_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_recoil_tween.parallel().tween_property(self, "rotation", kick_rot, recoil_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_recoil_tween.tween_property(self, "position", start_pos, recoil_time * 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_recoil_tween.parallel().tween_property(self, "rotation", start_rot, recoil_time * 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func start_melee() -> void:
	if _melee_tween:
		_melee_tween.kill()
	_melee_tween = create_tween()
	var start_pos = position
	var start_rot = rotation
	var hit_pos = start_pos + melee_offset
	var hit_rot = start_rot + melee_rot
	_melee_tween.tween_property(self, "position", hit_pos, melee_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_melee_tween.parallel().tween_property(self, "rotation", hit_rot, melee_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_melee_tween.tween_property(self, "position", start_pos, melee_time * 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_melee_tween.parallel().tween_property(self, "rotation", start_rot, melee_time * 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
