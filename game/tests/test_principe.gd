extends SceneTree
## El Príncipe #20: básico con anticipación, Impulso Táctico y Campo de Dominio.
## Valores de ensayo de docs/PRINCIPE_KIT.md; no acreditan balance.
var passed := 0
var failed := 0
const PRINCIPE := preload("res://data/characters/principe.tres")
const TURBO := preload("res://data/characters/turbo.tres")
const DT := 1.0 / 60

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

func make_arena(own: CharacterDefinition, rival: CharacterDefinition) -> IdolArena:
	GameSession.selected = own
	GameSession.selected_rival = rival
	GameSession.reload_enabled = true
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.set_physics_process(false)
	arena.bot.set_physics_process(false)
	await frames(2)
	arena.human.invulnerable = 0
	arena.bot.invulnerable = 0
	return arena

func dispose(arena: IdolArena) -> void:
	arena.queue_free()
	await process_frame
	await process_frame

func place(actor: ArenaPlayer, at: Vector3) -> void:
	actor.position = at
	actor.spawn_point = at
	actor.velocity = Vector3.ZERO
	actor.move_velocity = Vector3.ZERO
	actor.push_velocity = Vector3.ZERO

func run() -> void:
	# --- Datos del Resource -----------------------------------------------------
	check(CharacterCatalog.AVAILABLE.has(PRINCIPE) and PRINCIPE.number == 20 and PRINCIPE.id == "principe", "Príncipe #20 en el catálogo jugable")
	check(PRINCIPE.max_health == 4400 and is_equal_approx(PRINCIPE.speed, 6.6) and PRINCIPE.attack_damage == 750, "vida 4400, 6,6 m/s y básico 750")
	check(is_equal_approx(PRINCIPE.attack_interval, 0.6) and is_equal_approx(PRINCIPE.attack_windup, 0.12) and is_equal_approx(PRINCIPE.projectile_speed, 22.0), "cadencia 0,6 s, anticipación 0,12 s y 22 m/s")
	check(PRINCIPE.ammo.capacity == 3 and is_equal_approx(PRINCIPE.ammo.seconds_per_charge, 1.6), "3 cargas, una cada 1,6 s")
	check(PRINCIPE.ability.kind == "Power" and is_equal_approx(PRINCIPE.ability.damage_multiplier, 1.2) and is_equal_approx(PRINCIPE.ability.duration, 3.0) and is_equal_approx(PRINCIPE.ability.cooldown, 8.0), "Impulso Táctico +20 % durante 3 s, recarga 8 s")
	check(PRINCIPE.super_kind == "Field" and is_equal_approx(PRINCIPE.super_reach, 8.0) and is_equal_approx(PRINCIPE.super_radius, 3.0) and PRINCIPE.super_damage == 900, "campo hasta 8 m, radio 3 m, pulso 900")
	check(is_equal_approx(PRINCIPE.field_warning, 0.6) and is_equal_approx(PRINCIPE.field_duration, 3.0) and is_equal_approx(PRINCIPE.field_slow, 0.25) and is_equal_approx(PRINCIPE.field_push, 10.0), "aviso 0,6 s, campo 3 s, lento 25 %, empuje 10 m/s")
	check(PRINCIPE.model_scene != null and PRINCIPE.model_scene.resource_path.ends_with("principe.glb"), "usa el GLB del Príncipe en model_scene")
	check(TURBO.ability.kind == "Dash" and TURBO.super_kind == "Auto" and is_equal_approx(TURBO.attack_windup, 0.0), "Turbo conserva sprint, súper y disparo inmediato")

	# --- Básico con anticipación ---------------------------------------------------
	var arena := await make_arena(PRINCIPE, TURBO)
	var me := arena.human
	check(arena.bot.definition.id == "turbo", "el rival elegido en el menú llega a la arena")
	place(me, Vector3(8, 0, 0))
	place(arena.bot, Vector3(11, 0, 0))
	me.facing = Vector3.RIGHT
	var before := arena.projectiles.size()
	check(me.act() and me.ammo.charges == 2 and is_equal_approx(me.windup_time, 0.12), "aceptar consume carga e inicia la anticipación")
	check(arena.projectiles.size() == before, "durante la anticipación aún no sale el proyectil")
	me.facing = Vector3.BACK
	await frames(10)
	check(arena.projectiles.size() == before + 1, "el proyectil sale al terminar la anticipación")
	var shot: CombatProjectile = arena.projectiles.back()
	check(shot.damage == 750 and shot.direction.is_equal_approx(Vector3.RIGHT), "dirección y daño fijados al aceptar, aunque luego gire")
	me.attack_cooldown = 0
	me.act()
	me.take_damage(99999)
	await frames(12)
	check(arena.projectiles.size() <= before + 1 and me.ammo.charges == 1, "KO durante la anticipación cancela sin devolver la carga")
	await dispose(arena)

	# --- Impulso Táctico ---------------------------------------------------------------
	arena = await make_arena(PRINCIPE, TURBO)
	me = arena.human
	me.set_physics_process(false)
	place(me, Vector3(8, 0, 0))
	place(arena.bot, Vector3(11, 0, 0))
	check(me.ability() and is_equal_approx(me.damage_multiplier(), 1.2) and is_equal_approx(me.power_time, 3.0), "activa la mejora +20 % durante 3 s")
	check(not me.ability(), "recarga de 8 s impide reactivarla")
	check(me.dash_time == 0 and me.ammo.charges == 3, "no desplaza ni consume munición")
	me.act()
	check(is_equal_approx(me.shot_multiplier, 1.2), "la mejora se captura al aceptar el básico")
	me.power_time = 0.0
	me._physics_process(DT)
	check(is_equal_approx(me.damage_multiplier(), 1.0), "al expirar vuelve al daño base")
	for i in 10:
		me._physics_process(DT)
	check((arena.projectiles.back() as CombatProjectile).damage == 900, "el proyectil aceptado con mejora conserva 900 aunque expire")
	me.power_multiplier = 1.5
	me.power_time = 2.0
	me.cooldown = 0
	me.ability()
	check(is_equal_approx(me.damage_multiplier(), 1.5) and is_equal_approx(me.power_time, 2.0), "una mejora más débil no sustituye ni prolonga a una más fuerte")
	me.reset_at_spawn()
	check(is_equal_approx(me.damage_multiplier(), 1.0) and me.slow == 0 and me.channel_time == 0, "reaparecer limpia mejora, lentitud y preparación")
	await dispose(arena)

	# --- Campo de Dominio ----------------------------------------------------------------
	arena = await make_arena(PRINCIPE, TURBO)
	me = arena.human
	var rival := arena.bot
	me.set_physics_process(false)
	place(me, Vector3(5, 0, 0))
	place(rival, Vector3(10, 0, 1))
	me.super_charge = 100
	me.super_target = null
	check(not me.act("super") and me.super_charge == 100, "sin centro válido no consume la súper")
	me.super_target = Vector3(10, 0, 0)
	check(me.act("super") and me.super_charge == 0 and is_equal_approx(me.channel_time, 0.6), "consume 100 de súper e inicia la preparación de 0,6 s")
	check(arena.fields.size() == 1 and arena.fields[0].position.is_equal_approx(Vector3(10, 0, 0)), "fija el centro en el mundo")
	check(not me.act("shot") and not me.ability(), "durante la preparación no acepta otro ataque ni activa")
	var health := rival.health
	for i in 30:
		arena.update_fields(DT)
	check(rival.health == health and not arena.fields[0].triggered, "el aviso no hace daño todavía")
	place(rival, Vector3(10, 0, 1))
	for i in 8:
		arena.update_fields(DT)
	check(rival.health == health - 900, "el pulso aplica 900 una vez")
	check(rival.push_velocity.normalized().is_equal_approx(Vector3(0, 0, 1)) and is_equal_approx(rival.push_velocity.length(), 10.0), "empuje radial de 10 m/s desde el centro")
	check(me.super_charge == 0, "el pulso no recarga la súper")
	rival.push_velocity = Vector3.ZERO
	for i in 30:
		arena.update_fields(DT)
	check(rival.health == health - 900, "no repite daño durante el campo")
	check(is_equal_approx(rival.slow, 0.25), "dentro del campo el rival va un 25 % más lento")
	place(rival, Vector3(10, 0, 5))
	arena.update_fields(DT)
	check(rival.slow == 0.0, "al salir del campo desaparece la lentitud")
	rival.invulnerable = 1.0
	place(rival, Vector3(10, 0, 1))
	arena.update_fields(DT)
	check(rival.slow == 0.0, "la protección bloquea la lentitud")
	rival.invulnerable = 0
	check(me.slow == 0.0, "el dueño no recibe efectos de su campo")
	arena.freeze_combat(true)
	var age := arena.fields[0].age
	arena.update_fields(DT)
	check(is_equal_approx(arena.fields[0].age, age), "la pausa congela el campo")
	arena.freeze_combat(false)
	for i in 200:
		arena.update_fields(DT)
	check(arena.fields.is_empty() and rival.slow == 0.0, "el campo termina a los 3 s y libera al rival")

	# Cobertura: el bloque central corta pulso y lentitud.
	place(rival, Vector3(1.3, 0, 0))
	var covered := ZoneField.new()
	covered.setup(me, Vector3(-1.6, 0, 0))
	arena.add_child(covered)
	await frames(1)
	check(not covered.affects(rival), "la cobertura entre centro y rival bloquea el campo")
	place(rival, Vector3(-1.6, 0, 2.2))
	check(covered.affects(rival), "con línea libre y dentro del radio sí afecta")
	covered.queue_free()

	# Dueño eliminado antes de activar: se cancela.
	me.reset_at_spawn()
	me.channel_time = 0
	me.super_charge = 100
	place(rival, Vector3(10, 0, 0))
	me.super_target = Vector3(10, 0, 0)
	me.act("super")
	health = rival.health
	me.invulnerable = 0
	me.take_damage(99999)
	for i in 60:
		arena.update_fields(DT)
	check(rival.health == health and arena.fields.is_empty(), "KO durante el aviso cancela el campo sin devolver carga")

	# Un campo por emisor y campos que no se suman.
	me.reset_at_spawn()
	me.invulnerable = 0
	place(me, Vector3(5, 0, 0))
	me.super_charge = 100
	me.super_target = Vector3(10, 0, 0)
	me.act("super")
	me.channel_time = 0
	me.attack_cooldown = 0
	me.super_charge = 100
	me.super_target = Vector3(9, 0, 0)
	me.act("super")
	arena.update_fields(DT)
	check(arena.fields.size() == 1 and arena.fields[0].position.is_equal_approx(Vector3(9, 0, 0)), "un campo nuevo sustituye al anterior del mismo emisor")
	var ally := arena.spawn_player(PRINCIPE, 0, Vector3(6, 0, -3))
	await frames(1)
	var strong := ZoneField.new()
	strong.setup(ally, Vector3(10, 0, 0))
	strong.slow = 0.4
	arena.add_child(strong)
	arena.fields.append(strong)
	for field in arena.fields:
		field.triggered = true
		field.age = field.warning
	place(rival, Vector3(10, 0, 0.5))
	rival.invulnerable = 0
	arena.update_fields(DT)
	check(is_equal_approx(rival.slow, 0.4), "prevalece la lentitud más fuerte; no se suman")
	await dispose(arena)

	# --- Bot ------------------------------------------------------------------------------
	arena = await make_arena(TURBO, PRINCIPE)
	var bot := arena.bot
	arena.human.set_physics_process(false)
	place(arena.human, Vector3(4, 0, 0))
	place(bot, Vector3(10, 0, 0))
	bot.super_charge = 0
	arena.brain.update(bot, arena.human, arena.projectiles, DT, arena.fields)
	check(bot.command.shoot and bot.command.ability, "bot Príncipe activa la mejora con munición y blanco visible")
	bot.super_charge = 100
	arena.brain.update(bot, arena.human, arena.projectiles, DT, arena.fields)
	check(bot.command.super_shot and bot.super_target != null and (bot.super_target as Vector3).distance_to(Vector3(4, 0, 0)) < 0.01, "bot coloca el campo sobre el rival a su alcance")
	place(arena.human, Vector3(1.5, 0, 5))
	bot.super_charge = 100
	arena.brain.update(bot, arena.human, arena.projectiles, DT, arena.fields)
	check(not bot.command.super_shot, "bot no gasta la súper fuera de alcance")
	var field := ZoneField.new()
	field.setup(bot, Vector3(4, 0, 0))
	arena.add_child(field)
	arena.fields.append(field)
	place(arena.human, Vector3(5, 0, 0))
	arena.brain.update(arena.human, bot, arena.projectiles, DT, arena.fields)
	check(arena.human.command.move.x > 0.9, "un bot dentro de una zona anunciada sale por el lado opuesto al centro")
	await dispose(arena)

	# --- Menú: rival ----------------------------------------------------------------------
	GameSession.selected = TURBO
	GameSession.selected_rival = null
	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	await frames(2)
	check(menu.rival_text() == "RIVAL: EL REY", "rival por defecto sin cambios (Turbo contra Rey)")
	menu.cycle_rival()
	check(GameSession.selected_rival.id == "principe" and menu.rival_text().contains("PRÍNCIPE"), "el botón de rival recorre los héroes jugables")
	for i in CharacterCatalog.AVAILABLE.size() - 2:
		menu.cycle_rival()
	check(GameSession.selected_rival.id == "rey", "el ciclo vuelve al primero")
	GameSession.selected_rival = null
	menu.queue_free()
	await process_frame

	print("PRÍNCIPE: %d aprobadas; %d fallos" % [passed, failed])
	quit(1 if failed else 0)
