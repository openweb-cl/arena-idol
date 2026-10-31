extends SceneTree
## Capturas reales del Príncipe #20 jugable: selección, menú con rival, mejora de
## poder, aviso y pulso del Campo de Dominio. No acredita rendimiento Android. Uso:
## godot --path game --audio-driver Dummy --script ../art/lib/capture_principe.gd -- --output=/ruta
var output := "/tmp/principe-capturas"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):
			output = arg.trim_prefix("--output=")
	DirAccess.make_dir_recursive_absolute(output)
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await process_frame
		await RenderingServer.frame_post_draw

func capture(name: String) -> void:
	var image := root.get_texture().get_image()
	if image.save_png(output.path_join(name + ".png")) != OK:
		push_error("No se pudo guardar " + name)
		quit(1)
	print("CAPTURE ", name, " ", image.get_size())

func crop(name: String, camera: Camera3D, at: Vector3, size: Vector2i) -> void:
	## Recorte ampliado x2 del mismo frame, sin re-render.
	var screen := camera.unproject_position(at)
	var image := root.get_texture().get_image()
	var region := Rect2i(Vector2i(screen) - size / 2, size).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var part := image.get_region(region)
	part.resize(region.size.x * 2, region.size.y * 2, Image.INTERPOLATE_BILINEAR)
	part.save_png(output.path_join(name + ".png"))
	print("CAPTURE ", name, " ", part.get_size())

func run() -> void:
	var principe: CharacterDefinition = load("res://data/characters/principe.tres")
	var turbo: CharacterDefinition = load("res://data/characters/turbo.tres")
	GameSession.selected = principe
	GameSession.selected_rival = turbo
	GameSession.selected_arena = GameSession.ARENAS[0]
	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	await frames(10)
	capture("01-menu-principe-rival")
	menu.show_selection()
	await frames(10)
	capture("02-seleccion-principe")
	menu.queue_free()
	await frames(2)

	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.set_physics_process(false)
	arena.bot.set_physics_process(false)
	arena.aim_guide.hide()
	var me := arena.human
	var rival := arena.bot
	me.position = Vector3(-2.5, 0, 5.4)
	rival.position = Vector3(2.6, 0, 5.2)
	me.facing = Vector3.RIGHT
	rival.facing = Vector3.LEFT
	await frames(8)
	me.invulnerable = 0
	rival.invulnerable = 0
	me.ability()
	await frames(14)
	arena.hud.update_state(arena.rules, me)
	capture("03-arena-impulso-tactico")
	crop("03-arena-impulso-tactico-zoom", arena.camera, me.global_position + Vector3(0, 1.4, 0), Vector2i(300, 240))
	me.super_charge = 100
	me.super_target = Vector3(rival.position.x, 0, rival.position.z)
	me.act("super")
	for i in 6:
		arena.update_fields(1.0 / 60)
		await frames(1)
	capture("04-campo-aviso")
	crop("04-campo-aviso-zoom", arena.camera, Vector3(rival.position.x, 0.5, rival.position.z), Vector2i(420, 300))
	for i in 32:
		arena.update_fields(1.0 / 60)
	await frames(2)
	capture("05-campo-pulso")
	crop("05-campo-pulso-zoom", arena.camera, Vector3(2.6, 0.5, 5.2), Vector2i(420, 300))
	for i in 40:
		arena.update_fields(1.0 / 60)
		await frames(1)
	arena.hud.update_state(arena.rules, me)
	capture("06-campo-lento")
	print("PRINCIPE_CAPTURE rival_health=%d slow=%.2f" % [rival.health, rival.slow])
	arena.queue_free()
	await frames(2)
	GameSession.selected_rival = null
	quit(0)
