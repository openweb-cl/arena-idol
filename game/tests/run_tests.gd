extends SceneTree
## Pruebas reales de reglas, escenas y física. Sin plugins ni dependencias de pago.
var passed := 0
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, title: String) -> void:
	if condition:
		passed += 1
		print("PASS ", title)
	else:
		failures.append(title)
		push_error("FAIL " + title)

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func make_arena(id: int = 0) -> IdolArena:
	GameSession.selected = CharacterCatalog.AVAILABLE[id]
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	return arena

func dispose(node: Node) -> void:
	node.queue_free()
	await process_frame
	await process_frame

func isolate(arena: IdolArena) -> void:
	arena.set_physics_process(false)
	arena.bot.set_physics_process(false)
	arena.human.invulnerable = 0
	arena.bot.invulnerable = 0

func run() -> void:
	check(CharacterCatalog.CAPACITY == 16 and CharacterCatalog.AVAILABLE.size() == 4, "catálogo de 16 plazas, cuatro héroes implementados")
	check(CharacterCatalog.AVAILABLE[0].number == 11 and CharacterCatalog.AVAILABLE[1].number == 23 and CharacterCatalog.AVAILABLE[2].number == 20 and CharacterCatalog.AVAILABLE[3].number == 17, "dorsales canónicos 11, 23, 20 y 17")
	var config := MatchConfig.new()
	config.target_eliminations = 2
	config.duration_seconds = 10
	var rules := MatchRules.new(config)
	var endings: Array[int] = []
	rules.finished.connect(func() -> void: endings.append(1))
	rules.score(-1)
	rules.score(2)
	check(rules.scores == [0, 0], "equipo inválido no suma")
	rules.score(0)
	rules.score(0)
	rules.score(1)
	rules.tick(20)
	check(rules.ended and rules.scores == [2, 0] and endings.size() == 1, "victoria y cierre único sin score posterior")
	var tie := MatchRules.new(config)
	tie.tick(10)
	check(tie.ended and tie.result() == "EMPATE", "empate por tiempo")
	var defeat := MatchRules.new(config)
	defeat.score(1)
	defeat.tick(10)
	check(defeat.result() == "GANA EL RIVAL", "derrota por marcador al agotar tiempo")

	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	await frames(2)
	menu.show_selection()
	await frames(2)
	menu.select_character(CharacterCatalog.AVAILABLE[1])
	check(GameSession.selected.id == "rey" and menu.preview.definition.number == 23, "selección cambia Resource y vista 3D")
	var disabled := 0
	for button in menu.find_children("*", "Button", true, false):
		if button.disabled:
			disabled += 1
	check(disabled == 12, "las 12 plazas futuras están deshabilitadas")
	menu.show_home()
	await frames(2)
	check(not menu.selection and menu.preview.definition.id == "rey", "regreso a inicio conserva personaje")
	current_scene = menu
	menu.start_match()
	await frames(3)
	check(current_scene is IdolArena and current_scene.human.definition.id == "rey", "menú inicia partida con héroe elegido")
	await dispose(current_scene)

	var input_arena := make_arena()
	input_arena.bot.set_physics_process(false)
	var key := InputEventKey.new()
	key.keycode = KEY_D
	key.physical_keycode = KEY_D
	key.pressed = true
	Input.parse_input_event(key)
	await frames(25)
	key.pressed = false
	Input.parse_input_event(key)
	check(input_arena.human.position.x > -8, "tecla D simulada recorre adaptador de entrada y mueve actor")
	await frames(25)
	input_arena.human.position = Vector3(-6, 0, -2)
	input_arena.bot.position = Vector3(-2, 0, -2)
	input_arena.bot.invulnerable = 0
	await frames(2)
	var point := input_arena.camera.unproject_position(input_arena.bot.position)
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
	await frames(3)
	check(input_arena.human.command.aim.x > 0.9, "ratón apunta mediante proyección cámara-terreno")
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.position = point
	mouse.pressed = true
	root.push_input(mouse, true)
	await frames(25)
	mouse.pressed = false
	root.push_input(mouse, true)
	check(input_arena.bot.health < input_arena.bot.definition.max_health, "clic simulado dispara y daña mediante adaptador de entrada")
	await dispose(input_arena)

	var arena := make_arena()
	isolate(arena)
	await frames(2)
	var human := arena.human
	var bot := arena.bot
	check(arena.camera.projection == Camera3D.PROJECTION_ORTHOGONAL and human is CharacterBody3D, "arena y controlador 3D reales con cámara ortográfica")
	human.position = Vector3(-10, 0, -1.8)
	human.command.move = Vector2.RIGHT
	await frames(3)
	var early_speed := human.velocity.length()
	await frames(25)
	check(human.position.x > -9 and human.velocity.length() > early_speed, "aceleración y movimiento mediante física")
	human.command.move = Vector2.ZERO
	await frames(25)
	check(human.velocity.length() < 0.05, "frenado hasta reposo")
	human.position = Vector3(-2, 0, 0)
	human.command.move = Vector2.RIGHT
	await frames(60)
	check(human.position.x < -1.15, "obstáculo central impide atravesar cobertura")
	human.command.move = Vector2.ZERO
	human.move_velocity = Vector3.ZERO
	human.velocity = Vector3.ZERO
	human.position = Vector3(-12, 0, 0)
	human.command.move = Vector2.LEFT
	await frames(40)
	check(human.position.x > -12.65, "pared exterior contiene al personaje")
	human.command.move = Vector2.ZERO
	human.move_velocity = Vector3.ZERO
	human.velocity = Vector3.ZERO
	human.position = Vector3(-7, 0, 0)
	bot.position = Vector3(-3, 0, 0)
	human.facing = Vector3.RIGHT
	var before := bot.health
	check(human.act(), "ataque disponible")
	check(not human.act(), "cadencia impide spam de ataque")
	await frames(20)
	check(bot.health == before - human.definition.attack_damage, "proyectil impacta y resta vida real")
	check(human.super_charge == human.definition.charge_per_hit, "súper carga solo con impacto válido")
	check(human.health == human.definition.max_health, "proyectil excluye al emisor")
	# La misma línea de tiro ahora cruza el bloque central.
	human.position = Vector3(-3, 0, 0)
	bot.position = Vector3(3, 0, 0)
	await frames(2)
	before = bot.health
	human.attack_cooldown = 0
	human.act()
	await frames(35)
	check(bot.health == before, "cobertura bloquea pelotazos")
	# Disparo pegado al borde: el origen no puede saltarse la cobertura.
	human.position = Vector3(-1.23, 0, 0)
	human.move_velocity = Vector3.ZERO
	human.velocity = Vector3.ZERO
	await frames(2)
	human.attack_cooldown = 0
	human.act()
	await frames(30)
	check(bot.health == before, "disparar junto a pared no atraviesa su cara frontal")
	check(not human.act("super"), "súper rechaza carga incompleta")
	human.super_charge = 100
	human.attack_cooldown = 0
	check(human.act("super") and human.super_charge == 0, "súper consume su carga")
	check(arena.projectiles.back().power and arena.projectiles.back().damage == human.definition.super_damage, "Remate Relámpago usa proyectil especial")
	check(human.ability() and not human.ability(), "Turbo Sprint respeta cooldown")
	await frames(30)
	check(human.cooldown > 0 and human.dash_time == 0, "sprint termina antes del enfriamiento")
	bot.invulnerable = 0
	arena.apply_damage(bot, human, 20000, Vector3.RIGHT * 5)
	check(bot.knocked_out and bot.health == 0 and not bot.visible and arena.rules.scores[0] == 1, "eliminación, ocultación y punto único")
	arena.apply_damage(bot, human, 20000, Vector3.ZERO)
	check(arena.rules.scores[0] == 1, "eliminado no concede puntos duplicados")
	bot.set_physics_process(true)
	await frames(250)
	check(not bot.knocked_out and bot.health == bot.definition.max_health and bot.visible, "reaparición restaura vida y presencia")
	bot.invulnerable = 0.8
	check(not bot.take_damage(999), "protección de reaparición bloquea daño")
	bot.set_physics_process(false)
	# Pausa congela reloj, daño, cooldown y proyectil.
	human.attack_cooldown = 0
	human.facing = Vector3.BACK
	human.act()
	var projectile: CombatProjectile = arena.projectiles.back()
	var location := projectile.position
	var remaining := arena.rules.remaining
	var cooldown := human.cooldown
	arena.toggle_pause()
	await frames(20)
	check(projectile.position.is_equal_approx(location) and human.cooldown == cooldown and arena.rules.remaining == remaining, "pausa congela proyectiles, cooldown y reloj")
	before = human.health
	arena.apply_damage(human, bot, 999, Vector3.ZERO)
	check(human.health == before, "no hay daño durante pausa")
	arena.toggle_pause()
	check(arena.phase == IdolArena.Phase.PLAYING and human.active, "reanudar restaura combate")
	await dispose(arena)

	arena = make_arena(1)
	isolate(arena)
	await frames(2)
	human = arena.human
	bot = arena.bot
	human.position = Vector3(-7, 0, 0)
	bot.position = Vector3(-5, 0, 0)
	human.facing = Vector3.RIGHT
	before = bot.health
	human.act()
	check(bot.health == before - human.definition.attack_damage, "Rey daña en corto alcance")
	bot.position = Vector3(-1, 0, -2)
	human.attack_cooldown = 0
	before = bot.health
	human.act()
	check(bot.health == before, "melee no alcanza rivales lejanos")
	human.attack_cooldown = 0
	human.super_charge = 100
	bot.position = Vector3(-9, 0, 0)
	before = bot.health
	human.act("super")
	check(bot.health == before - human.definition.super_damage, "Onda Real alcanza detrás en radio")
	check(human.ability() and human.invulnerable > 0 and human.definition.ability.contact_damage > 0, "Embestida Real configura escudo y contacto")
	# IA: evasión dirigida ante una trayectoria entrante.
	var danger := CombatProjectile.new()
	danger.source = human
	danger.direction = Vector3.RIGHT
	danger.position = bot.position - Vector3.RIGHT * 3
	arena.add_child(danger)
	arena.brain.update(bot, human, [danger], 1.0 / 60)
	check(arena.brain.dodges > 0 and absf(bot.command.move.y) > 0, "bot esquiva proyectil entrante")
	await dispose(arena)

	arena = make_arena(1)
	arena.bot.set_physics_process(false)
	arena.human.position = Vector3(-6, 0, 0)
	arena.bot.position = Vector3(-4.5, 0, 0)
	arena.bot.invulnerable = 0
	arena.human.facing = Vector3.RIGHT
	before = arena.bot.health
	arena.human.ability()
	await frames(40)
	check(arena.bot.health == before - arena.human.definition.ability.contact_damage, "Embestida Real daña exactamente una vez por activación")
	await dispose(arena)

	# Ejecutar IA y partido completos con física real, sin simular sus callbacks.
	arena = make_arena()
	var initial := arena.bot.position
	await frames(360)
	check(arena.bot.position.distance_to(initial) > 4, "bot navega alrededor de cobertura")
	await frames(900)
	check(arena.impacts > 0, "bot persigue y produce impactos reales")
	check(arena.rules.scores[1] > 0, "bot logra eliminación sin intervención del test")
	await frames(10000)
	check(arena.rules.ended and arena.rules.scores[1] == arena.config.target_eliminations, "bot completa victoria al límite de eliminaciones")
	check(arena.phase == IdolArena.Phase.FINISHED and arena.hud.overlay.visible and not arena.human.active, "resultado de partida completa detiene combate")
	arena.hud.replay_requested.emit()
	await frames(3)
	arena = current_scene as IdolArena
	check(arena != null and arena.rules.scores == [0, 0] and arena.rules.remaining > 179 and arena.human.health == arena.human.definition.max_health, "botón revancha recarga partida y limpia reloj marcador y vida")
	arena.hud.menu_requested.emit()
	await frames(3)
	check(current_scene is Control and current_scene.scene_file_path == "res://scenes/menu/main.tscn", "botón volver al menú funciona")
	await dispose(current_scene)
	print("RESULTADO: %d verificaciones aprobadas; %d fallos" % [passed, failures.size()])
	quit(0 if failures.is_empty() else 1)
