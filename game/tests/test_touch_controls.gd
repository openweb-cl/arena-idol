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

func touch(index: int, at: Vector2, pressed: bool, canceled := false, emulate := false) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = at
	event.pressed = pressed
	event.canceled = canceled
	if emulate:
		# Input recibe píxeles de pantalla; push_input(true) recibe canvas lógico.
		event.position = root.get_screen_transform() * at
		event.window_id = root.get_window_id()
		Input.parse_input_event(event)
		Input.flush_buffered_events()
	else:
		root.push_input(event, true)

func drag(index: int, at: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = at
	root.push_input(event, true)

func reset(arena: IdolArena, test_case := 0) -> void:
	arena.touch_controls.state.cancel_all()
	arena.set_training_case(test_case)
	await frames(3)

func run() -> void:
	var input := TouchInputState.new()
	check(input.press(7, "move") and input.press(9, "attack"), "dedos independientes para movimiento y ataque")
	input.drag(7, Vector2(200, 200), 82)
	check(is_equal_approx(input.movement.length(), 1), "diagonal/arrastre grande nunca acelera más que teclado")
	input.drag(7, Vector2(1, 1), 82)
	check(input.movement.is_zero_approx(), "zona muerta evita deriva")
	input.drag(7, Vector2(41, 0), 82)
	check(input.movement.x > 0 and input.movement.x < 1, "movimiento analógico conserva intensidad")
	check(input.fire_held() and not input.press(10, "attack"), "AUTO dispara solo con contacto y un segundo dedo no roba el botón")
	check(not input.release(99) and input.move_finger == 7, "liberación ajena no cancela otro dedo")
	input.release(9)
	check(not input.fire_held() and input.move_finger == 7, "soltar ataque conserva movimiento")
	input.press(9, "attack")
	input.set_auto_mode(false)
	check(not input.fire_held() and input.move_finger == 7, "cambiar modo cancela ataque pero conserva stick izquierdo")
	input.press(9, "attack")
	check(not input.fire_held(), "MANUAL espera una dirección antes del primer disparo")
	input.drag(9, Vector2(50, -20), 70)
	check(input.fire_held() and input.aim.y < 0, "arrastrar ataque orienta y mantiene fuego manual")
	input.release(9)
	check(not input.fire_held(), "soltar fuera del área cancela fuego manual")
	input.press(3, "ability")
	check(input.consume_ability() and not input.consume_ability(), "habilidad se entrega una sola vez por pulsación")
	input.press(4, "super")
	check(input.consume_super() and not input.consume_super() and input.move_finger == 7, "súper independiente mientras se mueve")
	input.cancel_all()
	check(input.fingers.is_empty() and input.movement.is_zero_approx() and input.aim.is_zero_approx(), "cancelación global limpia contactos y ejes")
	var safe := TouchSafeArea.map_rect(Rect2(100, 40, 2200, 1000), Rect2(0, 0, 2400, 1080), Vector2(1280, 576))
	check(safe.position.is_equal_approx(Vector2(53.33333, 21.33333)) and safe.end.x < 1280, "safe area transforma píxeles físicos al canvas")
	check(TouchSafeArea.map_rect(Rect2(), Rect2(), Vector2(1280, 720)) == Rect2(0, 0, 1280, 720), "sin metadatos de pantalla usa toda el área lógica")
	var offset := TouchSafeArea.map_rect(Rect2(1920, 0, 2400, 1080), Rect2(2020, 40, 2000, 1000), Vector2(1280, 720))
	check(offset == Rect2(0, 0, 1280, 720), "ventana desplazada en escritorio no pierde área segura")
	var stretch := Transform2D(Vector2(0.05, 0), Vector2(0, 0.05), Vector2(0, 14))
	var letterboxed := TouchSafeArea.from_screen(Rect2(0, 14, 64, 36), Vector2(1280, 720), stretch)
	check(letterboxed.position.is_zero_approx() and letterboxed.size.is_equal_approx(Vector2(1280, 720)), "safe area respeta barras y escala real del viewport")

	var arena: IdolArena = load("res://scenes/training/projectile_range.tscn").instantiate()
	arena.force_touch_controls = true
	arena.auto_target_enabled = true
	root.add_child(arena)
	current_scene = arena
	await frames(4)
	var controls := arena.touch_controls
	check(controls != null and controls.visible, "arena incorpora adaptador aislado")
	check(not arena.hud.keyboard_hints.visible and not arena.hud.pause_button.visible, "HUD táctil no duplica botones ni instrucciones de teclado")
	for rect: Rect2 in [Rect2(0, 0, 1280, 720), Rect2(80, 24, 1120, 672), Rect2(70, 0, 1510, 720), Rect2(0, 0, 960, 720)]:
		controls.set_safe_rect(rect)
		var inside := rect.encloses(controls.mode_rect)
		for action: String in controls.centers:
			var radius: float = controls.radii[action]
			inside = inside and rect.encloses(Rect2(controls.centers[action] - Vector2.ONE * radius, Vector2.ONE * radius * 2))
		check(inside, "controles grandes dentro de safe area %s" % rect)
	controls.refresh_layout()
	var aim_up := ArenaTouchControls.world_direction(Vector2.UP, arena.camera)
	check(aim_up.y < -0.99 and absf(aim_up.x) < 0.01, "stick de apuntado usa ejes del plano de combate, sin altura")
	var health := arena.bot.health
	await frames(60)
	check(arena.bot.health == health and arena.basic_attacks[0] == 0, "AUTO apunta sin disparar por sí solo")
	# Movimiento y dedo de ataque distintos, incluyendo emulación de mouse real.
	touch(0, controls.centers.move, true, false, true)
	drag(0, controls.centers.move + Vector2(-60, 0))
	touch(1, controls.centers.attack, true, false, true)
	await frames(10)
	check(arena.human.position.x < -10 and controls.state.fire_held(), "multitáctil real mueve y ataca simultáneamente")
	check(not arena.mouse_fire_held, "mouse emulado no arma un segundo canal de ataque")
	touch(0, Vector2.ZERO, false, false, true)
	touch(1, Vector2.ZERO, false, false, true)
	await reset(arena)
	var attacks := arena.basic_attacks[0]
	touch(2, controls.centers.attack, true)
	await frames(60)
	touch(2, Vector2.ZERO, false)
	await frames(12)
	check(arena.basic_attacks[0] - attacks == 3 and arena.bot.health == 6200 - 3 * 850, "ataque sostenido respeta cargas, cadencia e impactos originales")
	health = arena.bot.health
	await frames(50)
	check(arena.bot.health == health, "soltar fuera del botón detiene ataques durante recarga")
	await reset(arena)
	attacks = arena.basic_attacks[0]
	touch(2, controls.centers.attack, true)
	await frames(150)
	touch(2, Vector2.ZERO, false)
	await frames(12)
	check(arena.basic_attacks[0] - attacks == 4 and arena.bot.health == 6200 - 4 * 850, "mantener durante recarga recupera una carga sin saltar cadencia ni inventar tiros")
	await reset(arena, 3)
	touch(2, controls.centers.attack, true)
	await frames(8)
	check(arena.human.ammo.charges == 3 and arena.auto_target == null, "AUTO sin rival libre no consume munición a través de cobertura")
	touch(2, Vector2.ZERO, false)
	await reset(arena)
	touch(5, controls.mode_rect.get_center(), true)
	touch(5, Vector2.ZERO, false)
	check(not arena.auto_target_enabled and not controls.state.auto_mode, "botón de modo sincroniza AUTO/MANUAL con arena")
	attacks = arena.basic_attacks[0]
	touch(2, controls.centers.attack, true)
	await frames(6)
	check(arena.basic_attacks[0] == attacks, "tocar el centro en manual no dispara en dirección accidental")
	drag(2, controls.centers.attack + Vector2(60, 0))
	await frames(1)
	touch(2, Vector2.ZERO, false)
	await frames(18)
	check(arena.bot.health == 6200 - 850 and arena.human.facing.x > 0.99, "arrastrar manual dispara hacia la dirección elegida y aplica daño")
	await reset(arena)
	touch(2, controls.centers.attack, true)
	drag(2, controls.centers.attack + Vector2(0, -controls.radii.attack * 0.2))
	await frames(1)
	touch(2, Vector2.ZERO, false)
	check(arena.human.facing.z < -0.99 and arena.projectiles.back().direction.z < -0.99, "deflexión manual pequeña fija dirección completa sin disparar hacia el frente anterior")
	arena.set_auto_target(true)
	await reset(arena)
	touch(0, controls.centers.move, true)
	drag(0, controls.centers.move + Vector2(-60, 0))
	touch(3, controls.centers.ability, true)
	await frames(1)
	check(arena.human.cooldown > 0 and arena.human.dash_direction.x < 0 and arena.human.ammo.charges == 3, "habilidad usa movimiento y reglas existentes sin consumir cargas")
	touch(0, Vector2.ZERO, false)
	touch(3, Vector2.ZERO, false)
	await reset(arena)
	arena.human.super_charge = 0
	var supers := arena.super_attacks[0]
	touch(3, controls.centers.super, true)
	await frames(2)
	touch(3, Vector2.ZERO, false)
	check(arena.super_attacks[0] == supers and arena.human.ammo.charges == 3, "súper sin medidor no ataca ni consume cargas")
	arena.human.super_charge = 100
	touch(2, controls.centers.attack, true)
	await frames(1)
	arena.human.attack_cooldown = 0
	touch(3, controls.centers.super, true)
	await frames(1)
	check(arena.human.super_charge == 0 and arena.projectiles.any(func(p: CombatProjectile) -> bool: return p.power), "súper táctil tiene prioridad sobre ataque sostenido")
	touch(2, Vector2.ZERO, false)
	touch(3, Vector2.ZERO, false)
	await reset(arena)
	touch(0, controls.centers.move, true)
	drag(0, controls.centers.move + Vector2(-60, 0))
	touch(2, controls.centers.attack, true)
	touch(4, controls.centers.pause, true)
	check(arena.phase == IdolArena.Phase.PAUSED and controls.state.fingers.is_empty() and not controls.visible, "pausa táctil libera todos los dedos y deja accesible el overlay")
	var position := arena.human.position
	var remaining := arena.human.ammo.remaining
	await frames(30)
	check(arena.human.position == position and arena.human.ammo.remaining == remaining, "pausa congela movimiento y recarga")
	# Los botones normales del overlay reciben ScreenTouch mediante Input.
	await frames(2)
	var resume_at := arena.hud.resume.get_global_rect().get_center()
	touch(0, resume_at, true, false, true)
	await frames(2)
	touch(0, resume_at, false, false, true)
	await frames(3)
	check(arena.phase == IdolArena.Phase.PLAYING and controls.visible, "CONTINUAR responde al toque de GUI")
	check(not controls.state.fire_held() and controls.state.movement.is_zero_approx(), "reanudar requiere contactos nuevos")
	touch(2, controls.centers.attack, true)
	touch(2, Vector2.ZERO, false, true)
	check(controls.state.fingers.is_empty(), "evento canceled libera contactos")
	touch(2, controls.centers.attack, true)
	arena.human.invulnerable = 0
	arena.human.take_damage(99999)
	check(not controls.state.fire_held(), "KO cancela fuego de inmediato")
	await frames(2)
	touch(2, controls.centers.attack, true)
	check(not controls.state.fire_held(), "no se arma fuego mientras está eliminado")
	arena.human.reset_at_spawn()
	await frames(2)
	check(not controls.state.fire_held(), "respawn no recupera contactos antiguos")
	touch(2, controls.centers.attack, true)
	arena.notification(NOTIFICATION_APPLICATION_PAUSED)
	check(arena.phase == IdolArena.Phase.PAUSED and controls.state.fingers.is_empty(), "background de Android pausa y cancela contactos")
	arena.toggle_pause()
	touch(2, controls.centers.attack, true)
	for i in arena.config.target_eliminations:
		arena.rules.score(0)
	check(arena.phase == IdolArena.Phase.FINISHED and not controls.visible and controls.state.fingers.is_empty(), "resultado limpia controles y permite revancha/menú sin contactos antiguos")
	arena.queue_free()
	await frames(2)
	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(5)
	var choose: Button
	for node in menu.find_children("*", "Button", true, false):
		if node.text == "ELEGIR ÍDOLO": choose = node
	check(Input.is_emulating_mouse_from_touch(), "emulación táctil habilitada para menús")
	var at := choose.get_global_rect().get_center()
	touch(0, at, true, false, true)
	await frames(2)
	touch(0, at, false, false, true)
	await frames(3)
	check(menu.selection, "menú ELEGIR ÍDOLO responde a ScreenTouch")
	menu.queue_free()
	await frames(2)
	print("TÁCTIL: %d aprobadas; %d fallos" % [passed, failed])
	quit(1 if failed else 0)
