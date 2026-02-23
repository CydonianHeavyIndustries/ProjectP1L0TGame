extends RigidBody3D

@export var fuse_time := 2.0
@export var damage := 60.0
@export var radius := 4.0

@onready var mesh: MeshInstance3D = $Mesh
var damage_owner: Node = null

func _ready() -> void:
	var timer = get_tree().create_timer(fuse_time)
	timer.timeout.connect(_explode)

func configure(owner_node: Node) -> void:
	damage_owner = owner_node

func _explode() -> void:
	var shape := SphereShape3D.new()
	shape.radius = radius
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = Transform3D(Basis(), global_position)
	params.collide_with_bodies = true
	params.exclude = [self]
	var results = get_world_3d().direct_space_state.intersect_shape(params)
	for hit in results:
		var body = hit.get("collider")
		if body and body.has_method("take_damage"):
			body.take_damage(damage, damage_owner)
	queue_free()
