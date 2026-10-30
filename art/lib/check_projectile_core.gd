extends SceneTree
## Verificación medible: el núcleo amarillo del proyectil de Turbo debe verse
## desde la cámara de juego (básico y súper). Mide, en la imagen renderizada, la
## fracción de píxeles con color de núcleo dentro del disco proyectado del núcleo.
## Requiere display (Xvfb sirve). Uso:
## xvfb-run godot --path game --audio-driver Dummy --fixed-fps 60 \
##   --script ../art/lib/check_projectile_core.gd -- --output=/ruta [--low]
const MIN_VISIBLE := 0.75  ## fracción mínima de píxeles de núcleo en el disco del núcleo
const DISC := 0.85  ## parte del radio proyectado que se mide (evita el antialias del borde)
var output := "/tmp/proyectil-nucleo"
var low := false
var failed := 0

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

func is_core(c: Color) -> bool:
	return c.r > 0.8 and c.g > 0.72 and c.b < 0.82 and c.r - c.b > 0.12

func run() -> void:
	var profile := "BAJO" if low else "ALTO"
	for kind in ["shot", "super"]:
		GameSession.selected_arena = GameSession.ARENAS[0]
		GameSession.selected = load("res://data/characters/turbo.tres")
		var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
		root.add_child(arena)
		current_scene = arena
		arena.aim_guide.hide()
		arena.bot.set_physics_process(false)
		arena.bot.position = Vector3(6.5, 0, -3.0)
		arena.human.position = Vector3(-6.0, 0, -1.5)
		arena.human.facing = Vector3.RIGHT
		await frames(4)
		arena.human.attack_cooldown = 0
		if kind == "super":
			arena.human.super_charge = 100
		arena.human.act(kind)
		await frames(6 if kind == "super" else 10)
		var projectile: CombatProjectile = arena.projectiles.back() if not arena.projectiles.is_empty() else null
		if projectile == null or not is_instance_valid(projectile):
			print("  FALLO  %s %s: no hay proyectil en vuelo" % [profile, kind])
			failed += 1
			arena.queue_free()
			await frames(2)
			continue
		var image := root.get_texture().get_image()
		var camera := arena.camera
		var center := camera.unproject_position(projectile.global_position)
		var radius_world := 0.32 if kind == "super" else 0.16
		var edge := camera.unproject_position(projectile.global_position + camera.global_transform.basis.x * radius_world)
		var radius_px := center.distance_to(edge)
		var inner := radius_px * DISC
		var total := 0
		var hits := 0
		for y in range(int(center.y - inner), int(center.y + inner) + 1):
			for x in range(int(center.x - inner), int(center.x + inner) + 1):
				if Vector2(x, y).distance_to(center) <= inner and x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
					total += 1
					if is_core(image.get_pixel(x, y)):
						hits += 1
		var ratio := float(hits) / maxf(1, total)
		var ok := ratio >= MIN_VISIBLE
		if not ok:
			failed += 1
		print("  %s  %s %s: núcleo visible %.0f%% (%d/%d px, radio proyectado %.1f px)" % ["OK" if ok else "FALLO", profile, kind, ratio * 100, hits, total, radius_px])
		var crop_rect := Rect2i(Vector2i(center) - Vector2i(60, 45), Vector2i(120, 90)).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
		var crop := image.get_region(crop_rect)
		crop.resize(crop_rect.size.x * 4, crop_rect.size.y * 4, Image.INTERPOLATE_NEAREST)
		crop.save_png(output.path_join("proyectil-%s-%s.png" % [kind, profile.to_lower()]))
		image.save_png(output.path_join("arena-%s-%s.png" % [kind, profile.to_lower()]))
		arena.queue_free()
		await frames(2)
	print("NÚCLEO PROYECTIL %s: %d fallos" % [profile, failed])
	quit(1 if failed else 0)
