extends Area3D

@export var speed := 18.0
@export var damage := 120.0
@export var lifetime := 3.0

var velocity := Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	if velocity != Vector3.ZERO:
		global_position += velocity * delta

func configure(direction: Vector3, speed_value: float, damage_value: float, life_value: float = -1.0) -> void:
	velocity = direction.normalized() * speed_value
	damage = damage_value
	if life_value > 0.0:
		lifetime = life_value

func _on_body_entered(body: Node) -> void:
	if body and body.has_method("take_damage"):
		body.take_damage(damage)
	_spawn_impact()
	queue_free()

func _spawn_impact() -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.25
	mesh.height = 0.5
	var fx := MeshInstance3D.new()
	fx.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 0.7, 0.2, 0.9)
	mat.emission = Color(1.0, 0.4, 0.1, 1.0)
	mat.emission_energy_multiplier = 1.8
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fx.material_override = mat
	fx.global_position = global_position
	if get_parent():
		get_parent().add_child(fx)
	var tween := fx.create_tween()
	tween.tween_property(fx, "scale", Vector3.ONE * 1.4, 0.12).from(Vector3.ONE * 0.6)
	tween.tween_property(fx, "scale", Vector3.ZERO, 0.12)
	tween.tween_callback(fx.queue_free)
