extends SceneTree
var output := "/tmp/arena-reload"

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
	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	await frames(4)
	capture("01-menu-reload-rules")
	menu.queue_free()
	await frames(1)
	var arena: IdolArena = load("res://scenes/training/projectile_range.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.set_training_case(2)
	await frames(4)
	capture("02-three-charges")
	var event := InputEventMouseButton.new()
	event.position = arena.camera.unproject_position(arena.bot.global_position + Vector3.UP)
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event, true)
	await frames(65)
	event.pressed = false
	root.push_input(event, true)
	capture("03-empty-reloading")
	await frames(30)
	capture("04-one-charge-restored")
	arena.queue_free()
	await process_frame
	quit()
