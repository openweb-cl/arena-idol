class_name TargetSelector
extends RefCounted
## Selección por distancia al centro; no atraviesa cobertura ni amplía el alcance.
static func nearest(source: ArenaPlayer, candidates: Array[ArenaPlayer]) -> ArenaPlayer:
	if source.knocked_out or not source.active:
		return null
	var selected: ArenaPlayer
	var best := source.definition.attack_range * source.definition.attack_range + 0.00001
	for candidate in candidates:
		if not is_instance_valid(candidate) or candidate == source or candidate.team == source.team:
			continue
		if candidate.knocked_out or candidate.health <= 0 or not candidate.active:
			continue
		var offset := candidate.global_position - source.global_position
		offset.y = 0
		var distance := offset.length_squared()
		if distance > source.definition.attack_range * source.definition.attack_range or distance >= best:
			continue
		if not clear_path(source, candidate):
			continue
		selected = candidate
		best = distance
	return selected

static func clear_path(source: ArenaPlayer, target: ArenaPlayer) -> bool:
	var shape := SphereShape3D.new()
	shape.radius = 0.16 if source.definition.attack_type == "Ranged" else 0.05
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, CombatAim.origin(source))
	query.motion = CombatAim.origin(target) - CombatAim.origin(source)
	query.collision_mask = 1
	query.exclude = [source.get_rid()]
	var fractions := source.get_world_3d().direct_space_state.cast_motion(query)
	return fractions[0] >= 1.0
