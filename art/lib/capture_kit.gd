extends SceneTree
## Capturas reales de un héroe jugable con habilidad y súper de zona: menú con
## rival, selección, habilidad activa, aviso, pulso y campo. No acredita Android. Uso:
## godot --path game --audio-driver Dummy --script ../art/lib/capture_kit.gd -- --hero=principe --output=/ruta
var output := "/tmp/kit-capturas"
var hero := "principe"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):
			output = arg.trim_prefix("--output=")
		if arg.begins_with("--hero="):
			hero = arg.trim_prefix("--hero=")
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
	var own: CharacterDefinition = load("res://data/characters/%s.tres" % hero)
	var turbo: CharacterDefinition = load("res://data/characters/turbo.tres")
	GameSession.selected = own
	GameSession.selected_rival = turbo
	GameSession.selected_arena = GameSession.ARENAS[0]
	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	await frames(10)
	capture("01-menu-%s-rival" % hero)
	menu.show_selection()
	await frames(10)
	capture("02-seleccion-%s" % hero)
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
	capture("03-arena-habilidad")
	crop("03-arena-habilidad-zoom", arena.camera, me.global_position + Vector3(0, 1.4, 0), Vector2i(300, 240))
	me.super_charge = 100
	if own.super_reach <= 0.01:  # zona centrada en el propio héroe: acercarlo al rival
		me.position = rival.position + Vector3(-1.8, 0, 0)
		await frames(2)
	me.super_target = arena.field_target(me) if own.super_reach <= 0.01 else Vector3(rival.position.x, 0, rival.position.z)
	me.act("super")
	for i in 6:
		arena.update_fields(1.0 / 60)
		await frames(1)
	capture("04-campo-aviso")
	crop("04-campo-aviso-zoom", arena.camera, Vector3(rival.position.x, 0.5, rival.position.z), Vector2i(460, 320))
	for i in 32:
		arena.update_fields(1.0 / 60)
	await frames(2)
	capture("05-campo-pulso")
	crop("05-campo-pulso-zoom", arena.camera, Vector3(rival.position.x, 0.5, rival.position.z), Vector2i(460, 320))
	for i in 40:
		arena.update_fields(1.0 / 60)
		await frames(1)
	arena.hud.update_state(arena.rules, me)
	capture("06-campo-lento")
	print("KIT_CAPTURE %s rival_health=%d slow=%.2f" % [hero, rival.health, rival.slow])
	arena.queue_free()
	await frames(2)
	GameSession.selected_rival = null
	quit(0)
