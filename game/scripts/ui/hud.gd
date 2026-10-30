class_name ArenaHUD
extends CanvasLayer
signal pause_requested
signal replay_requested
signal menu_requested
var scoreboard: Label
var status: Label
var message: Label
var overlay: PanelContainer
var overlay_title: Label
var overlay_detail: Label
var resume: Button
var metrics: Label
var show_metrics := false

func _ready() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var top := PanelContainer.new()
	top.position = Vector2(28, 16)
	top.size = Vector2(1224, 70)
	top.add_theme_stylebox_override("panel", ArenaStyle.box(ArenaStyle.PANEL))
	root.add_child(top)
	var row := HBoxContainer.new()
	top.add_child(row)
	row.add_child(ArenaStyle.label("BATALLA DE ÍDOLOS", 20, ArenaStyle.GOLD))
	scoreboard = ArenaStyle.label("", 28)
	scoreboard.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scoreboard.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(scoreboard)
	var pause_button := ArenaStyle.button("PAUSA / Esc")
	pause_button.custom_minimum_size = Vector2(160, 40)
	pause_button.add_theme_font_size_override("font_size", 18)
	row.add_child(pause_button)
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	status = ArenaStyle.label("", 20)
	status.position = Vector2(40, 624)
	root.add_child(status)
	var hints := ArenaStyle.label("WASD  MOVER   /   RATÓN  APUNTAR\nCLIC / ESPACIO  ATACAR   /   E / SHIFT  HABILIDAD\nQ  SÚPER   /   F3  MÉTRICAS", 16, ArenaStyle.MUTED)
	hints.position = Vector2(720, 622)
	root.add_child(hints)
	var placeholder := ArenaStyle.label("DEMO LOCAL 1 vs BOT · ARTE PROVISIONAL · Sin objetivos deportivos", 15, ArenaStyle.MUTED)
	placeholder.position = Vector2(40, 693)
	root.add_child(placeholder)
	message = ArenaStyle.label("", 22, ArenaStyle.GOLD)
	message.position = Vector2(310, 94)
	message.size.x = 660
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(message)
	metrics = ArenaStyle.label("", 17, ArenaStyle.GOLD)
	metrics.position = Vector2(40, 120)
	root.add_child(metrics)
	overlay = PanelContainer.new()
	overlay.position = Vector2(360, 180)
	overlay.custom_minimum_size = Vector2(560, 360)
	overlay.add_theme_stylebox_override("panel", ArenaStyle.box(ArenaStyle.INK, 20, ArenaStyle.GOLD))
	root.add_child(overlay)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	overlay.add_child(column)
	overlay_title = ArenaStyle.label("", 36, ArenaStyle.GOLD)
	column.add_child(overlay_title)
	overlay_detail = ArenaStyle.label("", 22)
	column.add_child(overlay_detail)
	resume = ArenaStyle.button("CONTINUAR", true)
	column.add_child(resume)
	resume.pressed.connect(func() -> void: pause_requested.emit())
	var replay := ArenaStyle.button("REVANCHA / REINICIAR")
	column.add_child(replay)
	replay.pressed.connect(func() -> void: replay_requested.emit())
	var menu := ArenaStyle.button("VOLVER AL MENÚ")
	column.add_child(menu)
	menu.pressed.connect(func() -> void: menu_requested.emit())
	overlay.hide()

func update_state(rules: MatchRules, player: ArenaPlayer) -> void:
	var seconds := ceili(rules.remaining)
	scoreboard.text = "TÚ  %d   —   %d  BOT      %d:%02d" % [rules.scores[0], rules.scores[1], seconds / 60, seconds % 60]
	var ability_text := "LISTA" if player.cooldown <= 0 else "%.1f s" % player.cooldown
	status.text = "%s #%d   /   %d PV\n%s: %s   /   SÚPER: %d%%" % [player.definition.display_name, player.definition.number, player.health, player.definition.ability.display_name, ability_text, player.super_charge]
	if player.knocked_out:
		status.text = "ELIMINADO TEMPORALMENTE\nREAPARICIÓN EN %.1f s" % maxf(0, player.respawn_time)
	metrics.visible = show_metrics
	if show_metrics:
		metrics.text = "%d FPS · %.2f ms proceso\n%d draw calls · %d primitivas\n%s / %s" % [Engine.get_frames_per_second(), Performance.get_monitor(Performance.TIME_PROCESS) * 1000, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME), RenderingServer.get_current_rendering_method(), "BAJO" if GraphicsSettings.low else "ALTO"]

func show_overlay(title: String, detail: String, paused: bool) -> void:
	overlay_title.text = title
	overlay_detail.text = detail
	resume.visible = paused
	overlay.show()
	if paused:
		resume.grab_focus()
