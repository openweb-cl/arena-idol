extends SceneTree
## Capturas reales con entradas preparadas. No sustituye un teléfono multitáctil.
var output := "/tmp/arena-touch-captures"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
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

func contact(index: int, at: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = at
	event.pressed = pressed
	root.push_input(event, true)

func run() -> void:
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	arena.force_touch_controls = true
	root.add_child(arena)
	current_scene = arena
	arena.bot.set_physics_process(false)
	arena.human.position = Vector3(-5, 0, 1.7)
	arena.bot.position = Vector3(3, 0, 1.7)
	await frames(8)
	var controls := arena.touch_controls
	capture("01-auto")
	contact(0, controls.centers.move + Vector2(-45, 0), true)
	contact(1, controls.centers.attack, true)
	await frames(8)
	capture("02-move-and-attack")
	contact(0, Vector2.ZERO, false)
	contact(1, Vector2.ZERO, false)
	arena.set_auto_target(false)
	contact(1, controls.centers.attack + Vector2(55, -25), true)
	await frames(3)
	capture("03-manual")
	contact(1, Vector2.ZERO, false)
	controls.set_safe_rect(Rect2(80, 24, 1120, 672))
	await frames(2)
	capture("04-safe-area-simulated")
	contact(2, controls.centers.pause, true)
	await frames(2)
	capture("05-pause")
	arena.queue_free()
	await frames(2)
	quit()
