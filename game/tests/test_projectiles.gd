extends SceneTree
## Regresión: cursor en torso visible, no solo en el origen de los pies.
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
	GameSession.selected = CharacterCatalog.AVAILABLE[0]
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.bot.set_physics_process(false)
	# Cursor sobre el torso: paralaje de altura frente a la línea horizontal.
	arena.human.position = Vector3(-10, 0, -2)
	arena.bot.position = Vector3(2, 0, -2)
	await frames(3)
	var cursor := arena.camera.unproject_position(arena.bot.global_position + Vector3.UP)
	var motion := InputEventMouseMotion.new()
	motion.position = cursor
	root.push_input(motion, true)
	await frames(3)
	var mouse := InputEventMouseButton.new()
	mouse.position = cursor
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	root.push_input(mouse, true)
	await frames(55)
	check(arena.bot.health == arena.bot.definition.max_health - arena.human.definition.attack_damage, "cursor en torso del Rey inmóvil impacta")
	arena.queue_free()
	await process_frame
	print("PROYECTILES: %d aprobadas; %d fallos" % [passed, failed])
	quit(0 if failed == 0 else 1)
