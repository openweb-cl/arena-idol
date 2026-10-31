extends Control
var page: VBoxContainer
var preview: CharacterVisual
var detail: Label
var selection := false
var preview_light: DirectionalLight3D
var match_settings: MatchConfig = preload("res://data/match.tres")
var cards: Dictionary = {}  ## id de héroe → botón de su tarjeta en la selección
var portrait_frame: StyleBoxFlat
const IN_DEVELOPMENT := {}  ## héroes con arte listo y sin gameplay
const PORTRAIT := "res://assets/ui/retratos/%s.png"  ## busto renderizado (art/lib/render_portraits.py)
var hero_name: Label
var hero_role: Label
var kit_label: Label
var stat_bars: Dictionary = {}  ## atributo → barra de la ficha

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
	## Composición de la referencia 05: retratos a la izquierda, héroe sobre pedestal
	## en el centro, ficha a la derecha y acciones abajo. Pendientes bloqueados.
	selection = true
	clear_page()
	header("PLANTEL / %02d DE %d DISPONIBLES" % [CharacterCatalog.AVAILABLE.size(), CharacterCatalog.CAPACITY])
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 18)
	page.add_child(row)
	row.add_child(roster_panel())
	var stage := VBoxContainer.new()
	stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(stage)
	add_portrait(stage, Vector2(400, 380))
	var info := VBoxContainer.new()
	info.custom_minimum_size.x = 360
	info.add_theme_constant_override("separation", 6)
	row.add_child(info)
	hero_name = ArenaStyle.label("", 44, ArenaStyle.WHITE, true, 5)
	info.add_child(hero_name)
	hero_role = ArenaStyle.label("", 20, ArenaStyle.GOLD, true)
	info.add_child(hero_role)
	detail = ArenaStyle.label("", 17, ArenaStyle.MUTED)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(detail)
	stat_bars.clear()
	for stat in ["VIDA", "VELOCIDAD", "ATAQUE", "ALCANCE"]:
		var line := HBoxContainer.new()
		info.add_child(line)
		var title := ArenaStyle.label(stat, 15, ArenaStyle.MUTED, true)
		title.custom_minimum_size.x = 112
		line.add_child(title)
		var bar := ArenaStyle.bar(ArenaStyle.GOLD, Color(0.05, 0.08, 0.16, 0.9), 12)
		bar.max_value = 1.0
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(bar)
		stat_bars[stat] = bar
	kit_label = ArenaStyle.label("", 16, ArenaStyle.WHITE)
	kit_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(kit_label)
	select_character(GameSession.selected)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	page.add_child(actions)
	var back := ArenaStyle.button("← INICIO")
	actions.add_child(back)
	back.pressed.connect(show_home)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	var rival := ArenaStyle.button(rival_text())
	rival.add_theme_font_size_override("font_size", 18)
	actions.add_child(rival)
	rival.pressed.connect(func() -> void:
		cycle_rival()
		rival.text = rival_text()
	)
	var play := ArenaStyle.button("JUGAR CON ESTE ÍDOLO  →", true)
	play.custom_minimum_size.x = 330
	actions.add_child(play)
	play.pressed.connect(start_match)
	play.grab_focus()
	page.add_child(ArenaStyle.label("MODELOS 3D PROVISIONALES · Arte en revisión · Valores de combate en ensayo", 15, ArenaStyle.MUTED))

func roster_panel() -> PanelContainer:
	## Panel ÍDOLOS: retrato por héroe jugable y plazas bloqueadas para el resto.
	var panel := PanelContainer.new()
	var style := ArenaStyle.box(Color(ArenaStyle.INK_DEEP, 0.82), 18, Color(ArenaStyle.PANEL_HI, 0.9))
	style.set_border_width_all(2)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)
	column.add_child(ArenaStyle.label("ÍDOLOS", 20, ArenaStyle.WHITE, true, 3))
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	column.add_child(grid)
	cards.clear()
	for index in CharacterCatalog.CAPACITY:
		var card := Button.new()
		card.custom_minimum_size = Vector2(68, 68)
		card.focus_mode = Control.FOCUS_ALL
		grid.add_child(card)
		if index < CharacterCatalog.AVAILABLE.size():
			var def := CharacterCatalog.AVAILABLE[index]
			if ResourceLoader.exists(PORTRAIT % def.id):
				card.icon = load(PORTRAIT % def.id)
				card.expand_icon = true
				card.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			else:
				card.text = "#%d" % def.number
			card.tooltip_text = "%s  #%d · %s" % [def.display_name, def.number, def.role]
			_style_card(card, def.color, false)
			card.pressed.connect(select_character.bind(def))
			cards[def.id] = card
		else:
			card.disabled = true
			card.text = "%02d" % (index + 1)
			card.tooltip_text = IN_DEVELOPMENT.get(index, "Próximamente")
			card.add_theme_font_size_override("font_size", 15)
			_style_card(card, ArenaStyle.PANEL_HI, false)
	column.add_child(ArenaStyle.label("MÁS ÍDOLOS\nPRÓXIMAMENTE", 14, ArenaStyle.MUTED, true))
	return panel

func _style_card(card: Button, color: Color, selected: bool) -> void:
	## Retrato con marco del color del héroe; el elegido se enciende en dorado.
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var s := ArenaStyle.box(Color(ArenaStyle.PANEL_HI if selected or state == "hover" else ArenaStyle.PANEL, 0.95), 12)
		s.set_border_width_all(4 if selected else 2)
		s.border_color = ArenaStyle.GOLD if selected else color
		s.content_margin_left = 3
		s.content_margin_right = 3
		s.content_margin_top = 3
		s.content_margin_bottom = 3
		if state == "disabled":
			s.bg_color = Color(ArenaStyle.INK_DEEP, 0.7)
			s.border_color = Color(ArenaStyle.PANEL_HI, 0.6)
		if state == "focus":
			s.draw_center = false
			s.set_border_width_all(3)
			s.border_color = ArenaStyle.MINT
		card.add_theme_stylebox_override(state, s)
	card.add_theme_color_override("font_color", color.lightened(0.55))
	card.add_theme_color_override("font_disabled_color", Color(ArenaStyle.MUTED, 0.45))
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
	if hero_name == null or not is_instance_valid(hero_name):
		return
	hero_name.text = "%s  #%d" % [def.display_name.to_upper(), def.number]
	hero_name.add_theme_color_override("font_color", def.color.lightened(0.45))
	hero_role.text = def.role
	detail.text = def.description
	# Barras relativas al plantel actual; orientan, no son balance validado.
	stat_bars["VIDA"].value = clampf(def.max_health / 7000.0, 0.1, 1.0)
	stat_bars["VELOCIDAD"].value = clampf(def.speed / 8.0, 0.1, 1.0)
	stat_bars["ATAQUE"].value = clampf(def.attack_damage / def.attack_interval / 2100.0, 0.1, 1.0)
	stat_bars["ALCANCE"].value = clampf(def.attack_range / 13.0, 0.1, 1.0)
	var super_text := "Disparo potente" if def.attack_type == "Ranged" else "Onda alrededor"
	if def.super_kind == "Field":
		super_text = "Zona de %.0f m · empuja y ralentiza %d %%" % [def.super_radius, roundi(def.field_slow * 100)]
	kit_label.text = "HABILIDAD  ·  %s  (%.1f s)\nSÚPER  ·  %s" % [def.ability.display_name, def.ability.cooldown, super_text]
	if def.ammo != null and def.ammo.enabled:
		kit_label.text += "\nMUNICIÓN  ·  %d cargas, +1 cada %.1f s" % [def.ammo.capacity, def.ammo.seconds_per_charge]

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
	# Pedestal: losa oscura, anillo del color del héroe y halo exterior.
	var base := CylinderMesh.new()
	base.top_radius = 1.45
	base.bottom_radius = 1.6
	base.height = 0.24
	ArenaGeometry.mesh(world, base, Vector3(0, -0.13, 0), Color("172243"))
	ArenaGeometry.ring(world, 1.1, GameSession.selected.color)
	ArenaGeometry.ring(world, 1.5, GameSession.selected.color.darkened(0.35))
	preview = CharacterVisual.new()
	preview.definition = GameSession.selected
	world.add_child(preview)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.75
	camera.position = Vector3(2.6, 2.2, -4.5)
	world.add_child(camera)
	camera.look_at(Vector3(0, 1.0, 0))
	camera.current = true

func _process(delta: float) -> void:
	if is_instance_valid(preview):
		preview.rotation.y += delta * 0.2
