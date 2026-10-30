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
	if centers.is_empty():
		return
	for action: String in centers:
		var center: Vector2 = centers[action]
		var radius: float = radii[action]
		var active := state.fingers.values().has(action)
		draw_circle(center, radius, Color(0.06, 0.1, 0.2, 0.85 if active else 0.68))
		var edge := Color("f5c542") if action in ["super", "pause"] else Color("a5b7d4")
		if not combat_enabled and action != "pause": edge = Color("555d70")
		draw_arc(center, radius - 2, 0, TAU, 48, edge, 3, true)
		match action:
			"move":
				draw_circle(center + state.movement * radius * 0.55, radius * 0.32, Color(0.65, 0.8, 1.0, 0.65))
				text_at(center + Vector2(0, radius + 19), "MOVER", 16)
			"attack":
				if not state.auto_mode and not state.aim.is_zero_approx():
					draw_line(center, center + state.aim * radius * 0.85, Color("ffe14a"), 4, true)
				text_at(center - Vector2(0, 14), "ATACAR", 19)
				text_at(center + Vector2(0, 16), attack_status, 18)
			"ability":
				text_at(center - Vector2(0, 10), "HABILIDAD", 14)
				text_at(center + Vector2(0, 14), ability_status, 17)
			"super":
				text_at(center - Vector2(0, 10), "SÚPER", 17)
				text_at(center + Vector2(0, 16), super_status, 18)
			"pause": text_at(center, "PAUSA", 13)
	draw_style_box(ArenaStyle.box(Color(0.06, 0.1, 0.2, 0.9), 12, Color("a5b7d4")), mode_rect)
	text_at(mode_rect.get_center(), "AUTO" if state.auto_mode else "MANUAL · ARRASTRA", 14)
