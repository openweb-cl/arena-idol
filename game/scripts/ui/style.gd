class_name ArenaStyle
extends RefCounted
## Identidad visual de la UI (refresh V2, provisional; Claude Code). Original: sin
## recursos comerciales. Tipografía: fuente incluida en Godot con variación negrita.
const INK := Color("101a33")
const INK_DEEP := Color("0a1124")
const PANEL := Color("202d4f")
const PANEL_HI := Color("2b3b66")
const GOLD := Color("f5c542")
const GOLD_DARK := Color("b8860b")
const MINT := Color("6fffd8")
const CORAL := Color("ff8a5c")
const BLUE := Color("3f8cff")
const RED := Color("ff4d5e")
const WHITE := Color("f8faff")
const MUTED := Color("a5b7d4")
const SKEW := Vector2(-0.14, 0)  ## inclinación deportiva de paneles y botones

static var _bold: FontVariation

static func bold() -> FontVariation:
	if _bold == null:
		_bold = FontVariation.new()
		_bold.base_font = ThemeDB.fallback_font
		_bold.variation_embolden = 0.85
		_bold.spacing_glyph = 1
	return _bold

static func box(color: Color, radius: int = 16, border: Color = Color.TRANSPARENT, skewed := false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_border_width_all(2)
	s.border_color = border
	s.content_margin_left = 24
	s.content_margin_right = 24
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 6
	s.shadow_offset = Vector2(0, 4)
	if skewed:
		s.skew = SKEW
	return s

static func label(text: String, size: int = 24, color: Color = WHITE, strong := false, outline := 0) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if strong:
		l.add_theme_font_override("font", bold())
	if outline > 0:
		set_outline(l, outline)
	return l

static func set_outline(control: Control, size: int) -> void:
	## Contorno oscuro para leer texto sobre la arena y el público.
	control.add_theme_constant_override("outline_size", size)
	control.add_theme_color_override("font_outline_color", INK_DEEP)

static func button(text: String, primary: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(180, 58)
	b.add_theme_font_size_override("font_size", 22)
	b.add_theme_font_override("font", bold())
	var base := GOLD if primary else PANEL
	b.add_theme_stylebox_override("normal", _button_box(base, GOLD_DARK if primary else INK_DEEP))
	b.add_theme_stylebox_override("hover", _button_box(Color("ffe18b") if primary else PANEL_HI, GOLD_DARK if primary else INK_DEEP))
	b.add_theme_stylebox_override("pressed", _button_box(Color("e0ae2e") if primary else INK, GOLD_DARK if primary else INK_DEEP, true))
	b.add_theme_stylebox_override("focus", _focus_box())
	b.add_theme_stylebox_override("disabled", _button_box(Color(0.09, 0.12, 0.22), Color(0.06, 0.08, 0.16)))
	b.add_theme_color_override("font_color", INK if primary else WHITE)
	b.add_theme_color_override("font_hover_color", INK if primary else WHITE)
	b.add_theme_color_override("font_pressed_color", INK if primary else WHITE)
	b.add_theme_color_override("font_focus_color", INK if primary else WHITE)
	b.add_theme_color_override("font_disabled_color", Color(0.45, 0.5, 0.62))
	return b

static func _button_box(color: Color, edge: Color, pressed := false) -> StyleBoxFlat:
	## Botón inclinado con «canto» inferior que se hunde al pulsar.
	var s := box(color, 12, Color.TRANSPARENT, true)
	s.set_border_width_all(0)
	s.border_width_bottom = 1 if pressed else 5
	s.border_color = edge
	s.content_margin_top = 16 if pressed else 12
	s.content_margin_bottom = 10 if pressed else 14
	s.shadow_size = 2 if pressed else 6
	return s

static func _focus_box() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.set_corner_radius_all(12)
	s.set_border_width_all(3)
	s.border_color = MINT
	s.skew = SKEW
	return s

static func bar(fill: Color, back := Color(0.05, 0.08, 0.16, 0.9), height := 12) -> ProgressBar:
	## Barra inclinada para vida, súper y recarga.
	var p := ProgressBar.new()
	p.show_percentage = false
	p.custom_minimum_size = Vector2(0, height)
	var bg := StyleBoxFlat.new()
	bg.bg_color = back
	bg.set_corner_radius_all(4)
	bg.skew = SKEW
	bg.set_border_width_all(1)
	bg.border_color = Color(1, 1, 1, 0.12)
	var fg := StyleBoxFlat.new()
	fg.bg_color = fill
	fg.set_corner_radius_all(4)
	fg.skew = SKEW
	fg.border_width_top = 2
	fg.border_color = fill.lightened(0.35)
	p.add_theme_stylebox_override("background", bg)
	p.add_theme_stylebox_override("fill", fg)
	return p

static func chip(color: Color) -> StyleBoxFlat:
	## Fondo de etiqueta compacta (equipo, rol, estado).
	var s := box(color, 8, Color.TRANSPARENT, true)
	s.set_border_width_all(0)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 4
	s.content_margin_bottom = 4
	s.shadow_size = 0
	return s
