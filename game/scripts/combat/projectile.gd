class_name CombatProjectile
extends CharacterBody3D
signal hit(target: ArenaPlayer, source: ArenaPlayer, damage: int, push: Vector3)
signal resolved(projectile: CombatProjectile, reason: String, at: Vector3)
var source: ArenaPlayer
var damage := 850
var direction := Vector3.RIGHT
var speed := 19.0
var max_distance := 13.0
var travelled := 0.0
var power := false
var enabled := true
var age := 0.0
var lifetime := 0.0
var done := false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 | 2
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	add_collision_exception_with(source)
	direction.y = 0
	direction = direction.normalized()
	lifetime = max_distance / maxf(speed, 0.001) + 0.25
	var collider := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.32 if power else 0.16
	collider.shape = sphere
	add_child(collider)
	# Aspecto delegado a VFX (Claude Code); collider y movimiento siguen aquí.
	var visual := ProjectileVisual.new()
	visual.power = power
	add_child(visual)
	if not direction.is_zero_approx():
		look_at(global_position + direction)

func finish(reason: String) -> void:
	if done:
		return
	done = true
	resolved.emit(self, reason, global_position)
	queue_free()

func _physics_process(delta: float) -> void:
	if not enabled or done:
		return
	age += delta
	if direction.is_zero_approx() or speed <= 0:
		finish("configuración inválida")
		return
	var remaining := maxf(0, max_distance - travelled)
	if remaining <= 0.0001:
		finish("alcance")
		return
	var before := global_position
	# Barrido continuo, sin avanzar nunca más allá del alcance configurado.
	var collision := move_and_collide(direction * minf(speed * delta, remaining))
	travelled += before.distance_to(global_position)
	if collision:
		var actor := collision.get_collider() as ArenaPlayer
		if actor != null and actor.team != source.team:
			var health_before := actor.health
			hit.emit(actor, source, damage, direction * source.definition.attack_push * (2 if power else 1))
			finish("impacto" if actor.health < health_before else "protegido")
		else:
			finish("aliado" if actor != null else "cobertura")
	elif travelled >= max_distance - 0.0001:
		finish("alcance")
	elif age >= lifetime:
		finish("tiempo")
