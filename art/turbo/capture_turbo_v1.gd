extends SceneTree
## Capturas reales de El Turbo #11 V1 (muestra provisional) en selección, arenas
## A/B y una tira de clips con el AnimationPlayer importado. Requiere display
## (Xvfb sirve); no acredita rendimiento Android. Uso:
## xvfb-run godot --path game --rendering-method gl_compatibility --audio-driver Dummy \
##   --script ../art/turbo/capture_turbo_v1.gd -- --output=/ruta
var output := "/tmp/turbo-v1"

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

func draw_calls() -> int:
	return RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)

func arena_shot(layout: ArenaDefinition, name: String, human_def: CharacterDefinition) -> int:
	GameSession.selected_arena = layout
	GameSession.selected = human_def
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.set_physics_process(false)
	arena.aim_guide.hide()
	arena.human.position = Vector3(-3.2, 0, 1.7)
	arena.bot.position = Vector3(3.0, 0, 1.7)
	arena.human.facing = Vector3.RIGHT
	arena.bot.facing = Vector3.LEFT
	arena.human.visual.speed_ratio = 1.0
	await frames(8)
	arena.hud.update_state(arena.rules, arena.human)
	await frames(2)
	var calls := draw_calls()
	capture(name)
	# Recorte ampliado x3 alrededor del Turbo (mismo frame, sin re-render).
	var turbo_actor := arena.human if human_def.id == "turbo" else arena.bot
	var screen := arena.camera.unproject_position(turbo_actor.global_position + Vector3(0, 1, 0))
	var image := root.get_texture().get_image()
	var region := Rect2i(Vector2i(screen) - Vector2i(110, 75), Vector2i(220, 150)).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var crop := image.get_region(region)
	crop.resize(region.size.x * 3, region.size.y * 3, Image.INTERPOLATE_NEAREST)
	crop.save_png(output.path_join(name + "-zoom.png"))
	print("CAPTURE ", name, "-zoom ", crop.get_size())
	arena.queue_free()
	await frames(2)
	return calls

func run() -> void:
	var turbo: CharacterDefinition = load("res://data/characters/turbo.tres")
	var rey: CharacterDefinition = load("res://data/characters/rey.tres")
	GameSession.selected = turbo
	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	menu.show_selection()
	await frames(12)
	capture("01-seleccion-turbo")
	menu.queue_free()
	await frames(2)
	var calls_a := await arena_shot(GameSession.ARENAS[0], "02-arena-a-turbo", turbo)
	var calls_b := await arena_shot(GameSession.ARENAS[1], "03-arena-b-turbo", turbo)
	# Comparación de draw calls con el placeholder procedural (solo en memoria).
	var glb := turbo.model_scene
	turbo.model_scene = null
	var calls_placeholder := await arena_shot(GameSession.ARENAS[0], "90-referencia-placeholder", turbo)
	turbo.model_scene = glb
	await arena_shot(GameSession.ARENAS[1], "05-arena-b-turbo-bot", rey)
	print("DRAW_CALLS arena_A_glb=%d arena_B_glb=%d arena_A_placeholder=%d" % [calls_a, calls_b, calls_placeholder])
	await clip_strip(turbo)
	quit()

func clip_strip(turbo: CharacterDefinition) -> void:
	## Cinco instancias reales del GLB, cada una congelada en un instante de su clip.
	var world := Node3D.new()
	root.add_child(world)
	ArenaGeometry.world(world)
	ArenaGeometry.box(world, Vector3(0, -0.1, 0), Vector3(16, 0.2, 5), Color("1d5c4e"))
	var poses := [["idle", 0.0], ["run", 0.0], ["kick", 0.13], ["hit", 0.07], ["celebrate", 0.37]]
	for i in poses.size():
		var visual := CharacterVisual.new()
		visual.definition = turbo
		visual.position = Vector3(-6 + i * 3, 0, 0)
		visual.rotation_degrees.y = 180 + 35  # frente del modelo (-Z) hacia la cámara
		world.add_child(visual)
		await process_frame
		visual.set_process(false)
		visual.animation_player.play(poses[i][0])
		visual.animation_player.seek(poses[i][1], true)
		visual.animation_player.pause()
		var label := Label3D.new()
		label.text = poses[i][0]
		label.font_size = 48
		label.position = Vector3(-6 + i * 3, 2.6, 0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		world.add_child(label)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 7.5
	camera.position = Vector3(0, 3.2, 8)
	world.add_child(camera)
	camera.look_at(Vector3(0, 1.1, 0))
	camera.current = true
	await frames(6)
	capture("04-clips-godot")
	world.queue_free()
	await frames(1)
