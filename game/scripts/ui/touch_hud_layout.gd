class_name TouchHUDLayout
extends RefCounted
## Ajuste funcional temporal. Claude puede cambiar el aspecto conservando estos anclajes.
static func apply(hud: ArenaHUD, safe: Rect2) -> void:
	hud.top.position = safe.position + Vector2(12, 8)
	hud.top.size = Vector2(safe.size.x - 140, 64)
	hud.pause_button.hide()
	hud.keyboard_hints.hide()
	hud.footer.hide()
	hud.assist_status.hide()
	hud.status.position = Vector2(safe.get_center().x - 260, safe.end.y - 102)
	hud.status.add_theme_font_size_override("font_size", 18)
	hud.ammo_panel.position = Vector2(safe.get_center().x - 260, safe.end.y - 170)
	hud.ammo_panel.size.x = 450
	hud.message.position = safe.position + Vector2(16, 80)
	hud.message.size.x = safe.size.x - 32
	hud.message.add_theme_font_size_override("font_size", 18)
	hud.metrics.position = safe.position + Vector2(16, 110)
	hud.diagnostics.position = safe.position + Vector2(16, 90)
	hud.diagnostics.add_theme_font_size_override("font_size", 14)
	hud.overlay.position = safe.get_center() - Vector2(280, 180)
