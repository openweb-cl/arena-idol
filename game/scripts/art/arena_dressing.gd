class_name ArenaDressing
extends Node3D
## Vestido visual de la arena «Prisma» (V2, provisional; no es arte final).
## Solo presentación: los colliders, Rect2, apariciones y navegación siguen en
## ArenaPitch/ArenaDefinition. Toda cobertura se dibuja exactamente sobre su Rect2.
## Rendimiento: la geometría se agrupa en tres mallas con color por vértice
## (suelo, estructura y líneas de luz) y el público usa MultiMesh.
var definition: ArenaDefinition
var quality := true
var _surfaces: Dictionary = {}
var _unit_box := BoxMesh.new()
var _rng := RandomNumberGenerator.new()

const HW := ArenaDefinition.HALF_WIDTH
const HD := ArenaDefinition.HALF_DEPTH
const APRON := Color("12233a")
const JADE_A := Color("2c6f5f")
const JADE_B := Color("286756")
const JADE_LINE := Color("3f8f78")
const JADE_DARK := Color("225a4b")
const INK := Color("22385a")
const INK_DARK := Color("16263e")
const INK_CAP := Color("2f4d78")
const MINT := Color("6fffd8")
const AMBER := Color("f0b04a")
const CORAL := Color("ff8a5c")
const TEAM_BLUE := Color("3f8cff")
const CROWD := [Color("1f3fbf"), Color("e0262f"), Color("f1f3f7"), Color("18181c"), Color("5ec8f2"), Color("ddaf52"), Color("2e9e6a")]
const SKIN := [Color("f1c7a3"), Color("d9a07c"), Color("b9805c"), Color("8a5a3c"), Color("5e3b26")]

func _ready() -> void:
	quality = not GraphicsSettings.low
	_rng.seed = 2310 + definition.obstacles.size()
	_floor()
	_perimeter()
	for index in definition.obstacles.size():
		_cover(definition.obstacles[index])
	_spawn_pad(definition.player_spawn, TEAM_BLUE)
	_spawn_pad(definition.bot_spawn, CORAL)
	_stands()
	_light_towers()
	_commit("floor", false, false)
	_commit("solid", false, true)
	_commit("glow", true, false)

# --- Lotes de geometría ------------------------------------------------------
func _st(batch: String) -> SurfaceTool:
	if not _surfaces.has(batch):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		_surfaces[batch] = st
	return _surfaces[batch]

func add_mesh(batch: String, mesh: PrimitiveMesh, xform: Transform3D, color: Color) -> void:
	var arrays := mesh.get_mesh_arrays()
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var normal_basis := xform.basis.inverse().transposed()
	var st := _st(batch)
	for i in indices:
		st.set_color(color)
		st.set_normal((normal_basis * normals[i]).normalized())
		st.add_vertex(xform * verts[i])

func box(batch: String, center: Vector3, size: Vector3, color: Color, yaw := 0.0) -> void:
	var basis := Basis(Vector3.UP, yaw) * Basis.from_scale(size)
	add_mesh(batch, _unit_box, Transform3D(basis, center), color)

func hexagon(batch: String, center: Vector3, radius: float, height: float, color: Color) -> void:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	cylinder.radial_segments = 6
	cylinder.rings = 1
	add_mesh(batch, cylinder, Transform3D(Basis(Vector3.UP, PI / 6), center), color)

func hex_ring(batch: String, center: Vector3, radius: float, width: float, color: Color) -> void:
	for i in 6:
		var a0 := TAU * i / 6.0
		var a1 := TAU * (i + 1) / 6.0
		var p0 := Vector3(cos(a0), 0, sin(a0)) * radius
		var p1 := Vector3(cos(a1), 0, sin(a1)) * radius
		var mid := (p0 + p1) / 2
		box(batch, center + mid, Vector3(p0.distance_to(p1) + width, 0.012, width), color, -atan2(p1.z - p0.z, p1.x - p0.x))

func _commit(batch: String, unshaded: bool, shadows: bool) -> void:
	if not _surfaces.has(batch):
		return
	var instance := MeshInstance3D.new()
	instance.name = "Arena_" + batch
	instance.mesh = (_surfaces[batch] as SurfaceTool).commit()
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.roughness = 0.85
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows and quality else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)

# --- Piezas ------------------------------------------------------------------
func _floor() -> void:
	box("floor", Vector3(0, -0.5, 0), Vector3(31, 0.8, 21), APRON)
	for i in 13:
		box("floor", Vector3(-12 + i * 2, -0.04, 0), Vector3(2, 0.08, 14), JADE_B if i % 2 else JADE_A)
	# Borde menta de la cancha y línea media discontinua.
	for z in [-HD + 0.05, HD - 0.05]:
		box("glow", Vector3(0, 0.006, z), Vector3(HW * 2, 0.012, 0.08), MINT)
	for x in [-HW + 0.05, HW - 0.05]:
		box("glow", Vector3(x, 0.006, 0), Vector3(0.08, 0.012, HD * 2), MINT)
	for i in 7:
		box("floor", Vector3(0, 0.004, -6 + i * 2), Vector3(0.1, 0.012, 0.9), JADE_LINE)
	# Emblema «Prisma» central original: hexágono con anillo.
	hexagon("floor", Vector3(0, 0.003, 0), 2.0, 0.012, Color("327a67"))
	hex_ring("floor", Vector3(0, 0.008, 0), 2.35, 0.1, JADE_LINE)
	# Chevrones de avance hacia el centro en cada mitad.
	for side in [-1, 1]:
		for k in 3:
			var x: float = side * (7.6 - k * 0.7)
			for s in [-1, 1]:
				box("floor", Vector3(x, 0.004, s * 0.32), Vector3(0.12, 0.012, 0.8), JADE_DARK, side * s * deg_to_rad(40))

func _perimeter() -> void:
	# Mismas medidas que los colliders de ArenaPitch; los remates crecen hacia afuera.
	for side in [-1, 1]:
		var z: float = side * 7.2
		box("solid", Vector3(0, 0.6, z), Vector3(26.8, 1.2, 0.4), INK)
		box("solid", Vector3(0, 1.26, z + side * 0.05), Vector3(27.0, 0.12, 0.5), INK_CAP)
		box("glow", Vector3(0, 1.0, z - side * 0.2), Vector3(26.4, 0.06, 0.02), MINT)
		for i in 14:
			box("solid", Vector3(-13 + i * 2, 0.5, z - side * 0.195), Vector3(0.12, 0.9, 0.03), INK_DARK)
	for side in [-1, 1]:
		var x: float = side * 13.2
		box("solid", Vector3(x, 0.6, 0), Vector3(0.4, 1.2, 14.4), INK)
		box("solid", Vector3(x + side * 0.05, 1.26, 0), Vector3(0.5, 0.12, 14.6), INK_CAP)
		box("glow", Vector3(x - side * 0.2, 1.0, 0), Vector3(0.02, 0.06, 14.0), MINT)
		for i in 7:
			box("solid", Vector3(x - side * 0.195, 0.5, -6 + i * 2), Vector3(0.03, 0.9, 0.12), INK_DARK)
	# Cantoneras ámbar al ras de la cara interior de los muros (sin invadir la cancha).
	for x in [-13.31, 13.31]:
		for z in [-7.31, 7.31]:
			box("solid", Vector3(x, 0.75, z), Vector3(0.62, 1.5, 0.62), AMBER)

func _cover(rect: Rect2) -> void:
	## Bloque prisma: cuerpo exacto al Rect2 (altura 1,5 como el collider), base,
	## franja media, cantoneras ámbar y remate con líneas de luz.
	var c := rect.get_center()
	var w := rect.size.x
	var d := rect.size.y
	var body := definition.wall_color
	box("solid", Vector3(c.x, 0.75, c.y), Vector3(w, 1.5, d), body)
	box("solid", Vector3(c.x, 0.07, c.y), Vector3(w, 0.14, d), INK_DARK)
	box("solid", Vector3(c.x, 1.54, c.y), Vector3(w - 0.12, 0.08, d - 0.12), body.lightened(0.28))
	for axis in [0, 1]:
		for s in [-1, 1]:
			var face := Vector3(c.x + (s * (w / 2 + 0.005) if axis == 0 else 0.0), 0.75, c.y + (s * (d / 2 + 0.005) if axis == 1 else 0.0))
			var band := Vector3(0.012, 0.22, d - 0.3) if axis == 0 else Vector3(w - 0.3, 0.22, 0.012)
			box("solid", face, band, body.darkened(0.25))
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			box("solid", Vector3(c.x + sx * (w / 2 - 0.05), 0.72, c.y + sz * (d / 2 - 0.05)), Vector3(0.1, 1.3, 0.1), AMBER)
	for s in [-1, 1]:
		box("glow", Vector3(c.x, 1.515, c.y + s * (d / 2 - 0.04)), Vector3(w - 0.08, 0.03, 0.04), MINT)
		box("glow", Vector3(c.x + s * (w / 2 - 0.04), 1.515, c.y), Vector3(0.04, 0.03, d - 0.08), MINT)

func _spawn_pad(at: Vector3, team: Color) -> void:
	hexagon("floor", Vector3(at.x, 0.008, at.z), 1.25, 0.014, team.darkened(0.55))
	hex_ring("glow", Vector3(at.x, 0.012, at.z), 1.25, 0.07, team)
	var toward := -signf(at.x) if absf(at.x) > 0.01 else 1.0
	for s in [-1, 1]:
		box("glow", Vector3(at.x + toward * 0.15, 0.014, at.z + s * 0.22), Vector3(0.08, 0.012, 0.55), team, toward * s * deg_to_rad(-40))

func _stands() -> void:
	var fans: Array[Transform3D] = []
	var fan_colors: Array[Color] = []
	var heads: Array[Transform3D] = []
	var head_colors: Array[Color] = []
	for side in [-1, 1]:
		for row in 3:
			var z: float = side * (8.25 + row * 0.8)
			var h := 0.45 + row * 0.5
			box("solid", Vector3(0, h / 2, z), Vector3(27, h, 0.8), Color("1b2a47"))
			box("glow", Vector3(0, h + 0.01, z - side * 0.38), Vector3(27, 0.03, 0.04), MINT if row == 0 else Color("3d6f9a"))
			if not quality and row > 0:
				continue
			for seat in 34:
				if _rng.randf() < 0.14:
					continue
				var x := -12.4 + seat * 0.75 + _rng.randf_range(-0.08, 0.08)
				var scale := _rng.randf_range(0.9, 1.12)
				var basis := Basis(Vector3.UP, (0.0 if side > 0 else PI) + _rng.randf_range(-0.3, 0.3)).scaled(Vector3.ONE * scale)
				fans.append(Transform3D(basis, Vector3(x, h + 0.25 * scale, z + side * 0.1)))
				fan_colors.append(CROWD[_rng.randi() % CROWD.size()])
				heads.append(Transform3D(Basis.from_scale(Vector3.ONE * scale), Vector3(x, h + 0.62 * scale, z + side * 0.1)))
				head_colors.append(SKIN[_rng.randi() % SKIN.size()])
		# Muro trasero con pancartas abstractas originales (sin textos ni escudos).
		var back_z: float = side * 10.75
		box("solid", Vector3(0, 1.8, back_z), Vector3(28, 3.6, 0.3), Color("131f36"))
		var banners := [TEAM_BLUE, CORAL, AMBER, MINT, Color("9b5cff"), TEAM_BLUE, CORAL]
		for i in banners.size():
			box("glow", Vector3(-11 + i * 3.67, 2.6, back_z - side * 0.16), Vector3(2.4, 0.7, 0.02), (banners[i] as Color).darkened(0.15))
	var torso := BoxMesh.new()
	torso.size = Vector3(0.42, 0.5, 0.28)
	var head := SphereMesh.new()
	head.radius = 0.15
	head.height = 0.3
	head.radial_segments = 8
	head.rings = 4
	_crowd("Publico_cuerpos", torso, fans, fan_colors)
	_crowd("Publico_cabezas", head, heads, head_colors)

func _crowd(node_name: String, mesh: Mesh, transforms: Array[Transform3D], colors: Array[Color]) -> void:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for i in transforms.size():
		multimesh.set_instance_transform(i, transforms[i])
		multimesh.set_instance_color(i, colors[i])
	var instance := MultiMeshInstance3D.new()
	instance.name = node_name
	instance.multimesh = multimesh
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.roughness = 0.9
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)

func _light_towers() -> void:
	## Torres de luz decorativas (sin luces dinámicas).
	for x in [-15.0, 15.0]:
		for z in [-10.2, 10.2]:
			box("solid", Vector3(x, 2.6, z), Vector3(0.3, 5.2, 0.3), Color("2a3a58"))
			box("solid", Vector3(x, 5.3, z), Vector3(1.8, 0.9, 0.25), Color("2a3a58"), 0.0)
			box("glow", Vector3(x, 5.3, z - signf(z) * 0.14), Vector3(1.6, 0.7, 0.02), Color("fff4c8"))
