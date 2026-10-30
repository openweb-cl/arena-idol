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

func remove_arena(arena: IdolArena) -> void:
	arena.queue_free()
	await process_frame
	await process_frame

func make_arena(layout: ArenaDefinition, hero: int = 0) -> IdolArena:
	GameSession.selected = CharacterCatalog.AVAILABLE[hero]
	GameSession.selected_arena = layout
	GameSession.reload_enabled = true
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	return arena

func run() -> void:
	var original: Array[Rect2] = [Rect2(-6, -4.8, 2.5, 2), Rect2(3.5, -4.8, 2.5, 2), Rect2(-6, 2.8, 2.5, 2), Rect2(3.5, 2.8, 2.5, 2), Rect2(-0.8, -1.3, 1.6, 2.6)]
	check(GameSession.ARENAS[0].obstacles == original, "A conserva exactamente la geometría anterior")
	for layout in GameSession.ARENAS:
		var arena := make_arena(layout)
		arena.set_physics_process(false)
		arena.bot.set_physics_process(false)
		await frames(3)
		check(arena.pitch.definition == layout and arena.brain.layout == layout, "%s: visual colisión y navegación comparten Resource" % layout.id)
		check(arena.human.position == layout.player_spawn and arena.bot.position == layout.bot_spawn, "%s: apariciones desde el Resource" % layout.id)
		var obstacle_count := 0
		for body in arena.pitch.get_children():
			if body.has_meta("obstacle_index"): obstacle_count += 1
		check(obstacle_count == layout.obstacles.size(), "%s: todos los muros del Resource tienen collider" % layout.id)
		var all_physical := true
		var all_solid := true
		var symmetric := true
		for rect in layout.obstacles:
			var center := rect.get_center()
			var start := Vector3(center.x, CombatAim.HEIGHT, rect.position.y - 0.25)
			var finish := Vector3(center.x, CombatAim.HEIGHT, center.y)
			var hit := arena.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(start, finish, 1))
			all_physical = all_physical and not hit.is_empty() and hit.collider.has_meta("obstacle_index")
			all_solid = all_solid and arena.brain.navigation.is_point_solid(Vector2i(roundi(center.x), roundi(center.y)))
			var mirror := Rect2(-rect.end, rect.size)
			symmetric = symmetric and layout.obstacles.any(func(other: Rect2) -> bool: return other.is_equal_approx(mirror))
		check(all_physical and all_solid, "%s: cada cobertura existe en física y rejilla de navegación" % layout.id)
		check(symmetric, "%s: cobertura simétrica al intercambiar lados" % layout.id)
		var source := Vector2i(roundi(layout.player_spawn.x), roundi(layout.player_spawn.z))
		var destination := Vector2i(roundi(layout.bot_spawn.x), roundi(layout.bot_spawn.z))
		check(not arena.brain.navigation.is_point_solid(source) and not arena.brain.navigation.is_point_solid(destination), "%s: apariciones sin muros" % layout.id)
		var forward := arena.brain.navigation.get_id_path(source, destination)
		var reverse := arena.brain.navigation.get_id_path(destination, source)
		check(forward.size() > 0 and forward.size() == reverse.size(), "%s: rutas entre apariciones en ambos sentidos" % layout.id)
		var connected := true
		for x in range(-12, 13):
			for z in range(-6, 7):
				var cell := Vector2i(x, z)
				if not arena.brain.navigation.is_point_solid(cell):
					connected = connected and arena.brain.navigation.get_id_path(source, cell).size() > 0
		check(connected, "%s: todas las celdas libres conectadas, sin bolsillos cerrados" % layout.id)
		# Acercar el personaje al primer muro con la física de movimiento real.
		var wall := layout.obstacles[0]
		var mid := wall.get_center()
		arena.human.position = Vector3(mid.x, 0, wall.position.y - 1)
		arena.human.command.move = Vector2.DOWN
		arena.human.command.aim = Vector2.DOWN
		await frames(60)
		check(arena.human.position.z < wall.position.y - 0.3, "%s: personaje no atraviesa cobertura" % layout.id)
		arena.human.command.move = Vector2.ZERO
		arena.human.move_velocity = Vector3.ZERO
		arena.human.velocity = Vector3.ZERO
		arena.human.facing = Vector3.BACK
		arena.human.attack_cooldown = 0
		arena.bot.position = Vector3(mid.x, 0, wall.end.y + 1)
		arena.bot.invulnerable = 0
		await frames(3)
		check(not TargetSelector.clear_path(arena.human, arena.bot) and TargetSelector.nearest(arena.human, arena.actors) == null, "%s: AUTO y guía respetan muro intermedio" % layout.id)
		arena.human.act()
		await frames(15)
		check(not arena.shot_events.is_empty() and arena.shot_events.back().reason == "cobertura" and arena.bot.health == arena.bot.definition.max_health, "%s: disparo pegado al muro bloqueado, sin daño tras cobertura" % layout.id)
		check(arena.report_data().map == layout.id and arena.human.ammo.capacity() == 3, "%s: informe identifica mapa sin cambiar recarga" % layout.id)
		await remove_arena(arena)
		# Navegación/ataque reales de los dos kits en ambos mapas.
		for hero in 2:
			arena = make_arena(layout, hero)
			arena.human.invulnerable = 9999
			var initial := arena.bot.position
			await frames(900)
			check(arena.bot.position.distance_to(initial) > 4 and arena.basic_attacks[1] > 0, "%s: bot %s navega y ataca sin encallarse" % [layout.id, arena.bot.definition.id])
			check(arena.report_data().participants[1].limited_ammo == (arena.bot.definition.id == "turbo"), "%s: bot mantiene reglas del héroe" % layout.id)
			await remove_arena(arena)

	var b := GameSession.ARENAS[1]
	var clearance_ok := true
	for i in b.obstacles.size():
		var rect := b.obstacles[i]
		clearance_ok = clearance_ok and rect.position.x >= -13 + 2.4 - 0.001 and rect.end.x <= 13 - 2.4 + 0.001 and rect.position.y >= -7 + 2.4 - 0.001 and rect.end.y <= 7 - 2.4 + 0.001
		for j in range(i + 1, b.obstacles.size()):
			var other := b.obstacles[j]
			var gap := Vector2(maxf(0, maxf(rect.position.x - other.end.x, other.position.x - rect.end.x)), maxf(0, maxf(rect.position.y - other.end.y, other.position.y - rect.end.y)))
			clearance_ok = clearance_ok and gap.length() >= 2.4 - 0.001
	check(clearance_ok, "B conserva al menos 2,4 m entre coberturas y bordes")
	GameSession.selected_arena = GameSession.ARENAS[1]
	var training: IdolArena = load("res://scenes/training/projectile_range.tscn").instantiate()
	root.add_child(training)
	check(training.layout.id == "prisma-a", "campo de tiro usa A para conservar regresiones")
	await remove_arena(training)
	GameSession.selected_arena = GameSession.ARENAS[0]
	GameSession.selected = CharacterCatalog.AVAILABLE[0]
	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(2)
	var map_button: Button
	var rules_button: Button
	for button in menu.find_children("*", "Button", true, false):
		if button.text.begins_with("ARENA "): map_button = button
		if button.text.begins_with("REGLAS:"): rules_button = button
	map_button.pressed.emit()
	check(GameSession.selected_arena.id == "prisma-b" and map_button.text == "ARENA B", "selector del menú alterna A/B")
	rules_button.pressed.emit()
	check(not GameSession.reload_enabled and GameSession.selected_arena.id == "prisma-b", "reglas de munición y selección de mapa son independientes")
	rules_button.pressed.emit()
	menu.start_match()
	await frames(3)
	var played := current_scene as IdolArena
	check(played.layout.id == "prisma-b" and played.human.ammo.limited(), "JUGAR inicia B con la recarga seleccionada")
	played.hud.replay_requested.emit()
	await frames(3)
	played = current_scene as IdolArena
	check(played.layout.id == "prisma-b" and played.rules.scores == [0, 0], "revancha conserva B y limpia el marcador")
	played.hud.menu_requested.emit()
	await frames(3)
	check(current_scene is Control, "desde B se vuelve al menú")
	current_scene.queue_free()
	await process_frame
	GameSession.selected_arena = GameSession.ARENAS[0]
	GameSession.selected = CharacterCatalog.AVAILABLE[0]
	print("MAPAS: %d aprobadas; %d fallos" % [passed, failed])
	quit(0 if failed == 0 else 1)
