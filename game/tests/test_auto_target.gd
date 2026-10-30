extends SceneTree
var passed := 0
var failed := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, text: String) -> void:
	if ok:
		passed += 1
		print("PASS ", text)
	else:
		failed += 1
		push_error("FAIL " + text)

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func click(pressed: bool, at: Vector2 = Vector2(100, 400)) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = at
	root.push_input(event, true)

func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func reset(arena: IdolArena, from: Vector3, to: Vector3) -> void:
	click(false)
	for p in arena.projectiles:
		if is_instance_valid(p): p.queue_free()
	arena.projectiles.clear()
	arena.human.spawn_point = from
	arena.bot.spawn_point = to
	arena.human.reset_at_spawn()
	arena.bot.reset_at_spawn()
	arena.bot.invulnerable = 0
	arena.human.invulnerable = 0
	await frames(3)

func run() -> void:
	var arena: IdolArena = load("res://scenes/training/projectile_range.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.auto_target_enabled = true
	await frames(4)
	check(arena.auto_target == arena.bot and arena.target_marker.visible, "selección automática con indicador visible")
	var health := arena.bot.health
	await frames(60)
	check(arena.bot.health == health and arena.projectiles.is_empty(), "apuntar solo no dispara sin intervención")
	var extra := arena.spawn_player(CharacterCatalog.AVAILABLE[1], 1, Vector3(-8, 0, -2))
	extra.set_physics_process(false)
	await frames(3)
	check(arena.auto_target == extra, "elige al rival más cercano entre dos")
	extra.team = arena.human.team
	await frames(2)
	check(arena.auto_target == arena.bot, "descarta aliados")
	extra.team = 1
	extra.take_damage(99999)
	await frames(2)
	check(arena.auto_target == arena.bot, "descarta eliminados")
	extra.queue_free()
	await frames(2)
	check(arena.auto_target == arena.bot, "tolera candidatos liberados")
	await reset(arena, Vector3(-3, 0, 0), Vector3(3, 0, 0))
	check(arena.auto_target == null, "cobertura impide selección")
	click(true)
	await frames(3)
	click(false)
	check(arena.projectiles.is_empty(), "sin blanco libre no lanza tiros automáticos contra pared")
	await reset(arena, Vector3(-12, 0, -2), Vector3(2, 0, -2))
	check(arena.auto_target == null, "descarta rivales fuera de alcance")
	# Las ocho direcciones a distancia de contacto físico; sin reajustar colliders.
	for i in 8:
		var direction := Vector3(cos(i * TAU / 8), 0, sin(i * TAU / 8))
		await reset(arena, Vector3(-9, 0, 0), Vector3(-9, 0, 0) + direction * 0.86)
		click(true)
		await frames(1)
		click(false)
		await frames(5)
		check(arena.bot.health == 6200 - 850, "contacto dirección %d: clic separado impacta y aplica daño original" % i)
	# Mantener el botón repite respetando 0,42 s; soltar encima del HUD lo detiene.
	await reset(arena, Vector3(-10, 0, -2), Vector3(-7, 0, -2))
	click(true)
	await frames(60)
	click(false, Vector2(1150, 50))
	await frames(12)
	check(arena.bot.health == 6200 - 3 * 850, "clic sostenido da tres ataques en el primer segundo respetando cadencia")
	health = arena.bot.health
	await frames(60)
	check(arena.bot.health == health, "soltar sobre HUD detiene repetición")
	# Pulsar Q con el disparo mantenido no debe quedar oculto por el básico.
	await reset(arena, Vector3(-10, 0, -2), Vector3(-7, 0, -2))
	click(true)
	await frames(1)
	arena.human.super_charge = 100
	arena.human.attack_cooldown = 0
	key(KEY_Q, true)
	key(KEY_Q, false)
	await frames(1)
	click(false)
	check(arena.projectiles.back().power and arena.human.super_charge == 0, "súper lista tiene prioridad sobre básico sostenido")
	# Espacio sostenido usa exactamente el mismo mecanismo.
	await reset(arena, Vector3(-10, 0, -2), Vector3(-7, 0, -2))
	key(KEY_SPACE, true)
	await frames(60)
	key(KEY_SPACE, false)
	await frames(12)
	check(arena.bot.health == 6200 - 3 * 850, "Espacio sostenido respeta cadencia")
	await reset(arena, Vector3(-9, 0, 0), Vector3(-8.14, 0, 0))
	arena.bot.invulnerable = 0.7
	click(true)
	await frames(8)
	check(arena.bot.health == 6200 and arena.shot_events.back().reason == "protegido" and arena.hud.assist_status.text.contains("PROTEGIDO"), "embestida protegida explica colisión sin daño")
	await frames(50)
	click(false)
	check(arena.bot.health == 6200 - 850, "al terminar protección vuelve a recibir impacto")
	# Movimiento y apuntado independientes: retroceder no gira el tiro hacia atrás.
	await reset(arena, Vector3(-9, 0, -2), Vector3(-6, 0, -2))
	key(KEY_A, true)
	click(true)
	await frames(25)
	key(KEY_A, false)
	click(false)
	await frames(10)
	check(arena.human.position.x < -10 and arena.bot.health < 6200, "retrocede con teclado mientras apunta y daña al rival")
	await reset(arena, Vector3(-10, 0, -2), Vector3(-7, 0, -2))
	click(true)
	await frames(1)
	arena.toggle_pause()
	check(not arena.mouse_fire_held and not arena.key_fire_held, "pausa suelta controles de disparo")
	arena.toggle_pause()
	await frames(60)
	check(arena.bot.health == 6200 - 850, "reanudar no reinicia fuego por un botón antiguo")
	key(KEY_T, true)
	key(KEY_T, false)
	await frames(3)
	check(not arena.auto_target_enabled and not arena.target_marker.visible, "T cambia a manual y oculta selección")
	await reset(arena, Vector3(-10, 0, -2), Vector3(-7, 0, -2))
	var at := arena.camera.unproject_position(arena.bot.global_position + Vector3.UP)
	click(true, at)
	await frames(1)
	click(false, at)
	await frames(20)
	check(arena.bot.health == 6200 - 850, "el modo manual conserva apuntado al torso")
	key(KEY_T, true)
	key(KEY_T, false)
	await frames(3)
	check(arena.auto_target_enabled and arena.auto_target == arena.bot, "T restaura selección automática")
	click(true)
	arena.human.invulnerable = 0
	arena.human.take_damage(99999)
	check(not arena.mouse_fire_held and not arena.key_fire_held, "eliminación suelta los disparos sostenidos")
	click(true)
	check(not arena.mouse_fire_held, "clic durante eliminación no arma disparo para la reaparición")
	arena.queue_free()
	await process_frame
	print("AUTO: %d aprobadas; %d fallos" % [passed, failed])
	quit(0 if failed == 0 else 1)
