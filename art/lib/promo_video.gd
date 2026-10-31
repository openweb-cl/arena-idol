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
var stripe: ColorRect

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await process_frame

## Tipografía de presentación: fuentes del sistema solo para renderizar el video
## (no se incluyen en el juego), inclinadas, con contorno grueso y sombra.
func display_font(names: PackedStringArray, weight: int = 900) -> FontVariation:
	var system := SystemFont.new()
	system.font_names = names
	system.font_weight = weight
	var font := FontVariation.new()
	font.base_font = system
	font.variation_transform = Transform2D(Vector2(1, 0), Vector2(-0.2, 1), Vector2.ZERO)  # cursiva deportiva
	return font

func styled(size: int, color: Color, font: Font, outline: int, outline_color: Color, shadow := Vector2(5, 6)) -> Label:
	var label := Label.new()
	var settings := LabelSettings.new()
	settings.font = font
	settings.font_size = size
	settings.font_color = color
	settings.outline_size = outline
	settings.outline_color = outline_color
	settings.shadow_size = 0
	settings.shadow_color = Color(0, 0, 0, 0.55)
	settings.shadow_offset = shadow
	label.label_settings = settings
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func make_overlay() -> void:
	overlay = CanvasLayer.new()
	overlay.layer = 50
	root.add_child(overlay)
	var impact := display_font(PackedStringArray(["Impact", "Arial Black", "Segoe UI Black"]))
	var black := display_font(PackedStringArray(["Segoe UI Black", "Arial Black"]))
	dim = ColorRect.new()
	dim.color = Color(0.03, 0.05, 0.11, 0.0)
	dim.size = Vector2(1280, 720)
	overlay.add_child(dim)
	band = ColorRect.new()
	band.color = Color(0.03, 0.05, 0.11, 0.86)
	band.position = Vector2(0, 572)
	band.size = Vector2(1280, 148)
	overlay.add_child(band)
	stripe = ColorRect.new()  # franja dorada inclinada sobre la banda
	stripe.color = ArenaStyle.GOLD
	stripe.position = Vector2(-40, 568)
	stripe.size = Vector2(1360, 6)
	stripe.rotation = -0.004
	overlay.add_child(stripe)
	title = styled(132, Color("ffd23f"), impact, 22, Color("1b0f3a"), Vector2(9, 10))
	title.size = Vector2(1280, 180)
	title.position = Vector2(0, 220)
	overlay.add_child(title)
	caption = styled(58, ArenaStyle.WHITE, impact, 14, Color("0c1430"))
	caption.size = Vector2(1280, 80)
	caption.position = Vector2(0, 580)
	overlay.add_child(caption)
	subcaption = styled(26, ArenaStyle.GOLD, black, 8, Color("0c1430"), Vector2(3, 4))
	subcaption.size = Vector2(1280, 40)
	subcaption.position = Vector2(0, 652)
	overlay.add_child(subcaption)
	tag = styled(15, Color(1, 1, 1, 0.8), black, 5, Color(0.05, 0.07, 0.14, 0.9), Vector2(2, 2))
	tag.text = "EN DESARROLLO · ARTE PROVISIONAL"
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tag.size = Vector2(360, 24)
	tag.position = Vector2(900, 8)
	overlay.add_child(tag)

func say(main: String, sub: String = "", color: Color = ArenaStyle.WHITE) -> void:
	caption.text = main
	caption.label_settings.font_color = color
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

	# 3–8 s · Selección: los cuatro ídolos.
	menu.show_selection()
	var lines := {"turbo": "VELOCIDAD", "rey": "FUERZA", "principe": "ESTRATEGIA", "pitbull": "DEFENSA"}
	for def in heroes:
		menu.select_character(def)
		say("ELIGE TU ÍDOLO", "%s  #%d  ·  %s" % [def.display_name.to_upper(), def.number, lines[def.id]])
		await frames(int(1.25 * FPS))
	menu.queue_free()
	await frames(1)

	# 8–27 s · Un duelo por ídolo, protagonista en primer plano: habilidad y súper.
	await fight(heroes[0], heroes[1], "EL TURBO  #11", "Turbo Sprint  +  súper Remate Relámpago", 4.75)
	await fight(heroes[1], heroes[2], "EL REY  #23", "Embestida Real  +  súper Onda Real", 4.75)
	await fight(heroes[2], heroes[3], "EL PRÍNCIPE  #20", "Impulso Táctico  +  súper Campo de Dominio", 4.75)
	await fight(heroes[3], heroes[0], "EL PITBULL  #17", "Guardia de Hierro  +  súper Zona de Contención", 4.75)

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

func fight(own: CharacterDefinition, rival: CharacterDefinition, main: String, sub: String, seconds: float) -> void:
	## Duelo real con IA en ambos lados; el protagonista activa su habilidad al
	## principio y su súper a mitad del tramo, de cerca y con la cámara encima.
	GameSession.selected = own
	GameSession.selected_rival = rival
	var arena: IdolArena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.set_physics_process(false)
	arena.aim_guide.hide()
	arena.auto_target_enabled = false  # sin rótulos de diagnóstico de disparo sobre la imagen
	arena.hud.message.text = ""
	var a := arena.human
	var b := arena.bot
	a.position = Vector3(-3.2, 0, 5.6)
	b.position = Vector3(1.4 if own.attack_type == "Melee" else 3.0, 0, 5.6)
	for actor: ArenaPlayer in [a, b]:
		actor.unlimited_ammo = true
		actor.ammo.unlimited = true
		actor.invulnerable = 0
	var brain_a := ArenaBot.new(arena.layout)
	var brain_b := arena.brain
	say(main, sub, own.color.lightened(0.6))
	var total := int(seconds * FPS)
	var super_done := false
	for i in total:
		if i == 8:
			a.facing = (b.position - a.position).normalized()
			a.ability()
		if not super_done and i >= int(total * 0.4) and (own.super_kind == "Field" or TargetSelector.clear_path(a, b) or i >= int(total * 0.75)):
			# Súper a la vista (con línea libre si es un disparo): de frente al rival.
			var to_rival := b.position - a.position
			to_rival.y = 0
			a.facing = to_rival.normalized()
			a.attack_cooldown = 0
			a.channel_time = 0
			a.windup_time = 0
			a.pending_kind = ""
			a.super_charge = 100
			a.super_target = arena.field_target(a) if own.super_reach <= 0.01 else Vector3(b.position.x, 0, b.position.z)
			super_done = a.act("super")  # si se rechaza, se reintenta en el siguiente fotograma
		for step in 2:  # 60 Hz de física por cada fotograma de 30 fps
			await physics_frame
			var dt := 1.0 / 60.0
			brain_a.update(a, b, arena.projectiles, dt, arena.fields)
			a.command.super_shot = false  # la súper del protagonista se lanza en su momento
			brain_b.update(b, a, arena.projectiles, dt, arena.fields)
			b.command.super_shot = false  # el rival no tapa el poder del protagonista
			arena.update_fields(dt)
			# El protagonista gana su toma: no baja de ~55 % de vida.
			if not a.knocked_out:
				a.health = maxi(a.health, int(a.definition.max_health * 0.55))
			for actor: ArenaPlayer in [a, b]:
				actor.position.x = clampf(actor.position.x, -12.5, 12.5)
				actor.position.z = clampf(actor.position.z, -6.5, 6.5)
				if actor.dash_time > 0 and not actor.dash_hit and actor.definition.ability.contact_damage > 0:
					var other := b if actor == a else a
					if actor.position.distance_to(other.position) < 1.6:
						actor.dash_hit = true
						arena.apply_damage(other, actor, actor.definition.ability.contact_damage, actor.dash_direction * 9)
		# Remate: si el rival sigue en pie al final, el protagonista lo elimina y celebra.
		if i == int(total * 0.8) and not b.knocked_out:
			b.invulnerable = 0
			arena.apply_damage(b, a, b.health, (b.position - a.position).normalized() * 6)
		if i >= int(total * 0.82):
			a.visual.celebration = true
		arena.hud.update_state(arena.rules, a)
		# Cámara de promo: cerca, centrada sobre el protagonista y su rival.
		var mid := a.position * 0.6 + b.position * 0.4
		var target := Vector3(clampf(mid.x, -7.0, 7.0), 27, clampf(mid.z, -3.0, 3.4) + 22)
		arena.camera.position = arena.camera.position.lerp(target, 0.12) if i > 0 else target
		arena.camera.size = 12.0
	arena.queue_free()
	await frames(1)
	GameSession.selected_rival = null
