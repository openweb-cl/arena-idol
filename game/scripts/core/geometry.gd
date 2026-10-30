class_name ArenaGeometry
extends RefCounted
## Geometría de entrenamiento temporal. Sustituible por escenas de arte.
static var materials: Dictionary = {}

static func material(color: Color) -> StandardMaterial3D:
	if materials.has(color):
		return materials[color]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.82
	materials[color] = m
	return m

static func mesh(parent: Node3D, shape: Mesh, at: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = shape
	node.material_override = material(color)
	node.position = at
	parent.add_child(node)
	return node

static func box(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	return mesh(parent, shape, at, color)

static func sphere(parent: Node3D, at: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = radius
	shape.height = radius * 2
	shape.radial_segments = 16
	shape.rings = 8
	return mesh(parent, shape, at, color)

static func ring(parent: Node3D, radius: float, color: Color) -> MeshInstance3D:
	var shape := TorusMesh.new()
	shape.inner_radius = radius - 0.035
	shape.outer_radius = radius + 0.035
	shape.rings = 32
	shape.ring_segments = 6
	return mesh(parent, shape, Vector3(0, 0.035, 0), color)

static func world(parent: Node3D) -> DirectionalLight3D:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("101a33")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("a3c9df")
	env.environment.ambient_light_energy = 0.65
	env.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	parent.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -28, 0)
	sun.light_color = Color("fff0cf")
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	parent.add_child(sun)
	return sun
