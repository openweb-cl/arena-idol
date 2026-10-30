extends SceneTree
## Regresión: apuntar al torso y a las cuatro direcciones, sin alterar balance.
var passed := 0
var failed := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, title: String) -> void:
	if ok:
		passed += 1
		print("PASS ", title)
	else:
		failed += 1
		push_error("FAIL " + title)

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func place(arena: IdolArena, from: Vector3, to: Vector3) -> void:
	for p in arena.projectiles:
		if is_instance_valid(p): p.queue_free()
	arena.projectiles.clear()
	arena.human.spawn_point = from
	arena.bot.spawn_point = to
	arena.human.reset_at_spawn()
	arena.bot.reset_at_spawn()
	arena.human.invulnerable = 0
	arena.bot.invulnerable = 0
	arena.shot_events.clear()
	await frames(3)

func click_at(arena: IdolArena, world: Vector3) -> void:
	var event := InputEventMouseButton.new()
	event.position = arena.camera.unproject_position(world)
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event, true)
	await frames(1)
	event.pressed = false
	root.push_input(event, true)
	await frames(60)

func last_reason(arena: IdolArena) -> String:
	return arena.shot_events.back().reason if not arena.shot_events.is_empty() else "sin resultado"

func run() -> void:
	var arena: IdolArena = load("res://scenes/training/projectile_range.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	await frames(3)
	check(arena.training_mode and arena.human.definition.number == 11 and arena.bot.definition.number == 23, "campo de tiro Turbo contra Rey")
	check(arena.show_aim_guide, "campo de tiro abre con guía opcional visible")
	var f2 := InputEventKey.new()
	f2.physical_keycode = KEY_F2
	f2.pressed = true
	root.push_input(f2, true)
	check(not arena.show_aim_guide, "F2 oculta línea e indicador de alcance")
	root.push_input(f2, true)
	check(arena.show_aim_guide, "F2 restaura guía")
	# Los tres ejercicios no usan estadísticas especiales ni autoimpactos.
	for case in range(5):
		arena.set_training_case(case)
		await frames(3)
		var spawn := arena.bot.position
		var health := arena.bot.health
		await click_at(arena, arena.bot.global_position + Vector3.UP)
		check(arena.bot.position.is_equal_approx(spawn) and arena.human.health == 4000, "ejercicio %d: Rey inmóvil y sin ataques" % (case + 1))
		if case < 3:
			check(arena.bot.health == health - 850 and last_reason(arena) == "impacto", "ejercicio %d: impacto al torso con daño original" % (case + 1))
		elif case == 3:
			check(arena.bot.health == health and last_reason(arena) == "cobertura", "cobertura registra bloqueo, no daño")
		else:
			check(arena.bot.health == health and last_reason(arena) == "alcance", "fuera de alcance registra expiración, no daño")
		check(absf(arena.shot_events.back().at.y - CombatAim.HEIGHT) < 0.001, "ejercicio %d: proyectil permanece en plano de combate" % (case + 1))
		check(arena.shot_events.back().distance <= 13.0001, "ejercicio %d: alcance nunca excede 13 m" % (case + 1))
	# Extremos, eje Z y diagonales en pasillos libres de la arena real.
	var lanes := [
		[Vector3(-10, 0, -2), Vector3(2, 0, -2)],
		[Vector3(10, 0, 2), Vector3(-2, 0, 2)],
		[Vector3(-9, 0, 5), Vector3(-9, 0, -5)],
		[Vector3(9, 0, -5), Vector3(9, 0, 5)],
		[Vector3(-11, 0, -6), Vector3(-8, 0, -3)],
		[Vector3(11, 0, -6), Vector3(8, 0, -3)],
		[Vector3(-11, 0, 6), Vector3(-8, 0, 3)],
		[Vector3(11, 0, 6), Vector3(8, 0, 3)],
	]
	for index in lanes.size():
		await place(arena, lanes[index][0], lanes[index][1])
		await click_at(arena, arena.bot.global_position + Vector3.UP)
		check(arena.bot.health == 6200 - 850 and last_reason(arena) == "impacto", "dirección %d: cursor al torso produce impacto físico" % index)
	# Apuntado en espacio vacío, sin selección de actor: misma altura del disparo.
	await place(arena, Vector3(-10, 0, -2), Vector3(2, 0, -2))
	var point := CombatAim.origin(arena.human) + Vector3(3, 0, 2)
	var solved: Vector3 = CombatAim.point(arena.camera, arena.camera.unproject_position(point), arena.human)
	check(solved.distance_to(point) < 0.001, "rayo a plano de combate conserva XZ sin paralaje")
	# Reproyectar con otra orientación de cámara, no depender de un ángulo fijo.
	arena.camera.position = Vector3(18, 27, 15)
	arena.camera.look_at(Vector3.ZERO)
	await frames(2)
	await click_at(arena, arena.bot.global_position + Vector3.UP)
	check(arena.bot.health == 6200 - 850, "apuntado al torso funciona con otra cámara inclinada")
	# Cadencia y excepciones de colisión no cambian.
	await place(arena, Vector3(-10, 0, -2), Vector3(2, 0, -2))
	arena.mouse_aim = false
	arena.human.command.aim = Vector2.RIGHT
	arena.human.facing = Vector3.RIGHT
	check(arena.human.act() and not arena.human.act(), "cadencia original impide doble disparo")
	var p: CombatProjectile = arena.projectiles.back()
	check(p.collision_mask == 3 and p.get_collision_exceptions().has(arena.human), "capas terreno/actor y exclusión del emisor")
	await frames(60)
	check(arena.human.health == 4000 and arena.bot.health == 6200 - 850, "no hay autoimpacto al salir del centro del emisor")
	# Rayos horizontales/atrás se rechazan sin reemplazar dirección por basura.
	var old_rotation := arena.camera.rotation
	arena.camera.rotation = Vector3.ZERO
	var horizontal: Variant = CombatAim.point(arena.camera, Vector2(640, 360), arena.human)
	check(horizontal == null, "rayo paralelo al plano se rechaza")
	arena.camera.rotation = old_rotation
	# Fuerza una dirección vertical desde un emisor bot: se normaliza a XZ.
	arena.bot.definition = arena.human.definition
	arena.bot.active = true
	arena.bot.facing = Vector3(-2, 5, 0)
	arena.human.position = Vector3(-10, 0, -2)
	arena.bot.position = Vector3(-6, 0, -2)
	arena.bot.spawn_point = arena.bot.position
	arena.human.invulnerable = 0
	arena.bot.attack_cooldown = 0
	await frames(3)
	arena.on_action(arena.bot, "shot")
	p = arena.projectiles.back()
	check(p.direction.is_equal_approx(Vector3.LEFT), "proyectil del bot aplana y normaliza dirección")
	await frames(30)
	check(arena.human.health == 4000 - 850, "bot usa mismo proyectil, reglas de impacto y daño")
	# No superar alcance incluso con pasos grandes o velocidades altas.
	p = CombatProjectile.new()
	p.source = arena.human
	p.position = Vector3(-10, CombatAim.HEIGHT, -2)
	p.direction = Vector3.RIGHT
	p.max_distance = 0.2
	p.speed = 100
	arena.add_child(p)
	p.set_physics_process(false)
	p._physics_process(0.1)
	check(p.done and p.travelled <= 0.2001 and is_equal_approx(p.global_position.y, CombatAim.HEIGHT), "paso grande limita distancia sin desvío vertical")
	arena.queue_free()
	await process_frame
	print("PROYECTILES: %d aprobadas; %d fallos" % [passed, failed])
	quit(0 if failed == 0 else 1)
