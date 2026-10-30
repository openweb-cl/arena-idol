extends SceneTree
## Capturas reales del refresh visual de las arenas A y B (V2 provisional), con
## Turbo y Rey en escena, y conteo de draw calls. Requiere display (Xvfb sirve).
## xvfb-run godot --path game --audio-driver Dummy --fixed-fps 60 \
##   --script ../art/lib/capture_arena.gd -- --output=/ruta [--low]
var output := "/tmp/arena-capturas"
var low := false

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):
			output = arg.trim_prefix("--output=")
		elif arg == "--low":
			low = true
	GraphicsSettings.low = low
	DirAccess.make_dir_recursive_absolute(output)
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await process_frame
		await RenderingServer.frame_post_draw

func run() -> void:
	var suffix := "-bajo" if low else ""
	var report := []
	for index in GameSession.ARENAS.size():
		var layout: ArenaDefinition = GameSession.ARENAS[index]
		GameSession.selected_arena = layout
		GameSession.selected = load("res://data/characters/turbo.tres")
		var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
		root.add_child(arena)
		current_scene = arena
		arena.set_physics_process(false)
		arena.aim_guide.hide()
		arena.human.position = Vector3(-3.0, 0, 2.0)
		arena.bot.position = Vector3(3.2, 0, -2.0)
		arena.human.facing = Vector3.RIGHT
		arena.bot.facing = Vector3.LEFT
		await frames(8)
		arena.hud.update_state(arena.rules, arena.human)
		await frames(2)
		var calls := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var prims := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		report.append("%s draw_calls=%d primitivas=%d" % [layout.id, calls, prims])
		var image := root.get_texture().get_image()
		image.save_png(output.path_join("arena-%s%s.png" % [layout.id, suffix]))
		var screen := arena.camera.unproject_position(arena.human.global_position + Vector3(0, 1, 0))
		var region := Rect2i(Vector2i(screen) - Vector2i(160, 110), Vector2i(320, 220)).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
		var crop := image.get_region(region)
		crop.resize(region.size.x * 2, region.size.y * 2, Image.INTERPOLATE_NEAREST)
		crop.save_png(output.path_join("arena-%s-zoom%s.png" % [layout.id, suffix]))
		print("CAPTURE ", layout.id)
		arena.queue_free()
		await frames(2)
	print("ARENA_METRICS ", " | ".join(report))
	quit()
