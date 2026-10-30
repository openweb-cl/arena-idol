extends SceneTree
## Capturas reales de Turbo #11 y Rey/King #23 (muestras provisionales) en
## selección, arenas A/B y tiras de clips con el AnimationPlayer importado.
## Requiere display (Xvfb sirve); no acredita rendimiento Android. Uso:
## xvfb-run godot --path game --audio-driver Dummy [--rendering-method gl_compatibility] \
##   --script ../art/lib/capture_heroes.gd -- --output=/ruta
var output := "/tmp/heroes-capturas"

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

func zoom(name: String, camera: Camera3D, actor: Node3D) -> void:
	## Recorte ampliado x3 del mismo frame, sin re-render.
	var screen := camera.unproject_position(actor.global_position + Vector3(0, 1, 0))
	var image := root.get_texture().get_image()
	var region := Rect2i(Vector2i(screen) - Vector2i(110, 75), Vector2i(220, 150)).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var crop := image.get_region(region)
	crop.resize(region.size.x * 3, region.size.y * 3, Image.INTERPOLATE_NEAREST)
	crop.save_png(output.path_join(name + ".png"))
	print("CAPTURE ", name, " ", crop.get_size())

func arena_shot(layout: ArenaDefinition, name: String, human_def: CharacterDefinition) -> int:
	GameSession.selected_arena = layout
	GameSession.selected = human_def
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.set_physics_process(false)
	arena.aim_guide.hide()
	arena.human.position = Vector3(-2.6, 0, 1.7)
	arena.bot.position = Vector3(2.4, 0, 1.7)
	arena.human.facing = Vector3.RIGHT
	arena.bot.facing = Vector3.LEFT
	await frames(8)
	arena.hud.update_state(arena.rules, arena.human)
	await frames(2)
	var calls := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	capture(name)
	zoom(name + "-zoom-" + arena.human.definition.id, arena.camera, arena.human)
	zoom(name + "-zoom-" + arena.bot.definition.id, arena.camera, arena.bot)
	arena.queue_free()
	await frames(2)
	return calls

func run() -> void:
	var turbo: CharacterDefinition = load("res://data/characters/turbo.tres")
	var rey: CharacterDefinition = load("res://data/characters/rey.tres")
	GameSession.selected = turbo
	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	await frames(10)
	capture("00-menu")
	menu.show_selection()
	await frames(10)
	capture("01-seleccion-turbo")
	menu.select_character(rey)
	await frames(10)
	capture("02-seleccion-rey")
	menu.queue_free()
	await frames(2)
	var calls_a := await arena_shot(GameSession.ARENAS[0], "03-arena-a", turbo)
	var calls_b := await arena_shot(GameSession.ARENAS[1], "04-arena-b", rey)
	# Referencia con los placeholders procedurales (solo en memoria, sin guardar recursos).
	var scenes := [turbo.model_scene, rey.model_scene]
	turbo.model_scene = null
	rey.model_scene = null
	var calls_placeholder := await arena_shot(GameSession.ARENAS[0], "90-referencia-placeholders", turbo)
	turbo.model_scene = scenes[0]
	rey.model_scene = scenes[1]
	print("DRAW_CALLS arena_A_glb=%d arena_B_glb=%d arena_A_placeholders=%d" % [calls_a, calls_b, calls_placeholder])
	await clip_strip(turbo, "05-clips-turbo")
	await clip_strip(rey, "06-clips-rey")
	# Héroes solo de arte (sin gameplay ni .tres): definiciones temporales en memoria.
	var principe := art_only("principe")
	var pitbull := art_only("pitbull")
	await clip_strip(principe, "07-clips-principe")
	await clip_strip(pitbull, "08-clips-pitbull")
	await lineup([turbo, rey, principe, pitbull])
	quit()

func art_only(id: String) -> CharacterDefinition:
	var definition := CharacterDefinition.new()
	definition.id = id
	definition.model_scene = load("res://assets/models/%s/%s.glb" % [id, id])
	return definition

func lineup(definitions: Array) -> void:
	## Los cuatro héroes en idle: vista frontal y vista con la inclinación de la cámara de juego.
	var world := Node3D.new()
	root.add_child(world)
	ArenaGeometry.world(world)
	ArenaGeometry.box(world, Vector3(0, -0.1, 0), Vector3(14, 0.2, 6), Color("1d5c4e"))
	for i in definitions.size():
		var visual := CharacterVisual.new()
		visual.definition = definitions[i]
		visual.position = Vector3(-3.3 + i * 2.2, 0, 0)
		visual.rotation_degrees.y = 180 + 20
		world.add_child(visual)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 5.2
	camera.position = Vector3(0, 2.4, 8)
	world.add_child(camera)
	camera.look_at(Vector3(0, 1.0, 0))
	camera.current = true
	await frames(8)
	capture("09-plantel-frente")
	camera.size = 7.5
	camera.position = Vector3(0, 9.5, 8)
	camera.look_at(Vector3(0, 0.8, 0))
	await frames(4)
	capture("10-plantel-camara-juego")
	world.queue_free()
	await frames(1)

func clip_strip(definition: CharacterDefinition, name: String) -> void:
	## Cinco instancias reales del GLB, cada una congelada en un instante de su clip.
	var world := Node3D.new()
	root.add_child(world)
	ArenaGeometry.world(world)
	ArenaGeometry.box(world, Vector3(0, -0.1, 0), Vector3(16, 0.2, 5), Color("1d5c4e"))
	var poses := [["idle", 0.0], ["run", 0.0], ["kick", 0.13], ["hit", 0.07], ["celebrate", 0.37]]
	for i in poses.size():
		var visual := CharacterVisual.new()
		visual.definition = definition
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
		label.position = Vector3(-6 + i * 3, 2.7, 0)
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
	capture(name)
	world.queue_free()
	await frames(1)
