class_name CombatAim
extends RefCounted
## Ratón, origen del disparo y guía comparten altura. Sin autoapuntado por proximidad.
const HEIGHT := 0.85

static func origin(actor: ArenaPlayer) -> Vector3:
	return actor.global_position + Vector3.UP * HEIGHT

static func direction(from: Vector3, to: Vector3) -> Vector3:
	var flat := to - from
	flat.y = 0
	return flat.normalized()

static func point(camera: Camera3D, screen: Vector2, actor: ArenaPlayer) -> Variant:
	var ray_origin := camera.project_ray_origin(screen)
	var ray_direction := camera.project_ray_normal(screen)
	# Solo si el cursor atraviesa físicamente un actor: su centro de combate.
	# La trayectoria sigue chocando con cobertura; no se ensanchan los colliders.
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * camera.far, 2, [actor.get_rid()])
	var hit := actor.get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var target := hit.collider as ArenaPlayer
		if target != null and not target.knocked_out:
			var center := origin(target)
			center.y = origin(actor).y
			return center
	return Plane(Vector3.UP, origin(actor).y).intersects_ray(ray_origin, ray_direction)
