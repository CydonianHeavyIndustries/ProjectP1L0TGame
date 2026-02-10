extends RigidBody3D

@export var fuse_time := 2.0
@export var damage := 60.0
@export var radius := 4.0
@export var blast_visual_duration := 0.25
@export var blast_visual_color := Color(0.2, 0.9, 1.0, 0.25)

func _ready() -> void:
	var timer = get_tree().create_timer(fuse_time)
	timer.timeout.connect(_explode)

func _explode() -> void:
	_spawn_blast_visual()
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
			body.take_damage(damage)
	queue_free()

func _spawn_blast_visual() -> void:
	if blast_visual_duration <= 0.0:
		return
	var visual := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	visual.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = blast_visual_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	visual.material_override = mat
	visual.global_position = global_position
	var parent = get_parent()
	if parent:
		parent.add_child(visual)
	else:
		get_tree().current_scene.add_child(visual)
	var timer = get_tree().create_timer(blast_visual_duration)
	timer.timeout.connect(func(): visual.queue_free())
