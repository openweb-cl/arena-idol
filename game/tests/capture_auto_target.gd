extends SceneTree
var output := "/tmp/arena-auto-target"

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
	arena.auto_target_enabled = true
	await frames(4)
	capture("01-target-selected")
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = Vector2(100, 400) # Cursor lejos del Rey: apunta la asistencia.
	event.pressed = true
	root.push_input(event, true)
	await frames(1)
	event.pressed = false
	root.push_input(event, true)
	await frames(15)
	capture("02-auto-aim-impact")
	arena.bot.invulnerable = 1.5
	await frames(15)
	event.pressed = true
	root.push_input(event, true)
	await frames(1)
	event.pressed = false
	root.push_input(event, true)
	await frames(15)
	capture("03-protected-target")
	arena.queue_free()
	await process_frame
	quit()
