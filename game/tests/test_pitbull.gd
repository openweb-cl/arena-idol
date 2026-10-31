extends SceneTree
## El Pitbull #17: Impacto Corto, Guardia de Hierro (escudo finito) y Zona de
## Contención centrada en él. Valores de ensayo de su ficha; no acreditan balance.
var passed := 0
var failed := 0
const PITBULL := preload("res://data/characters/pitbull.tres")
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
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.set_physics_process(false)
	arena.bot.set_physics_process(false)
	arena.human.set_physics_process(false)
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
	actor.velocity = Vector3.ZERO
	actor.move_velocity = Vector3.ZERO
	actor.push_velocity = Vector3.ZERO

func run() -> void:
	# --- Datos del Resource -----------------------------------------------------
	check(CharacterCatalog.AVAILABLE.has(PITBULL) and PITBULL.number == 17 and PITBULL.id == "pitbull", "Pitbull #17 en el catálogo jugable")
	check(PITBULL.max_health == 6400 and is_equal_approx(PITBULL.speed, 5.8) and PITBULL.attack_type == "Melee", "vida 6400, 5,8 m/s, cuerpo a cuerpo")
	check(PITBULL.attack_damage == 900 and is_equal_approx(PITBULL.attack_range, 2.2) and is_equal_approx(PITBULL.attack_interval, 0.62), "Impacto Corto: 900 a 2,2 m cada 0,62 s")
	check(PITBULL.ability.kind == "Shield" and PITBULL.ability.shield_hp == 1000 and is_equal_approx(PITBULL.ability.duration, 2.0) and is_equal_approx(PITBULL.ability.cooldown, 7.0) and is_equal_approx(PITBULL.ability.speed_multiplier, 0.9), "Guardia de Hierro: 1000 de escudo, 2 s, recarga 7 s, 90 % de velocidad")
	check(PITBULL.super_kind == "Field" and PITBULL.super_reach == 0.0 and PITBULL.super_damage == 800 and is_equal_approx(PITBULL.super_radius, 3.0), "Zona de Contención centrada en él: 800, radio 3 m")
	check(is_equal_approx(PITBULL.field_warning, 0.45) and is_equal_approx(PITBULL.field_duration, 4.0) and is_equal_approx(PITBULL.field_slow, 0.2) and is_equal_approx(PITBULL.field_push, 6.0), "aviso 0,45 s, 4 s, lento 20 %, empuje 6 m/s")
	check(PITBULL.ammo == null and PITBULL.model_scene.resource_path.ends_with("pitbull.glb") and PITBULL.field_effect == "pitbull_field", "sin munición, GLB propio y efectos celestes")

	# --- Impacto Corto --------------------------------------------------------------
	var arena := await make_arena(PITBULL, TURBO)
	var me := arena.human
	var rival := arena.bot
	place(me, Vector3(8, 0, 0))
	place(rival, Vector3(9.8, 0, 0))
	me.facing = Vector3.RIGHT
	var health := rival.health
	check(me.act() and rival.health == health - 900, "golpe a 1,8 m resta 900")
	check(not me.act(), "la cadencia de 0,62 s impide repetir de inmediato")
	me.attack_cooldown = 0
	place(rival, Vector3(11.5, 0, 0))
	health = rival.health
	me.act()
	check(rival.health == health, "fuera de 2,2 m no alcanza")
	check(me.position.is_equal_approx(Vector3(8, 0, 0)), "el golpe no desplaza al Pitbull")

	# --- Guardia de Hierro ------------------------------------------------------------
	health = me.health
	check(me.ability() and me.shield_hp == 1000 and is_equal_approx(me.shield_time, 2.0), "activa escudo de 1000 durante 2 s")
	check(me.invulnerable == 0 and me.dash_time == 0, "no es invulnerabilidad ni desplazamiento")
	check(not me.ability(), "recarga de 7 s impide reactivarlo")
	check(me.take_damage(850, Vector3.RIGHT * 5) and me.health == health and me.shield_hp == 150 and me.push_velocity == Vector3.ZERO, "absorbe un impacto entero sin perder vida ni ser empujado")
	me.take_damage(850)
	check(me.shield_hp == 0 and me.health == health - 700, "al romperse, el resto del daño llega a la vida")
	me.cooldown = 0
	me.ability()
	me.shield_time = 0.01
	me._physics_process(DT)
	check(me.shield_hp == 0, "al expirar desaparece el escudo restante")
	me.cooldown = 0
	me.ability()
	me.reset_at_spawn()
	check(me.shield_hp == 0 and me.shield_time == 0, "reaparecer limpia el escudo")
	await dispose(arena)

	# --- Zona de Contención ----------------------------------------------------------------
	arena = await make_arena(PITBULL, TURBO)
	me = arena.human
	rival = arena.bot
	place(me, Vector3(8, 0, 0))
	place(rival, Vector3(8, 0, 2))
	me.super_charge = 100
	var center: Variant = arena.field_target(me)
	check(center != null and (center as Vector3).is_equal_approx(Vector3(8, 0, 0)), "el centro es la posición del propio Pitbull")
	me.super_target = center
	check(me.act("super") and me.super_charge == 0 and is_equal_approx(me.channel_time, 0.45), "consume la súper y prepara 0,45 s")
	check(arena.fields.size() == 1 and arena.fields[0].effect_kind == "pitbull_field", "campo con efectos propios del Pitbull")
	health = rival.health
	for i in 20:
		arena.update_fields(DT)
	check(rival.health == health, "el aviso aún no daña")
	for i in 10:
		arena.update_fields(DT)
	check(rival.health == health - 800 and is_equal_approx(rival.push_velocity.length(), 6.0), "pulso de 800 y empuje de 6 m/s")
	check(rival.push_velocity.normalized().is_equal_approx(Vector3(0, 0, 1)), "el empuje sale desde el Pitbull")
	arena.update_fields(DT)
	check(is_equal_approx(rival.slow, 0.2) and me.slow == 0.0, "rival un 20 % más lento; el dueño no")
	for i in 230:
		arena.update_fields(DT)
	check(arena.fields.size() == 1 and is_equal_approx(rival.slow, 0.2), "la zona sigue activa antes de los 4 s")
	for i in 20:
		arena.update_fields(DT)
	check(arena.fields.is_empty() and rival.slow == 0.0, "termina a los 4 s")
	await dispose(arena)

	# --- Bot ---------------------------------------------------------------------------------
	arena = await make_arena(TURBO, PITBULL)
	var bot := arena.bot
	place(arena.human, Vector3(8, 0, 0))
	place(bot, Vector3(10.5, 0, 0))
	bot.super_charge = 100
	arena.brain.update(bot, arena.human, arena.projectiles, DT, arena.fields)
	check(bot.command.super_shot and (bot.super_target as Vector3).is_equal_approx(Vector3(10.5, 0, 0)), "bot activa la zona con el rival dentro del radio")
	check(bot.command.ability, "bot levanta el escudo con el rival encima")
	place(arena.human, Vector3(2, 0, 0))
	bot.super_charge = 100
	arena.brain.update(bot, arena.human, arena.projectiles, DT, arena.fields)
	check(not bot.command.super_shot and not bot.command.ability, "lejos no gasta súper ni escudo")
	await dispose(arena)

	# --- Efectos ------------------------------------------------------------------------------
	var effect := AbilityEffect.new()
	effect.kind = "pitbull_field_warning"
	effect.radius = 3.0
	effect.duration = 0.45
	root.add_child(effect)
	check(effect.kind == "principe_field_warning" and effect.edge == VFXKit.PITBULL_SKY, "aviso del Pitbull con paleta celeste")
	effect.queue_free()
	var guard := AbilityEffect.new()
	guard.kind = "pitbull_guard"
	guard.duration = 2.0
	root.add_child(guard)
	check(guard.parts.size() == 3 and is_equal_approx(guard.life, 2.0), "burbuja de guardia dura lo que el escudo")
	guard.queue_free()
	await process_frame

	print("PITBULL: %d aprobadas; %d fallos" % [passed, failed])
	quit(1 if failed else 0)
