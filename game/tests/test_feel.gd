extends SceneTree
## Sensación de juego: orientación del cuerpo, números de daño, aplastamiento,
## sacudida de cámara y polvo. Todo es presentación: no cambia reglas de combate.
var passed := 0
var failed := 0
const TURBO := preload("res://data/characters/turbo.tres")
const REY := preload("res://data/characters/rey.tres")

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

func facing_angle(direction: Vector3) -> float:
	return atan2(-direction.x, -direction.z)

func run() -> void:
	GameSession.selected = TURBO
	GameSession.selected_rival = REY
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.set_physics_process(false)
	arena.bot.set_physics_process(false)
	await frames(2)
	var me := arena.human
	me.invulnerable = 0
	arena.bot.invulnerable = 0
	me.position = Vector3(-8, 0, 0)
	arena.bot.position = Vector3(8, 0, 0)

	# --- Orientación -------------------------------------------------------------------
	var dusts := []
	me.kicked_up_dust.connect(func(actor: ArenaPlayer) -> void: dusts.append(actor))
	me.command.aim = Vector2.RIGHT
	me.command.move = Vector2(0, 1)
	await frames(24)
	check(absf(angle_difference(me.visual.rotation.y, facing_angle(Vector3.BACK))) < 0.2, "con apuntado AUTO, el cuerpo mira hacia donde corre")
	check(me.facing.is_equal_approx(Vector3.RIGHT), "la dirección de ataque sigue siendo la del apuntado")
	check(dusts.size() == 1, "arrancar desde quieto levanta polvo una vez")
	me.attack_cooldown = 0
	me.act()
	await frames(10)
	check(absf(angle_difference(me.visual.rotation.y, facing_angle(Vector3.RIGHT))) < 0.25, "al atacar se gira hacia el blanco")
	await frames(40)
	check(absf(angle_difference(me.visual.rotation.y, facing_angle(Vector3.BACK))) < 0.25, "pasado el ataque vuelve a mirar hacia donde corre")
	me.command.move = Vector2(0, -1)
	await frames(4)
	check(dusts.size() == 2, "invertir la marcha levanta polvo")
	me.command.move = Vector2.ZERO
	me.command.aim = Vector2.ZERO

	# --- Números de daño y aplastamiento ------------------------------------------------------
	for child in arena.get_children():
		if child is DamageNumber:
			child.free()
	arena.apply_damage(arena.bot, me, 850, Vector3.ZERO)
	var numbers := arena.get_children().filter(func(n: Node) -> bool: return n is DamageNumber)
	check(numbers.size() == 1 and (numbers[0] as DamageNumber).text == "−850", "un impacto muestra su daño real")
	await frames(3)
	check(arena.bot.visual.model.scale.y < 0.99, "el golpeado se aplasta un instante")
	await frames(52)
	check(is_equal_approx(arena.bot.visual.model.scale.y, arena.bot.definition.model_scale.y), "y recupera su escala")
	check(arena.get_children().filter(func(n: Node) -> bool: return n is DamageNumber).is_empty(), "el número desaparece solo")
	arena.bot.shield_hp = 1000
	arena.bot.shield_time = 2.0
	arena.apply_damage(arena.bot, me, 850, Vector3.ZERO)
	numbers = arena.get_children().filter(func(n: Node) -> bool: return n is DamageNumber)
	check(numbers.size() == 1 and (numbers[0] as DamageNumber).text.begins_with("ESCUDO"), "el daño absorbido por escudo se muestra aparte")

	# --- Cámara ----------------------------------------------------------------------------------
	arena.camera.trauma = 0
	arena.apply_damage(arena.bot, me, TURBO.super_damage, Vector3.ZERO)
	check(arena.camera.trauma > 0.3, "un golpe de súper sacude la cámara")
	var position := arena.camera.global_position
	await frames(90)
	check(arena.camera.trauma == 0.0 and absf(arena.camera.h_offset) < 0.001 and absf(arena.camera.v_offset) < 0.001, "la sacudida se apaga sola")
	check(arena.camera.global_position.is_equal_approx(position), "la cámara no se mueve: solo desplaza la imagen")

	arena.queue_free()
	await process_frame
	GameSession.selected_rival = null
	print("SENSACIÓN: %d aprobadas; %d fallos" % [passed, failed])
	quit(1 if failed else 0)
