extends SceneTree
## Capturas de escenas reales, estados preparados para revisión de interfaz.
## Ejecutar con display real; no con --headless. No es un benchmark Android.
var output := "/tmp/arena-captures"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):
			output = arg.trim_prefix("--output=")
	DirAccess.make_dir_recursive_absolute(output)
	call_deferred("run")

func capture(name: String) -> void:
	for i in 3:
		await process_frame
		await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var result := image.save_png(output.path_join(name + ".png"))
	if result != OK:
		push_error("No se pudo guardar " + name)
		quit(1)
	print("CAPTURE ", name, " ", image.get_size())

func run() -> void:
	GameSession.selected = CharacterCatalog.AVAILABLE[0]
	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	await capture("01-menu")
	menu.show_selection()
	await capture("02-selection-turbo")
	menu.select_character(CharacterCatalog.AVAILABLE[1])
	await capture("03-selection-rey")
	menu.queue_free()
	await process_frame
	GameSession.selected = CharacterCatalog.AVAILABLE[0]
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	arena.set_physics_process(false)
	arena.human.position = Vector3(-4, 0, 1.7)
	arena.bot.position = Vector3(3, 0, 1.7)
	arena.bot.command.move = Vector2.ZERO
	arena.human.facing = Vector3.RIGHT
	arena.bot.facing = Vector3.LEFT
	arena.hud.update_state(arena.rules, arena.human)
	await capture("04-arena")
	arena.human.super_charge = 100
	arena.human.act("super")
	arena.hud.update_state(arena.rules, arena.human)
	await capture("05-super-turbo")
	arena.rules.scores = [5, 2]
	arena.rules.end()
	await capture("06-result")
	arena.queue_free()
	await process_frame
	quit()
