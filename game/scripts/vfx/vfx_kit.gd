class_name VFXKit
extends RefCounted
## Piezas comunes de VFX originales para Mobile/Compatibility: materiales sin
## iluminación y opacos (salvo el escudo), sin luces dinámicas ni sombras.
## Los efectos se desvanecen escalando, no con transparencia.

# Paleta de efectos por identidad (coherente con docs/arte/HEROES.md).
const TURBO_SPARK := Color("fff3a0")
const TURBO_BOLT := Color("ffe14a")
const TURBO_BLUE := Color("2f6bff")
const TURBO_RED := Color("ff3b3b")
const REY_GOLD := Color("ffc94d")
const REY_AMBER := Color("ff9f2e")
const REY_VIOLET := Color("9b5cff")
const HIT_CORE := Color("fff8ec")
const HIT_EDGE := Color("ff8a3d")
const COVER := Color("ffb357")
const SHIELD := Color(0.75, 0.92, 1.0, 0.35)
const PRINCIPE_RED := Color("d92332")
const PRINCIPE_LIGHT := Color("ffe9e6")
const PRINCIPE_BLUE := Color("1a37a8")
const PRINCIPE_ZONE := Color("1b2b63")

static var _materials: Dictionary = {}
static var _overlays: Dictionary = {}
static var _meshes: Dictionary = {}

static func material(color: Color) -> StandardMaterial3D:
	if _materials.has(color):
		return _materials[color]
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = color
	if color.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.no_depth_test = false
	_materials[color] = m
	return m

static func overlay(color: Color) -> StandardMaterial3D:
	## Para destellos breves que deben leerse aunque los tape el cuerpo del héroe.
	if _overlays.has(color):
		return _overlays[color]
	var m := material(color).duplicate() as StandardMaterial3D
	m.no_depth_test = true
	m.render_priority = 1
	_overlays[color] = m
	return m

static func on_top(node: Node) -> void:
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mesh := child as MeshInstance3D
		var base := mesh.material_override as StandardMaterial3D
		if base != null:
			mesh.material_override = overlay(base.albedo_color)
	if node is MeshInstance3D:
		var own := (node as MeshInstance3D).material_override as StandardMaterial3D
		if own != null:
			(node as MeshInstance3D).material_override = overlay(own.albedo_color)

static func _node(parent: Node3D, mesh: Mesh, at: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material(color)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.position = at
	parent.add_child(node)
	return node

static func box(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var key := "box%s" % size
	if not _meshes.has(key):
		var shape := BoxMesh.new()
		shape.size = size
		_meshes[key] = shape
	return _node(parent, _meshes[key], at, color)

static func sphere(parent: Node3D, at: Vector3, radius: float, color: Color, segments := 12) -> MeshInstance3D:
	var key := "sph%.3f/%d" % [radius, segments]
	if not _meshes.has(key):
		var shape := SphereMesh.new()
		shape.radius = radius
		shape.height = radius * 2
		shape.radial_segments = segments
		shape.rings = maxi(4, segments / 2)
		_meshes[key] = shape
	return _node(parent, _meshes[key], at, color)

static func disk(parent: Node3D, at: Vector3, radius: float, color: Color, segments := 32) -> MeshInstance3D:
	## Disco plano opaco sobre el suelo (zonas de efecto, sin transparencia).
	var key := "disk%.3f/%d" % [radius, segments]
	if not _meshes.has(key):
		var shape := CylinderMesh.new()
		shape.top_radius = radius
		shape.bottom_radius = radius
		shape.height = 0.01
		shape.radial_segments = segments
		shape.rings = 1
		_meshes[key] = shape
	return _node(parent, _meshes[key], at, color)

static func ring(parent: Node3D, at: Vector3, radius: float, thickness: float, color: Color) -> MeshInstance3D:
	## Anillo plano sobre el suelo (eje Y).
	var key := "ring%.3f/%.3f" % [radius, thickness]
	if not _meshes.has(key):
		var shape := TorusMesh.new()
		shape.inner_radius = maxf(0.01, radius - thickness / 2)
		shape.outer_radius = radius + thickness / 2
		shape.rings = 36
		shape.ring_segments = 4
		_meshes[key] = shape
	return _node(parent, _meshes[key], at, color)

static func arc(parent: Node3D, at: Vector3, radius: float, degrees: float, width: float, height: float, color: Color) -> MeshInstance3D:
	## Arco centrado hacia -Z (frente del personaje). height > 0 lo levanta como muro.
	var key := "arc%.2f/%.0f/%.2f/%.2f" % [radius, degrees, width, height]
	if not _meshes.has(key):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var steps := 14
		for i in steps:
			var a0 := deg_to_rad(-degrees / 2 + degrees * i / steps)
			var a1 := deg_to_rad(-degrees / 2 + degrees * (i + 1) / steps)
			var taper0 := sin(PI * i / steps)
			var taper1 := sin(PI * (i + 1) / steps)
			var d0 := Vector3(sin(a0), 0, -cos(a0))
			var d1 := Vector3(sin(a1), 0, -cos(a1))
			var in0 := d0 * (radius - width * taper0 / 2)
			var out0 := d0 * (radius + width * taper0 / 2) + Vector3.UP * height * taper0
			var in1 := d1 * (radius - width * taper1 / 2)
			var out1 := d1 * (radius + width * taper1 / 2) + Vector3.UP * height * taper1
			for v in [in0, out0, out1, in0, out1, in1]:
				st.add_vertex(v)
		var mesh := st.commit()
		_meshes[key] = mesh
	var node := _node(parent, _meshes[key], at, color)
	node.material_override = _double_sided(color)
	return node

static func _double_sided(color: Color) -> StandardMaterial3D:
	var key := Color(color.r, color.g, color.b, color.a)
	var cache_key := "ds%s" % key
	if _materials.has(cache_key):
		return _materials[cache_key]
	var m := material(color).duplicate() as StandardMaterial3D
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_materials[cache_key] = m
	return m

static func bolt(parent: Node3D, from: Vector3, to: Vector3, segments: int, jitter: float, thickness: float, color: Color) -> Node3D:
	## Rayo en zigzag original hecho con prismas finos; regenerable para parpadeo.
	var holder := Node3D.new()
	parent.add_child(holder)
	var points: Array[Vector3] = [from]
	for i in range(1, segments):
		var p := from.lerp(to, float(i) / segments)
		points.append(p + Vector3(randf_range(-jitter, jitter), randf_range(-jitter, jitter) * 0.6, randf_range(-jitter, jitter)))
	points.append(to)
	for i in segments:
		var a := points[i]
		var b := points[i + 1]
		var length := a.distance_to(b)
		if length < 0.001:
			continue
		var dir := (b - a) / length
		var up := Vector3.UP if absf(dir.y) < 0.95 else Vector3.RIGHT
		var seg := box(holder, Vector3.ZERO, Vector3(thickness, thickness, 1.0), color)
		seg.transform = Transform3D(Basis.looking_at(dir, up) * Basis.from_scale(Vector3(1, 1, length)), (a + b) / 2)
	return holder

static func star(parent: Node3D, at: Vector3, size: float, thickness: float, color: Color) -> Node3D:
	## Destello de tres prismas cruzados.
	var holder := Node3D.new()
	holder.position = at
	parent.add_child(holder)
	for r in [Vector3(0, 0, 0), Vector3(0, 0, 60), Vector3(0, 0, -60)]:
		var spike := box(holder, Vector3.ZERO, Vector3(size, thickness, thickness), color)
		spike.rotation_degrees = r
	var flat := box(holder, Vector3.ZERO, Vector3(thickness, thickness, size * 0.7), color)
	flat.rotation_degrees.y = 45
	return holder

static func sparks(parent: Node3D, at: Vector3, amount: int, color: Color, speed: float, lifetime: float,
		direction := Vector3.UP, spread := 180.0, gravity := -6.0, size := 0.07) -> CPUParticles3D:
	## Chispas de una sola ráfaga (CPUParticles3D funciona igual en Mobile y Compatibility).
	var p := CPUParticles3D.new()
	p.position = at
	p.amount = maxi(1, amount)
	p.one_shot = true
	p.explosiveness = 1.0
	p.lifetime = lifetime
	p.direction = direction
	p.spread = spread
	p.initial_velocity_min = speed * 0.5
	p.initial_velocity_max = speed
	p.gravity = Vector3(0, gravity, 0)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.2
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0))
	p.scale_amount_curve = curve
	var key := "spark%.3f" % size
	if not _meshes.has(key):
		var shape := BoxMesh.new()
		shape.size = Vector3(size, size, size * 2.2)
		_meshes[key] = shape
	p.mesh = _meshes[key]
	p.material_override = material(color)
	p.particle_flag_align_y = true
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.emitting = true
	parent.add_child(p)
	return p

static func ease_out(t: float) -> float:
	return 1.0 - pow(1.0 - clampf(t, 0, 1), 3)

static func fade(t: float) -> float:
	## Se mantiene visible al inicio y cae al final del ciclo de vida.
	return maxf(0.001, 1.0 - pow(clampf(t, 0, 1), 2.5))
