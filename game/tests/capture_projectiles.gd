extends SceneTree
## Capturas de disparos resueltos por física; escenarios preparados, sin retocar imágenes.
var output := "/tmp/arena-projectiles"

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
	var code := root.get_texture().get_image().save_png(output.path_join(name + ".png"))
	if code != OK:
		push_error("No se pudo guardar " + name)
		quit(1)
	print("CAPTURE ", name)

func run() -> void:
	var arena: IdolArena = load("res://scenes/training/projectile_range.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	await frames(5)
	for case in [2, 3, 4]:
		arena.set_training_case(case)
		await frames(4)
		var event := InputEventMouseButton.new()
		event.position = arena.camera.unproject_position(arena.bot.global_position + Vector3.UP)
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = true
		root.push_input(event, true)
		await frames(12)
		if case == 2:
			capture("01-projectile-in-flight")
		await frames(38)
		capture(["", "", "02-impact", "03-cover", "04-range-expired"][case])
	arena.queue_free()
	await process_frame
	quit()
