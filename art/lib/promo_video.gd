extends SceneTree
## Video promocional de 30 s con imágenes REALES del juego en desarrollo (no es arte final).
## Graba con el Movie Maker de Godot (30 fps fijos):
##   godot --path game --audio-driver Dummy --resolution 1280x720 --write-movie ../builds/promo/promo.avi \
##     --script ../art/lib/promo_video.gd
## Los combates los juega la IA de ambos lados; los rótulos se dibujan encima.
const FPS := 30
var overlay: CanvasLayer
var caption: Label
var subcaption: Label
var title: Label
var tag: Label
var dim: ColorRect
var band: ColorRect

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await process_frame

func make_overlay() -> void:
	overlay = CanvasLayer.new()
	overlay.layer = 50
	root.add_child(overlay)
	tag = ArenaStyle.label("EN DESARROLLO · ARTE PROVISIONAL", 16, Color(1, 1, 1, 0.85), true, 4)
	tag.position = Vector2(24, 682)
	dim = ColorRect.new()
	dim.color = Color(0.03, 0.05, 0.11, 0.0)
	dim.size = Vector2(1280, 720)
	overlay.add_child(dim)
	band = ColorRect.new()
	band.color = Color(0.03, 0.05, 0.11, 0.86)
	band.position = Vector2(0, 572)
	band.size = Vector2(1280, 148)
	overlay.add_child(band)
	overlay.move_child(tag, -1)
	title = ArenaStyle.label("", 92, ArenaStyle.GOLD, true, 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(1280, 140)
	title.position = Vector2(0, 250)
	overlay.add_child(title)
	caption = ArenaStyle.label("", 40, ArenaStyle.WHITE, true, 8)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.size = Vector2(1280, 60)
	caption.position = Vector2(0, 590)
	overlay.add_child(caption)
	subcaption = ArenaStyle.label("", 24, ArenaStyle.GOLD, true, 6)
	subcaption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subcaption.size = Vector2(1280, 40)
	subcaption.position = Vector2(0, 640)
	overlay.add_child(subcaption)

func say(main: String, sub: String = "") -> void:
	caption.text = main
	subcaption.text = sub

func run() -> void:
	make_overlay()
	var heroes: Array[CharacterDefinition] = []
	for id in ["turbo", "rey", "principe", "pitbull"]:
		heroes.append(load("res://data/characters/%s.tres" % id))
	GameSession.selected_arena = GameSession.ARENAS[0]

	# 0–3 s · Portada sobre el menú.
	GameSession.selected = heroes[0]
	var menu: Control = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	title.text = "ARENA DE ÍDOLOS"
	say("", "Batalla de Ídolos · combate arcade 3D")
	for i in 3 * FPS:
		dim.color.a = 0.9 * clampf(i / 8.0, 0, 1) if i < 2.5 * FPS else 0.9 * (1.0 - (i - 2.5 * FPS) / (0.5 * FPS))
		title.modulate.a = clampf(i / 12.0, 0, 1)
		title.scale = Vector2.ONE * (1.0 + 0.04 * (1.0 - clampf(i / 20.0, 0, 1)))
		await process_frame
	title.text = ""
	dim.color.a = 0.0

	# 3–9 s · Selección: los cuatro ídolos.
	menu.show_selection()
	var lines := {"turbo": "VELOCIDAD", "rey": "FUERZA", "principe": "ESTRATEGIA", "pitbull": "DEFENSA"}
	for def in heroes:
		menu.select_character(def)
		say("ELIGE TU ÍDOLO", "%s  #%d  ·  %s" % [def.display_name.to_upper(), def.number, lines[def.id]])
		await frames(int(1.5 * FPS))
	menu.queue_free()
	await frames(1)

	# 9–27 s · Combates reales con IA en ambos lados.
	await fight(heroes[0], heroes[1], "COMBATES ARCADE EN 3D", "Turbo dispara · Rey embiste con escudo", 6.0, false)
	await fight(heroes[2], heroes[3], "CADA ÍDOLO, SU PODER", "Príncipe: Campo de Dominio", 6.0, true)
	await fight(heroes[3], heroes[0], "AGUANTA Y CONTRAATACA", "Pitbull: Guardia de Hierro · Zona de Contención", 6.0, true)

	# 27–30 s · Cierre.
	GameSession.selected = heroes[2]
	menu = load("res://scenes/menu/main.tscn").instantiate()
	root.add_child(menu)
	title.text = "ARENA DE ÍDOLOS"
	say("PRÓXIMAMENTE", "Se viene pronto")
	for i in 3 * FPS:
		dim.color.a = 0.92 * clampf(i / 8.0, 0, 1)
		title.modulate.a = clampf(i / 10.0, 0, 1)
		await process_frame
	quit(0)

func fight(own: CharacterDefinition, rival: CharacterDefinition, main: String, sub: String, seconds: float, force_super: bool) -> void:
	GameSession.selected = own
	GameSession.selected_rival = rival
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.set_physics_process(false)
	arena.aim_guide.hide()
	arena.hud.message.text = ""
	var a := arena.human
	var b := arena.bot
	a.position = Vector3(-4.5, 0, 4.6)
	b.position = Vector3(3.5, 0, 4.4)
	a.unlimited_ammo = true
	b.unlimited_ammo = true
	a.ammo.unlimited = true
	b.ammo.unlimited = true
	var brain_a := ArenaBot.new(arena.layout)
	var brain_b := arena.brain
	say(main, sub)
	var total := int(seconds * FPS)
	for i in total:
		# Súper hacia la mitad del tramo para mostrar los poderes de zona.
		if force_super and i == int(total * 0.35):
			a.super_charge = 100
		if i == int(total * 0.55):
			b.super_charge = 100
		for step in 2:  # 60 Hz de física por cada fotograma de 30 fps
			await physics_frame
			var dt := 1.0 / 60.0
			brain_a.update(a, b, arena.projectiles, dt, arena.fields)
			brain_b.update(b, a, arena.projectiles, dt, arena.fields)
			arena.update_fields(dt)
			for actor: ArenaPlayer in [a, b]:
				actor.position.x = clampf(actor.position.x, -12.5, 12.5)
				actor.position.z = clampf(actor.position.z, -6.5, 6.5)
				if actor.dash_time > 0 and not actor.dash_hit and actor.definition.ability.contact_damage > 0:
					var other := b if actor == a else a
					if actor.position.distance_to(other.position) < 1.6:
						actor.dash_hit = true
						arena.apply_damage(other, actor, actor.definition.ability.contact_damage, actor.dash_direction * 9)
		arena.hud.update_state(arena.rules, a)
		# Cámara de promo: más cerca y siguiendo el punto medio del duelo.
		var mid := (a.position + b.position) * 0.5
		var target := Vector3(clampf(mid.x, -6.5, 6.5), 27, clampf(mid.z, -2.5, 2.5) + 22)
		arena.camera.position = arena.camera.position.lerp(target, 0.12) if i > 0 else target
		arena.camera.size = 13.5
	arena.queue_free()
	await frames(1)
	GameSession.selected_rival = null
