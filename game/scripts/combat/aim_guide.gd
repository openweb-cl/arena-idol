class_name AimGuide
extends Node3D
## Representación del mismo segmento barrido por el proyectil, sin autoridad de daño.
var line: MeshInstance3D
var endpoint: MeshInstance3D
var range_ring: MeshInstance3D
var line_material: StandardMaterial3D

func _ready() -> void:
	line = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.035, 0.035, 1)
	line.mesh = box
	line_material = StandardMaterial3D.new()
	line_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	line.material_override = line_material
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(line)
	endpoint = ArenaGeometry.sphere(self, Vector3.ZERO, 0.09, ArenaStyle.GOLD)
	range_ring = ArenaGeometry.ring(self, 1, ArenaStyle.GOLD)

func update_guide(actor: ArenaPlayer, direction: Vector3) -> void:
	var start := CombatAim.origin(actor)
	var distance := actor.definition.attack_range
	var is_ranged := actor.definition.attack_type == "Ranged"
	var radius := 0.16 if is_ranged else 0.05
	# La guía usa la misma esfera del ataque básico, no un rayo que ignora bordes.
	var shape := SphereShape3D.new()
	shape.radius = radius
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, start)
	query.motion = direction * distance
	query.collision_mask = 1 | 2
	query.exclude = [actor.get_rid()]
	var fractions := actor.get_world_3d().direct_space_state.cast_motion(query)
	var reachable := distance * fractions[0]
	var end := start + direction * reachable
	line.global_position = (start + end) / 2
	line.scale = Vector3(1, 1, maxf(0.01, reachable))
	if reachable > 0.001:
		line.look_at(end)
	line_material.albedo_color = Color("ffae68") if fractions[0] < 1 else ArenaStyle.GOLD
	endpoint.global_position = end
	range_ring.global_position = actor.global_position + Vector3.UP * 0.035
	var torus := range_ring.mesh as TorusMesh
	torus.inner_radius = distance - 0.025
	torus.outer_radius = distance + 0.025
