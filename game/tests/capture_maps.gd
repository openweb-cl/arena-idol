extends SceneTree
var output := "/tmp/arena-maps"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await process_frame
		await RenderingServer.frame_post_draw

func capture(name: String) -> void:
	if root.get_texture().get_image().save_png(output.path_join(name + ".png")) != OK:
		push_error("No se pudo guardar " + name)
		quit(1)
	print("CAPTURE ", name)

func run() -> void:
	GameSession.selected_arena = GameSession.ARENAS[1]
	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	await frames(4)
	capture("01-menu-map-selector")
	menu.queue_free()
	await frames(1)
	for layout in GameSession.ARENAS:
		GameSession.selected_arena = layout
		var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
		root.add_child(arena)
		current_scene = arena
		arena.set_physics_process(false)
		arena.aim_guide.hide()
		await frames(5)
		arena.hud.update_state(arena.rules, arena.human)
		await frames(1)
		capture("02-" + layout.id)
		arena.queue_free()
		await frames(1)
	quit()
