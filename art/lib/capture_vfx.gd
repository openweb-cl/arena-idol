extends SceneTree
## Capturas reales de los VFX V1 (provisionales): una ficha por efecto en su pico
## y momentos de combate en la arena A. Requiere display (Xvfb sirve). Uso:
## xvfb-run godot --path game --audio-driver Dummy --fixed-fps 60 \
##   --script ../art/lib/capture_vfx.gd -- --output=/ruta [--low]
## No acredita rendimiento Android: los draw calls son conteos en este equipo.
var output := "/tmp/vfx-capturas"
var low := false
const TILE := Vector2i(400, 300)
const EFFECTS := [
	["shot", "turbo", 0.35], ["turbo_sprint", "turbo", 0.3], ["turbo_super", "turbo", 0.3],
	["hit", "turbo", 0.3], ["shield", "turbo", 0.2], ["melee", "rey", 0.35],
	["rey_charge", "rey", 0.25], ["rey_super", "rey", 0.45], ["impact_cover", "", 0.3],
	["elimination", "rey", 0.25],
]

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

func draw_calls() -> int:
	return RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)

func save(image: Image, name: String) -> void:
	if image.save_png(output.path_join(name + ".png")) != OK:
		push_error("No se pudo guardar " + name)
		quit(1)
	print("CAPTURE ", name, " ", image.get_size())

func run() -> void:
	var suffix := "-bajo" if low else ""
	await effect_sheet(suffix)
	await principe_sheet(suffix)
	await arena_moments(suffix)
	quit()

func effect_sheet(suffix: String) -> void:
	var sheet := Image.create(TILE.x * 5, TILE.y * 2, false, Image.FORMAT_RGBA8)
	var defs := {"turbo": load("res://data/characters/turbo.tres"), "rey": load("res://data/characters/rey.tres")}
	var report := []
	for i in EFFECTS.size():
		var spec: Array = EFFECTS[i]
		var world := Node3D.new()
		root.add_child(world)
		ArenaGeometry.world(world)
		ArenaGeometry.box(world, Vector3(0, -0.1, 0), Vector3(14, 0.2, 10), Color("2f9c7c"))
		if spec[0] == "impact_cover":
			ArenaGeometry.box(world, Vector3(0, 0.9, -0.35), Vector3(2.0, 1.8, 0.6), Color("8ec9ef"))
		var actor: Node3D = null
		if spec[1] != "":
			var visual := CharacterVisual.new()
			visual.definition = defs[spec[1]]
			visual.rotation_degrees.y = 180 + 30
			world.add_child(visual)
			actor = visual
			if spec[0] == "elimination":
				visual.visible = false
		var effect := AbilityEffect.new()
		effect.kind = spec[0]
		effect.quality = not low
		effect.color = (defs[spec[1]] as CharacterDefinition).color if spec[1] != "" else Color.WHITE
		effect.radius = 4.5
		effect.position = Vector3(0, 0.9, 0) if spec[0] == "impact_cover" else Vector3.ZERO
		effect.rotation_degrees.y = 180 + 30 if actor != null else 0
		world.add_child(effect)
		var camera := Camera3D.new()
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 10.0 if spec[0] == "rey_super" else 3.6
		camera.position = Vector3(0, 6.5, 6.0) if spec[0] == "rey_super" else Vector3(0, 2.6, 5.0)
		world.add_child(camera)
		camera.look_at(Vector3(0, 0.0 if spec[0] == "rey_super" else 1.0, 0))
		camera.current = true
		var target_frames := int(spec[2] * AbilityEffect.LIVES[spec[0]] * 60.0)
		await frames(maxi(1, target_frames))
		report.append("%s=%d" % [spec[0], draw_calls()])
		var shot := root.get_texture().get_image()
		var region := Rect2i((shot.get_width() - TILE.x * 2) / 2, (shot.get_height() - TILE.y * 2) / 2, TILE.x * 2, TILE.y * 2)
		var tile := shot.get_region(region)
		tile.resize(TILE.x, TILE.y, Image.INTERPOLATE_BILINEAR)
		tile.convert(Image.FORMAT_RGBA8)
		sheet.blit_rect(tile, Rect2i(Vector2i.ZERO, TILE), Vector2i((i % 5) * TILE.x, (i / 5) * TILE.y))
		world.queue_free()
		await frames(2)
	save(sheet, "01-efectos" + suffix)
	print("DRAW_CALLS_FICHA ", " ".join(report))

func principe_sheet(suffix: String) -> void:
	## Efectos preparados para el Príncipe (sin gameplay todavía): definición temporal.
	var principe := CharacterDefinition.new()
	principe.id = "principe"
	principe.model_scene = load("res://assets/models/principe/principe.glb")
	var specs := [["principe_shot", 0.35, 0.0], ["principe_buff", 0.35, 0.0],
		["principe_field_warning", 0.5, 0.6], ["principe_field", 0.4, 3.0], ["proyectil", 0.0, 0.0]]
	var sheet := Image.create(TILE.x * specs.size(), TILE.y, false, Image.FORMAT_RGBA8)
	for i in specs.size():
		var spec: Array = specs[i]
		var world := Node3D.new()
		root.add_child(world)
		ArenaGeometry.world(world)
		ArenaGeometry.box(world, Vector3(0, -0.1, 0), Vector3(16, 0.2, 12), Color("2f9c7c"))
		var field: bool = (spec[0] as String).begins_with("principe_field")
		var visual := CharacterVisual.new()
		visual.definition = principe
		visual.rotation_degrees.y = 180 + 30
		visual.position = Vector3(-3.2, 0, 1.2) if field else Vector3.ZERO
		world.add_child(visual)
		if spec[0] == "proyectil":
			var holder := Node3D.new()
			holder.position = Vector3(0.6, 1.0, 0.4)
			world.add_child(holder)
			var shot := ProjectileVisual.new()
			shot.style = "principe"
			holder.add_child(shot)
			holder.look_at(holder.global_position + Vector3(1, 0, 0.3))
		else:
			var effect := AbilityEffect.new()
			effect.kind = spec[0]
			effect.quality = not low
			effect.radius = 3.0
			effect.duration = spec[2]
			effect.rotation_degrees.y = 0 if field else 210
			if not field:
				effect.follow = null
			world.add_child(effect)
		var camera := Camera3D.new()
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 8.5 if field else 3.6
		camera.position = Vector3(0, 7.0, 5.5) if field else Vector3(0, 2.6, 5.0)
		world.add_child(camera)
		camera.look_at(Vector3(0, 0.0 if field else 1.0, 0))
		camera.current = true
		var life: float = spec[2] if spec[2] > 0.0 else AbilityEffect.LIVES.get(spec[0], 0.5)
		await frames(maxi(2, int(spec[1] * life * 60.0)))
		var shot_image := root.get_texture().get_image()
		var region := Rect2i((shot_image.get_width() - TILE.x * 2) / 2, (shot_image.get_height() - TILE.y * 2) / 2, TILE.x * 2, TILE.y * 2)
		var tile := shot_image.get_region(region)
		tile.resize(TILE.x, TILE.y, Image.INTERPOLATE_BILINEAR)
		tile.convert(Image.FORMAT_RGBA8)
		sheet.blit_rect(tile, Rect2i(Vector2i.ZERO, TILE), Vector2i(i * TILE.x, 0))
		world.queue_free()
		await frames(2)
	save(sheet, "01b-efectos-principe" + suffix)

func arena_moments(suffix: String) -> void:
	GameSession.selected_arena = GameSession.ARENAS[0]
	GameSession.selected = load("res://data/characters/turbo.tres")
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.aim_guide.hide()
	arena.bot.set_physics_process(false)
	arena.human.position = Vector3(-4.5, 0, 1.7)
	arena.bot.position = Vector3(3.5, 0, 1.7)
	arena.human.facing = Vector3.RIGHT
	arena.bot.facing = Vector3.LEFT
	arena.human.command.move = Vector2.ZERO
	await frames(6)
	var idle_calls := draw_calls()
	# Disparo básico en vuelo.
	arena.human.attack_cooldown = 0
	arena.human.act("shot")
	await frames(14)
	save(root.get_texture().get_image(), "02-arena-disparo" + suffix)
	var shot_calls := draw_calls()
	await frames(40)
	# Súper de Turbo.
	arena.human.attack_cooldown = 0
	arena.human.super_charge = 100
	arena.human.act("super")
	await frames(10)
	save(root.get_texture().get_image(), "03-arena-super-turbo" + suffix)
	await frames(60)
	# Súper de Rey cerca de Turbo (onda hasta su radio real).
	arena.bot.set_physics_process(true)
	arena.bot.position = Vector3(-2.0, 0, 1.7)
	arena.bot.attack_cooldown = 0
	arena.bot.super_charge = 100
	arena.bot.act("super")
	await frames(16)
	save(root.get_texture().get_image(), "04-arena-super-rey" + suffix)
	var super_calls := draw_calls()
	print("DRAW_CALLS_ARENA idle=%d disparo=%d super_rey=%d" % [idle_calls, shot_calls, super_calls])
	arena.queue_free()
	await frames(2)
