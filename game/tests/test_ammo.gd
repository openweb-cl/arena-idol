extends SceneTree
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

func run() -> void:
	var settings := AmmoDefinition.new()
	var state := AmmoState.new(settings)
	check(state.charges == 3 and state.remaining == 0, "depósito inicial lleno y temporizador inactivo")
	check(state.consume() and state.charges == 2, "un ataque consume una carga")
	state.tick(0.5)
	state.consume()
	check(is_equal_approx(state.remaining, 1.0), "disparar no reinicia el ciclo de recarga")
	check(state.consume() and not state.consume() and state.charges == 0, "vacío rechaza consumo sin cargas negativas")
	state.tick(0.99)
	check(state.charges == 0, "no regenera anticipadamente")
	state.tick(0.01)
	check(state.charges == 1 and is_equal_approx(state.remaining, 1.5), "recupera una carga al cumplir 1,5 segundos")
	state.tick(6)
	check(state.charges == 3 and state.remaining == 0 and state.progress() == 1, "paso grande recupera hasta capacidad y detiene reloj")
	state.consume()
	state.reset()
	check(state.charges == 3 and state.remaining == 0, "reset restaura depósito y ciclo")
	state.unlimited = true
	for i in 20: state.consume()
	check(state.charges == 3 and not state.limited(), "referencia ilimitada no consume")
	var no_ammo := AmmoState.new()
	check(no_ammo.consume() and not no_ammo.limited(), "héroe sin recurso no hereda restricción")

	GameSession.reload_enabled = true
	var arena: IdolArena = load("res://scenes/training/projectile_range.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.set_physics_process(false)
	arena.human.set_physics_process(false)
	arena.bot.set_physics_process(false)
	await frames(2)
	var player := arena.human
	check(player.ammo.limited() and not arena.bot.ammo.limited(), "Turbo limitado y Rey sin munición")
	player.active = false
	check(not player.act() and player.ammo.charges == 3, "actor inactivo no consume")
	player.active = true
	check(player.act() and player.ammo.charges == 2, "ataque aceptado crea proyectil y consume")
	check(not player.act() and player.ammo.charges == 2, "rechazo por cadencia no consume")
	player.attack_cooldown = 0
	player.act()
	player.attack_cooldown = 0
	player.act()
	await frames(3)
	var count := arena.projectiles.size()
	var phase_before := player.visual.action_time
	player.attack_cooldown = 0
	check(not player.act() and arena.projectiles.size() == count and player.visual.action_time == phase_before, "vacío no crea proyectil ni reinicia animación")
	player.super_charge = 100
	check(player.act("super") and player.super_charge == 0 and player.ammo.charges == 0, "súper disponible con depósito vacío e independiente")
	check(player.ability() and player.ammo.charges == 0, "sprint no consume ni exige cargas")
	player.active = true
	player.set_physics_process(true)
	arena.toggle_pause()
	var remaining := player.ammo.remaining
	await frames(20)
	check(player.ammo.remaining == remaining, "pausa congela recarga")
	arena.toggle_pause()
	await frames(90)
	check(player.ammo.charges == 1, "reanudar recupera exactamente una carga")
	player.invulnerable = 0
	player.take_damage(99999)
	await frames(245)
	check(not player.knocked_out and player.ammo.charges == 3 and player.ammo.remaining == 0, "reaparición repone todas las cargas")
	arena.hud.update_state(arena.rules, player)
	check(arena.hud.ammo_cells.get_child_count() == 3 and arena.hud.ammo_title.text.contains("3/3"), "HUD muestra tres segmentos y cantidad")
	var data := arena.report_data()
	check(data.participants[0].empty_periods == 1 and data.participants[0].empty_seconds > 0, "informe registra periodos y tiempo sin munición")
	var path := MatchReport.save(data)
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	check(saved.schema == 1 and saved.participants[0].character == "turbo", "informe JSON local recuperable")
	arena.queue_free()
	await process_frame

	# Bot y jugador comparten implementación y configuración, no sólo disparo visual.
	GameSession.selected = CharacterCatalog.AVAILABLE[1]
	arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	arena.set_physics_process(false)
	arena.human.set_physics_process(false)
	arena.bot.set_physics_process(false)
	await frames(2)
	check(arena.bot.ammo.limited() and arena.bot.ammo.capacity() == 3 and not arena.human.ammo.limited(), "bot Turbo recibe el mismo recurso; Rey humano no")
	for i in 3:
		arena.bot.attack_cooldown = 0
		arena.bot.act()
	arena.bot.attack_cooldown = 0
	check(not arena.bot.act() and arena.bot.ammo.charges == 0, "bot tampoco dispara sin cargas")
	arena.bot.ammo.tick(1.5)
	check(arena.bot.act() and arena.bot.ammo.charges == 0, "bot recupera y consume una carga con las mismas reglas")
	arena.queue_free()
	await process_frame

	GameSession.selected = CharacterCatalog.AVAILABLE[0]
	arena = load("res://scenes/training/projectile_range.tscn").instantiate()
	root.add_child(arena)
	await frames(3)
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.position = arena.camera.unproject_position(arena.bot.global_position + Vector3.UP)
	mouse.pressed = true
	root.push_input(mouse, true)
	await frames(174)
	mouse.pressed = false
	root.push_input(mouse, true)
	await frames(10)
	check(arena.basic_attacks[0] == 4 and arena.bot.health == 6200 - 4 * 850, "sostener disparo respeta cargas durante varias recargas")
	arena.auto_target_enabled = true
	arena.set_training_case(4)
	var accepted := arena.basic_attacks[0]
	mouse.pressed = true
	root.push_input(mouse, true)
	await frames(10)
	mouse.pressed = false
	root.push_input(mouse, true)
	check(arena.human.ammo.charges == 3 and arena.basic_attacks[0] == accepted, "AUTO sin blanco válido no consume cargas")
	var lab := InputEventKey.new()
	lab.physical_keycode = KEY_L
	lab.pressed = true
	root.push_input(lab, true)
	check(arena.laboratory_unlimited_ammo and not arena.human.ammo.limited(), "L permite aislar regresiones sólo en laboratorio")
	arena.queue_free()
	await process_frame

	GameSession.selected = CharacterCatalog.AVAILABLE[0]
	GameSession.reload_enabled = false
	arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	arena.set_physics_process(false)
	await frames(2)
	check(not arena.human.ammo.limited() and arena.report_data().configuration == "reference-pr3", "referencia del menú restaura comportamiento previo")
	arena.queue_free()
	await process_frame
	GameSession.reload_enabled = true
	print("MUNICIÓN: %d aprobadas; %d fallos" % [passed, failed])
	quit(0 if failed == 0 else 1)
