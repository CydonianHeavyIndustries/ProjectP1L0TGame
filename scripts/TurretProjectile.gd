extends Area3D

@export var speed := 9.0
@export var damage := 10.0
@export var lifetime := 3.5

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
	queue_free()
