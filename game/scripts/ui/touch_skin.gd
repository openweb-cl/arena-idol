class_name TouchSkin
extends RefCounted
## Aspecto de los controles táctiles (refresh V2, provisional; Claude Code).
## Solo dibuja dentro de los círculos y del rectángulo que define ArenaTouchControls:
## posiciones, radios y zonas de toque siguen siendo del adaptador (Codex).
const FILL := Color(0.04, 0.07, 0.16, 0.72)
const FILL_ACTIVE := Color(0.09, 0.15, 0.32, 0.9)
const OFF := Color("555d70")

static func draw(c: ArenaTouchControls) -> void:
	if c.centers.is_empty():
		return
	for action: String in c.centers:
		var center: Vector2 = c.centers[action]
		var radius: float = c.radii[action]
		var active: bool = c.state.fingers.values().has(action)
		var enabled: bool = c.combat_enabled or action == "pause"
		c.draw_circle(center, radius, FILL_ACTIVE if active else FILL)
		c.draw_arc(center, radius - 1.5, 0, TAU, 56, Color(1, 1, 1, 0.12), 3.0, true)
		match action:
			"move": _move(c, center, radius, enabled)
			"attack": _attack(c, center, radius, enabled, active)
			"ability": _ability(c, center, radius, enabled)
			"super": _super(c, center, radius, enabled)
			"pause": _pause(c, center, radius)
	_mode(c)

static func _move(c: ArenaTouchControls, center: Vector2, radius: float, enabled: bool) -> void:
	var edge := ArenaStyle.MUTED if enabled else OFF
	for k in 8:
		var a := TAU * k / 8.0
		var dir := Vector2(cos(a), sin(a))
		c.draw_line(center + dir * (radius - 14), center + dir * (radius - 6), Color(edge, 0.6), 3.0, true)
	var knob := center + c.state.movement * radius * 0.55
	c.draw_circle(knob, radius * 0.34, Color(ArenaStyle.BLUE, 0.85 if enabled else 0.3))
	c.draw_circle(knob, radius * 0.22, Color(0.75, 0.88, 1.0, 0.9 if enabled else 0.3))
	c.text_at(center + Vector2(0, radius + 19), "MOVER", 16)

static func _attack(c: ArenaTouchControls, center: Vector2, radius: float, enabled: bool, active: bool) -> void:
	# Segmentos de cargas alrededor del anillo (llenos = disponibles).
	var capacity: int = maxi(1, c.ammo_capacity)
	var gap := 0.12
	for i in capacity:
		var start := -PI / 2 + TAU * i / capacity + gap / 2
		var finish := -PI / 2 + TAU * (i + 1) / capacity - gap / 2
		var filled: bool = c.ammo_capacity == 0 or i < c.ammo_charges
		var color := ArenaStyle.GOLD if filled else Color(ArenaStyle.PANEL_HI, 0.9)
		if not enabled:
			color = OFF
		c.draw_arc(center, radius - 6, start, finish, 18, color, 7.0, true)
	if c.ammo_capacity > 0 and c.ammo_charges < c.ammo_capacity:
		c.draw_arc(center, radius - 15, -PI / 2, -PI / 2 + TAU * c.ammo_progress, 40, ArenaStyle.MINT, 3.0, true)
	# Retícula central.
	var reticle := ArenaStyle.WHITE if enabled else OFF
	c.draw_arc(center + Vector2(0, -10), 15, 0, TAU, 28, reticle, 3.0, true)
	for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		c.draw_line(center + Vector2(0, -10) + dir * 9, center + Vector2(0, -10) + dir * 22, reticle, 3.0, true)
	if not c.state.auto_mode and not c.state.aim.is_zero_approx():
		c.draw_line(center, center + c.state.aim * radius * 0.85, Color("ffe14a"), 5, true)
	c.text_at(center + Vector2(0, 26), c.attack_status, 18)
	if active:
		c.draw_arc(center, radius + 4, 0, TAU, 56, Color(ArenaStyle.GOLD, 0.6), 3.0, true)

static func _ability(c: ArenaTouchControls, center: Vector2, radius: float, enabled: bool) -> void:
	var ready: bool = c.ability_ratio <= 0.0
	var tone := ArenaStyle.MINT if ready else ArenaStyle.MUTED
	if not enabled:
		tone = OFF
	if not ready:
		# Barrido de recarga: la parte oscura es lo que falta.
		c.draw_arc(center, radius - 5, -PI / 2, -PI / 2 + TAU * (1.0 - c.ability_ratio), 40, Color(tone, 0.9), 6.0, true)
	else:
		c.draw_arc(center, radius - 5, 0, TAU, 48, tone, 6.0, true)
	# Doble chevrón de avance.
	for k in 2:
		var x := center.x - 10 + k * 14
		var y := center.y - 10
		c.draw_polyline(PackedVector2Array([Vector2(x - 6, y - 10), Vector2(x + 4, y), Vector2(x - 6, y + 10)]), tone, 4.0, true)
	c.text_at(center + Vector2(0, 20), c.ability_status, 15)

static func _super(c: ArenaTouchControls, center: Vector2, radius: float, enabled: bool) -> void:
	var full: bool = c.super_ratio >= 1.0
	var tone := ArenaStyle.MINT if full else ArenaStyle.GOLD
	if not enabled:
		tone = OFF
	c.draw_arc(center, radius - 5, -PI / 2, -PI / 2 + TAU * clampf(c.super_ratio, 0, 1), 48, tone, 7.0, true)
	if full and enabled:
		c.draw_arc(center, radius + 4, 0, TAU, 56, Color(ArenaStyle.MINT, 0.55), 4.0, true)
	# Estrella de cinco puntas.
	var star := PackedVector2Array()
	var star_center := center + Vector2(0, -10)
	for k in 11:
		var a := -PI / 2 + TAU * k / 10.0
		var r := 16.0 if k % 2 == 0 else 7.0
		star.append(star_center + Vector2(cos(a), sin(a)) * r)
	c.draw_colored_polygon(star, tone if full or not enabled else Color(tone, 0.55))
	c.text_at(center + Vector2(0, 20), "SÚPER " + c.super_status if full else c.super_status, 15)

static func _pause(c: ArenaTouchControls, center: Vector2, radius: float) -> void:
	c.draw_arc(center, radius - 3, 0, TAU, 48, ArenaStyle.GOLD, 3.0, true)
	for dx in [-8, 8]:
		c.draw_rect(Rect2(center + Vector2(dx - 4, -14), Vector2(8, 22)), ArenaStyle.WHITE)
	c.text_at(center + Vector2(0, 22), "PAUSA", 12)

static func _mode(c: ArenaTouchControls) -> void:
	var box := ArenaStyle.box(Color(ArenaStyle.INK_DEEP, 0.85), 12, ArenaStyle.MINT if c.state.auto_mode else ArenaStyle.GOLD, true)
	box.set_border_width_all(2)
	c.draw_style_box(box, c.mode_rect)
	var title := "AUTO" if c.state.auto_mode else "MANUAL"
	c.text_at(c.mode_rect.get_center() + Vector2(0, -10), title, 18)
	c.text_at(c.mode_rect.get_center() + Vector2(0, 14), "apunta solo" if c.state.auto_mode else "arrastra ATACAR", 12)
