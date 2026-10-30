class_name ArenaStyle
extends RefCounted
const INK := Color("101a33")
const PANEL := Color("202d4f")
const GOLD := Color("f5c542")
const WHITE := Color("f8faff")
const MUTED := Color("a5b7d4")

static func box(color: Color, radius: int = 16, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_border_width_all(2)
	s.border_color = border
	s.content_margin_left = 24
	s.content_margin_right = 24
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	return s

static func label(text: String, size: int = 24, color: Color = WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

static func button(text: String, primary: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(180, 58)
	b.add_theme_font_size_override("font_size", 22)
	b.add_theme_stylebox_override("normal", box(GOLD if primary else PANEL))
	b.add_theme_stylebox_override("hover", box(Color("ffe18b") if primary else Color("34496f")))
	b.add_theme_stylebox_override("pressed", box(Color("c99730") if primary else INK))
	b.add_theme_stylebox_override("focus", box(Color.TRANSPARENT, 16, WHITE))
	b.add_theme_color_override("font_color", INK if primary else WHITE)
	b.add_theme_color_override("font_hover_color", INK if primary else WHITE)
	return b
