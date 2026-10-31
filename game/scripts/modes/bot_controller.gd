class_name ArenaBot
extends RefCounted
## Persigue, usa alcance/cobertura y esquiva proyectiles de forma reactiva.
## Evalúa el tipo de habilidad y de súper; sale de zonas anunciadas que percibe.
var dodge_time := 0.0
var dodge_direction := Vector2.ZERO
var dodges := 0
var layout: ArenaDefinition

func update(actor: ArenaPlayer, rival: ArenaPlayer, projectiles: Array[CombatProjectile], delta: float, fields: Array = []) -> void:
	actor.command.clear_actions()
	actor.super_target = null
	if actor.knocked_out or rival.knocked_out:
		actor.command.move = Vector2.ZERO
		return
	var offset := rival.position - actor.position
	var flat := Vector2(offset.x, offset.z)
	actor.command.aim = flat.normalized()
	var desired_range := actor.definition.attack_range * (0.65 if actor.definition.attack_type == "Ranged" else 0.8)
	var move := flat.normalized() if flat.length() > desired_range else Vector2.ZERO
	if actor.definition.attack_type == "Ranged" and flat.length() < 4:
		move = -flat.normalized()
	if not line_clear(actor, rival):
		# Salir al pasillo central para bordear cobertura, sin teletransporte.
		move = route(actor.position, rival.position)
	else:
		actor.command.shoot = flat.length() < actor.definition.attack_range
		actor.command.super_shot = actor.super_charge >= 100 and flat.length() < actor.definition.super_radius + 1 if actor.definition.attack_type == "Melee" else actor.super_charge >= 100 and flat.length() < actor.definition.attack_range
		if actor.definition.super_kind == "Field" and actor.definition.super_reach <= 0.01:
			# Campo centrado en sí mismo: activarlo con el rival dentro del radio.
			actor.command.super_shot = actor.super_charge >= 100 and flat.length() <= actor.definition.super_radius
			if actor.command.super_shot:
				actor.super_target = Vector3(actor.position.x, 0, actor.position.z)
		elif actor.definition.super_kind == "Field":
			# Coloca el campo sobre el rival visible dentro del alcance de colocación.
			actor.command.super_shot = actor.super_charge >= 100 and flat.length() <= actor.definition.super_reach
			if actor.command.super_shot:
				actor.super_target = Vector3(rival.position.x, 0, rival.position.z)
		if actor.command.super_shot:
			actor.command.shoot = false
	# La línea de tiro puede estar libre y el cuerpo aún rozar una esquina.
	# En aproximación usar el radio de navegación, no el rayo del proyectil.
	if move.dot(flat) > 0 and not layout.clear_segment(Vector2(actor.position.x, actor.position.z), Vector2(rival.position.x, rival.position.z)):
		move = route(actor.position, rival.position)
	# Zonas anunciadas o activas del rival: salir por el lado opuesto al centro.
	var threatened := false
	var escaping := false
	for field in fields:
		if not is_instance_valid(field) or field.team == actor.team or field.finished():
			continue
		var away := Vector2(actor.position.x - field.position.x, actor.position.z - field.position.z)
		if away.length() < field.radius + 0.6:
			move = away.normalized() if away.length() > 0.05 else Vector2(-flat.y, flat.x).normalized()
			escaping = true
	if escaping:
		dodge_time = 0.0
	elif dodge_time > 0:
		dodge_time -= delta
		move = dodge_direction
	else:
		for projectile in projectiles:
			if not is_instance_valid(projectile) or projectile.is_queued_for_deletion() or projectile.source == actor:
				continue
			var to_actor := actor.position - projectile.position
			to_actor.y = 0
			if to_actor.length() < 5 and projectile.direction.dot(to_actor.normalized()) > 0.85:
				dodge_direction = Vector2(-projectile.direction.z, projectile.direction.x)
				if absf(actor.position.z + dodge_direction.y * 2) > 5.5:
					dodge_direction = -dodge_direction
				dodge_time = 0.35
				dodges += 1
				threatened = true
				move = dodge_direction
				break
	actor.command.move = move
	if actor.definition.ability != null and actor.definition.ability.kind == "Shield":
		# Escudo al recibir presión: proyectil en camino o rival encima; no prevé disparos futuros.
		actor.command.ability = threatened or flat.length() < 3.0
	elif actor.definition.ability != null and actor.definition.ability.kind == "Power":
		# Mejora de poder solo con munición y un blanco alcanzable a la vista.
		actor.command.ability = actor.command.shoot and actor.ammo.charges > 0
	else:
		actor.command.ability = (actor.definition.attack_type == "Melee" and flat.length() < 5 and flat.length() > 2) or (dodge_time > 0 and actor.definition.attack_type == "Ranged")

func line_clear(a: ArenaPlayer, b: ArenaPlayer) -> bool:
	return TargetSelector.clear_path(a, b)

var navigation: AStarGrid2D

func _init(settings: ArenaDefinition = null) -> void:
	layout = settings if settings != null else preload("res://data/maps/prisma_a.tres")
	navigation = AStarGrid2D.new()
	navigation.region = Rect2i(-12, -6, 25, 13)
	navigation.cell_size = Vector2.ONE
	navigation.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	navigation.update()
	for x in range(-12, 13):
		for z in range(-6, 7):
			for rect in layout.obstacles:
				if rect.grow(0.65).has_point(Vector2(x, z)):
					navigation.set_point_solid(Vector2i(x, z))

func walkable(point: Vector2i) -> Vector2i:
	for radius in range(4):
		for x in range(point.x - radius, point.x + radius + 1):
			for y in range(point.y - radius, point.y + radius + 1):
				var cell := Vector2i(x, y)
				if navigation.region.has_point(cell) and not navigation.is_point_solid(cell):
					return cell
	return Vector2i(-10, 0)

func route(from: Vector3, to: Vector3) -> Vector2:
	var start := walkable(Vector2i(roundi(from.x), roundi(from.z)))
	var target := walkable(Vector2i(roundi(to.x), roundi(to.z)))
	var path := navigation.get_id_path(start, target)
	if path.size() > 1:
		return (Vector2(path[1]) - Vector2(from.x, from.z)).normalized()
	return Vector2(to.x - from.x, to.z - from.z).normalized()
