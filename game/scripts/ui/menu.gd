extends Control
var page: VBoxContainer
var preview: CharacterVisual
var detail: Label
var selection := false
var preview_light: DirectionalLight3D
var match_settings: MatchConfig = preload("res://data/match.tres")
var cards: Dictionary = {}  ## id de héroe → botón de su tarjeta en la selección
var portrait_frame: StyleBoxFlat
const IN_DEVELOPMENT := {3: "EL PITBULL  #17"}  ## arte listo, sin gameplay

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(MenuBackdrop.new())
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 54)
	margin.add_theme_constant_override("margin_right", 54)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
	# Solo márgenes seguros; la producción visual del menú sigue en manos de Claude.
	margin.add_child(TouchSafeArea.new())
	page = VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	margin.add_child(page)
	show_home()

func clear_page() -> void:
	for child in page.get_children():
		page.remove_child(child)
		child.queue_free()

func header(section: String) -> void:
	var row := HBoxContainer.new()
	page.add_child(row)
	var title := ArenaStyle.label("ARENA DE ÍDOLOS", 34, ArenaStyle.GOLD, true, 4)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	var tag := PanelContainer.new()
	tag.add_theme_stylebox_override("panel", ArenaStyle.chip(Color(ArenaStyle.PANEL, 0.85)))
	tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tag.add_child(ArenaStyle.label(section, 16, ArenaStyle.MUTED, true))
	row.add_child(tag)

func show_home() -> void:
	selection = false
	clear_page()
	header("PROTOTIPO 01   •   LOCAL / SIN CONEXIÓN")
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(body)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 8)
	body.add_child(left)
	left.add_child(ArenaStyle.label("DOMINA\nLA ARENA.", 56, ArenaStyle.WHITE, true, 5))
	left.add_child(ArenaStyle.label("BATALLA DE ÍDOLOS", 24, ArenaStyle.GOLD, true))
	left.add_child(ArenaStyle.label("Combate local · Tú contra un bot\n%d segundos · %d eliminaciones para ganar" % [match_settings.duration_seconds, match_settings.target_eliminations], 23, ArenaStyle.MUTED))
	var play := ArenaStyle.button("JUGAR  →", true)
	left.add_child(play)
	play.pressed.connect(start_match)
	var choose := ArenaStyle.button("ELEGIR ÍDOLO")
	var secondary := HBoxContainer.new()
	left.add_child(secondary)
	secondary.add_child(choose)
	choose.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choose.pressed.connect(show_selection)
	var training := ArenaStyle.button("CAMPO DE TIRO")
	secondary.add_child(training)
	training.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	training.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/training/projectile_range.tscn"))
	var graphics := ArenaStyle.button("GRÁFICOS: " + ("BAJO" if GraphicsSettings.low else "ALTO"))
	left.add_child(graphics)
	graphics.pressed.connect(func() -> void:
		GraphicsSettings.low = not GraphicsSettings.low
		graphics.text = "GRÁFICOS: " + ("BAJO" if GraphicsSettings.low else "ALTO")
		GraphicsSettings.apply(preview.get_viewport(), preview_light)
	)
	var rules := ArenaStyle.button("REGLAS: " + ("RECARGA" if GameSession.reload_enabled else "REFERENCIA SIN RECARGA"))
	var options := HBoxContainer.new()
	left.add_child(options)
	options.add_child(rules)
	rules.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var arena_choice := ArenaStyle.button("ARENA " + ("A" if GameSession.selected_arena.id == "prisma-a" else "B"))
	arena_choice.add_theme_font_size_override("font_size", 18)
	arena_choice.custom_minimum_size = Vector2(180, 42)
	options.add_child(arena_choice)
	arena_choice.pressed.connect(func() -> void:
		GameSession.selected_arena = GameSession.ARENAS[1] if GameSession.selected_arena.id == "prisma-a" else GameSession.ARENAS[0]
		arena_choice.text = "ARENA " + ("A" if GameSession.selected_arena.id == "prisma-a" else "B")
	)
	var rival := ArenaStyle.button(rival_text())
	rival.add_theme_font_size_override("font_size", 18)
	rival.custom_minimum_size = Vector2(240, 42)
	options.add_child(rival)
	rival.pressed.connect(func() -> void:
		cycle_rival()
		rival.text = rival_text()
	)
	rules.pressed.connect(func() -> void:
		GameSession.reload_enabled = not GameSession.reload_enabled
		rules.text = "REGLAS: " + ("RECARGA" if GameSession.reload_enabled else "REFERENCIA SIN RECARGA")
	)
	rules.add_theme_font_size_override("font_size", 18)
	rules.custom_minimum_size.y = 42
	play.grab_focus()
	var hero := VBoxContainer.new()
	hero.custom_minimum_size.x = 420
	body.add_child(hero)
	add_portrait(hero, Vector2(420, 330))
	hero.add_child(ArenaStyle.label("%02d / %s" % [GameSession.selected.number, GameSession.selected.display_name.to_upper()], 32, GameSession.selected.color.lightened(0.45), true, 4))
	hero.add_child(ArenaStyle.label(GameSession.selected.role, 20, ArenaStyle.MUTED, true))
	page.add_child(ArenaStyle.label("WASD: mover   ·   Apuntado automático   ·   T: apuntado manual   ·   Clic / Espacio: atacar\nMantén pulsado para repetir   ·   E: habilidad   ·   Q: súper   ·   Esc: pausa", 18, ArenaStyle.MUTED))
	page.add_child(ArenaStyle.label("MODELOS DE ENTRENAMIENTO PROVISIONALES · Sin cuentas, compras ni servicios externos", 16, ArenaStyle.MUTED))

func show_selection() -> void:
	selection = true
	clear_page()
	header("PLANTEL / %02d DE %d DISPONIBLES" % [CharacterCatalog.AVAILABLE.size(), CharacterCatalog.CAPACITY])
	page.add_child(ArenaStyle.label("ELIGE TU ESTILO DE COMBATE", 32, ArenaStyle.WHITE, true, 4))
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 24)
	page.add_child(row)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	row.add_child(grid)
	cards.clear()
	for index in CharacterCatalog.CAPACITY:
		var card := ArenaStyle.button("PRÓXIMAMENTE\n%02d" % (index + 1))
		card.custom_minimum_size = Vector2(155, 90)
		card.add_theme_font_size_override("font_size", 16)
		grid.add_child(card)
		if index < CharacterCatalog.AVAILABLE.size():
			var def := CharacterCatalog.AVAILABLE[index]
			card.text = "%s  #%d\n%s" % [def.display_name, def.number, def.role]
			_style_card(card, def.color, false)
			card.pressed.connect(select_character.bind(def))
			cards[def.id] = card
		else:
			card.disabled = true
			if IN_DEVELOPMENT.has(index):
				card.text = "%s\nEN DESARROLLO" % IN_DEVELOPMENT[index]
	var info := VBoxContainer.new()
	row.add_child(info)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_portrait(info, Vector2(300, 200))
	detail = ArenaStyle.label("", 18)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(detail)
	select_character(GameSession.selected)
	var actions := HBoxContainer.new()
	page.add_child(actions)
	page.add_child(ArenaStyle.label("MODELOS 3D PROVISIONALES · Arte en revisión", 15, ArenaStyle.MUTED))
	var back := ArenaStyle.button("← INICIO")
	actions.add_child(back)
	back.pressed.connect(show_home)
	var play := ArenaStyle.button("JUGAR CON ESTE ÍDOLO", true)
	actions.add_child(play)
	play.pressed.connect(start_match)
	play.grab_focus()

func _style_card(card: Button, color: Color, selected: bool) -> void:
	## Tarjeta con canto del color del héroe; la elegida se enciende en dorado.
	for state in ["normal", "hover", "pressed", "focus"]:
		var s := ArenaStyle.box(Color(ArenaStyle.PANEL_HI if selected or state == "hover" else ArenaStyle.PANEL, 0.95), 10, Color.TRANSPARENT, true)
		s.set_border_width_all(0)
		s.border_width_left = 8
		s.border_width_bottom = 3 if selected else 0
		s.border_color = ArenaStyle.GOLD if selected else color
		if state == "focus":
			s.draw_center = false
			s.set_border_width_all(3)
			s.border_color = ArenaStyle.MINT
		card.add_theme_stylebox_override(state, s)
	card.add_theme_color_override("font_color", color.lightened(0.55))
	card.add_theme_color_override("font_hover_color", ArenaStyle.WHITE)

func select_character(def: CharacterDefinition) -> void:
	GameSession.selected = def
	for id in cards:
		var hero_def: CharacterDefinition = CharacterCatalog.AVAILABLE.filter(func(d: CharacterDefinition) -> bool: return d.id == id)[0]
		_style_card(cards[id], hero_def.color, id == def.id)
	if portrait_frame != null:
		portrait_frame.border_color = def.color
	if preview.definition != def:
		var parent := preview.get_parent()
		parent.remove_child(preview)
		preview.queue_free()
		preview = CharacterVisual.new()
		preview.definition = def
		parent.add_child(preview)
	detail.text = "%s  /  #%d\n%s\n%s\nVida %d  ·  Velocidad %.1f m/s\nHabilidad: %.1f s de recarga" % [def.display_name, def.number, def.role, def.description, def.max_health, def.speed, def.ability.cooldown]
	if def.ammo != null and def.ammo.enabled:
		detail.text += "\n%d cargas · +1 cada %.1f s" % [def.ammo.capacity, def.ammo.seconds_per_charge]

## Rival del bot: recorre los héroes jugables distintos del propio.
func rival_text() -> String:
	return "RIVAL: " + CharacterCatalog.rival_for(GameSession.selected, GameSession.selected_rival).display_name.to_upper()

func cycle_rival() -> void:
	var options := CharacterCatalog.AVAILABLE.filter(func(d: CharacterDefinition) -> bool: return d.id != GameSession.selected.id)
	var current := CharacterCatalog.rival_for(GameSession.selected, GameSession.selected_rival)
	GameSession.selected_rival = options[(options.find(current) + 1) % options.size()]

func start_match() -> void:
	get_tree().change_scene_to_file("res://scenes/arena/arena.tscn")

func add_portrait(parent: Node, dimensions: Vector2) -> void:
	# Marco con el color del héroe alrededor del retrato 3D.
	var frame := PanelContainer.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portrait_frame = ArenaStyle.box(Color(ArenaStyle.INK_DEEP, 0.75), 18, GameSession.selected.color)
	portrait_frame.set_border_width_all(3)
	portrait_frame.content_margin_left = 6
	portrait_frame.content_margin_right = 6
	portrait_frame.content_margin_top = 6
	portrait_frame.content_margin_bottom = 6
	frame.add_theme_stylebox_override("panel", portrait_frame)
	parent.add_child(frame)
	var container := SubViewportContainer.new()
	container.custom_minimum_size = dimensions
	container.stretch = true
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(dimensions)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	var world := Node3D.new()
	viewport.add_child(world)
	preview_light = ArenaGeometry.world(world)
	GraphicsSettings.apply(viewport, preview_light)
	ArenaGeometry.box(world, Vector3(0, -0.15, 0), Vector3(2.7, 0.2, 2.7), Color("202d4f"))
	ArenaGeometry.ring(world, 1.1, GameSession.selected.color)
	preview = CharacterVisual.new()
	preview.definition = GameSession.selected
	world.add_child(preview)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 3.0
	camera.position = Vector3(2.6, 2.4, -4.5)
	world.add_child(camera)
	camera.look_at(Vector3(0, 1, 0))
	camera.current = true

func _process(delta: float) -> void:
	if is_instance_valid(preview):
		preview.rotation.y += delta * 0.2
