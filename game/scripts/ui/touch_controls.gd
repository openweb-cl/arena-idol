class_name ArenaTouchControls
extends Control
## UI propia, multitáctil. Solo emite intenciones; ArenaPlayer valida acciones.
signal pause_requested
signal aim_mode_requested(auto_mode: bool)
signal safe_area_changed(safe: Rect2)
var state := TouchInputState.new()
var safe_rect := Rect2()
var centers: Dictionary = {}
var radii: Dictionary = {}
var mode_rect := Rect2()
var combat_enabled := true
var playing := true
var ability_status := "LISTA"
var super_status := "0%"
var attack_status := "ATACAR"
# Valores numéricos para el aspecto (TouchSkin); no influyen en las reglas.
var ability_ratio := 0.0
var super_ratio := 0.0
var ammo_charges := 0
var ammo_capacity := 0
var ammo_progress := 0.0

static func requested() -> bool:
	return OS.has_feature("mobile") or DisplayServer.is_touchscreen_available() or OS.get_cmdline_user_args().has("--touch-controls")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_viewport().size_changed.connect(refresh_layout)
	call_deferred("refresh_layout")

func refresh_layout() -> void:
	set_safe_rect(TouchSafeArea.for_canvas(get_viewport(), size))

func set_safe_rect(value: Rect2) -> void:
	state.cancel_all()
	safe_rect = value
	var scale_factor := clampf(minf(value.size.x / 1280.0, value.size.y / 720.0), 0.7, 1.2)
	var bottom := value.end.y - 118 * scale_factor
	centers = {
		"move": Vector2(value.position.x + 118 * scale_factor, bottom),
		"attack": Vector2(value.end.x - 118 * scale_factor, bottom),
		"ability": Vector2(value.end.x - 288 * scale_factor, bottom - 50 * scale_factor),
		"super": Vector2(value.end.x - 150 * scale_factor, bottom - 170 * scale_factor),
		"pause": Vector2(value.end.x - 60 * scale_factor, value.position.y + 60 * scale_factor),
	}
	radii = {"move": 82 * scale_factor, "attack": 70 * scale_factor, "ability": 50 * scale_factor, "super": 52 * scale_factor, "pause": 48 * scale_factor}
	mode_rect = Rect2(Vector2(value.end.x - 388 * scale_factor, value.end.y - 108 * scale_factor), Vector2(175, 96) * scale_factor)
	safe_area_changed.emit(safe_rect)
	queue_redraw()

func hit_action(at: Vector2) -> String:
	if mode_rect.has_point(at):
		return "mode"
	for action: String in centers:
		if at.distance_to(centers[action]) <= radii[action]:
			return action
	return ""

func _input(event: InputEvent) -> void:
	if not playing or not is_visible_in_tree():
		return
	var handled := false
	if event is InputEventScreenTouch:
		if event.canceled:
			handled = state.fingers.has(event.index)
			state.cancel_all()
		elif not event.pressed:
			handled = state.release(event.index)
		else:
			var action := hit_action(event.position)
			if not action.is_empty():
				handled = true
				if combat_enabled or action == "pause":
					if state.press(event.index, action):
						if action in ["move", "attack"]:
							state.drag(event.index, event.position - centers[action], radii[action])
						elif action == "pause":
							pause_requested.emit()
						elif action == "mode":
							aim_mode_requested.emit(not state.auto_mode)
	elif event is InputEventScreenDrag:
		if state.fingers.has(event.index):
			var action: String = state.fingers[event.index]
			if action in ["move", "attack"]:
				state.drag(event.index, event.position - centers[action], radii[action])
			handled = true
	if handled:
		get_viewport().set_input_as_handled()
		queue_redraw()

func set_playing(value: bool) -> void:
	playing = value
	visible = value
	if not value:
		state.cancel_all()

func update_player(player: ArenaPlayer) -> void:
	var enabled := player.active and not player.knocked_out
	if combat_enabled != enabled:
		state.cancel_all()
	combat_enabled = enabled
	ability_status = "LISTA" if player.cooldown <= 0 else "%.1f s" % player.cooldown
	super_status = "%d%%" % player.super_charge
	attack_status = ("%d/%d" % [player.ammo.charges, player.ammo.capacity()]) if player.ammo.limited() else "ATACAR"
	ability_ratio = clampf(player.cooldown / maxf(0.001, player.definition.ability.cooldown), 0, 1) if player.definition.ability else 0.0
	super_ratio = player.super_charge / 100.0
	ammo_capacity = player.ammo.capacity() if player.ammo.limited() else 0
	ammo_charges = player.ammo.charges
	ammo_progress = player.ammo.progress()
	queue_redraw()

static func world_direction(axis: Vector2, camera: Camera3D) -> Vector2:
	var right := camera.global_basis.x
	var up := camera.global_basis.y
	right.y = 0
	up.y = 0
	var world := right.normalized() * axis.x - up.normalized() * axis.y
	return Vector2(world.x, world.z).normalized() * minf(1, axis.length())

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED]:
		state.cancel_all()

func text_at(at: Vector2, text: String, font_size: int = 17) -> void:
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, at - Vector2(width / 2, -font_size * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

func _draw() -> void:
	# Aspecto en TouchSkin (Claude Code); posiciones y zonas de toque siguen aquí.
	TouchSkin.draw(self)
