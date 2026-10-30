extends Control
var page: VBoxContainer
var preview: CharacterVisual
var detail: Label
var selection := false
var preview_light: DirectionalLight3D
var match_settings: MatchConfig = preload("res://data/match.tres")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = ArenaStyle.INK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 54)
	margin.add_theme_constant_override("margin_right", 54)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
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
	var title := ArenaStyle.label("ARENA DE ÍDOLOS", 30, ArenaStyle.GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	row.add_child(ArenaStyle.label(section, 18, ArenaStyle.MUTED))

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
	left.add_child(ArenaStyle.label("DOMINA\nLA ARENA.", 48))
	left.add_child(ArenaStyle.label("BATALLA DE ÍDOLOS", 24, ArenaStyle.GOLD))
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
	left.add_child(rules)
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
	hero.add_child(ArenaStyle.label("%02d / %s" % [GameSession.selected.number, GameSession.selected.display_name.to_upper()], 32, GameSession.selected.color))
	hero.add_child(ArenaStyle.label(GameSession.selected.role, 20, ArenaStyle.MUTED))
	page.add_child(ArenaStyle.label("WASD: mover   ·   Apuntado automático   ·   T: apuntado manual   ·   Clic / Espacio: atacar\nMantén pulsado para repetir   ·   E: habilidad   ·   Q: súper   ·   Esc: pausa", 18, ArenaStyle.MUTED))
	page.add_child(ArenaStyle.label("MODELOS DE ENTRENAMIENTO PROVISIONALES · Sin cuentas, compras ni servicios externos", 16, ArenaStyle.MUTED))

func show_selection() -> void:
	selection = true
	clear_page()
	header("PLANTEL / 02 DE 16 DISPONIBLES")
	page.add_child(ArenaStyle.label("ELIGE TU ESTILO DE COMBATE", 32))
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 24)
	page.add_child(row)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	row.add_child(grid)
	for index in CharacterCatalog.CAPACITY:
		var card := ArenaStyle.button("PRÓXIMAMENTE\n%02d" % (index + 1))
		card.custom_minimum_size = Vector2(155, 90)
		card.add_theme_font_size_override("font_size", 16)
		grid.add_child(card)
		if index < CharacterCatalog.AVAILABLE.size():
			var def := CharacterCatalog.AVAILABLE[index]
			card.text = "%s  #%d\n%s" % [def.display_name, def.number, def.role]
			card.add_theme_color_override("font_color", def.color)
			card.pressed.connect(select_character.bind(def))
		else:
			card.disabled = true
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
	page.add_child(ArenaStyle.label("MODELOS PROVISIONALES · Integración artística GLB pendiente", 15, ArenaStyle.MUTED))
	var back := ArenaStyle.button("← INICIO")
	actions.add_child(back)
	back.pressed.connect(show_home)
	var play := ArenaStyle.button("JUGAR CON ESTE ÍDOLO", true)
	actions.add_child(play)
	play.pressed.connect(start_match)
	play.grab_focus()

func select_character(def: CharacterDefinition) -> void:
	GameSession.selected = def
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

func start_match() -> void:
	get_tree().change_scene_to_file("res://scenes/arena/arena.tscn")

func add_portrait(parent: Node, dimensions: Vector2) -> void:
	var container := SubViewportContainer.new()
	container.custom_minimum_size = dimensions
	container.stretch = true
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(container)
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
