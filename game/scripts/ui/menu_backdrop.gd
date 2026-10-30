class_name MenuBackdrop
extends Control
## Fondo original del menú (refresh V2, provisional): degradado tinta, franjas
## diagonales y motivo hexagonal «Prisma». Dibujo vectorial, sin texturas.
var accent := ArenaStyle.GOLD

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var w := size.x
	var h := size.y
	# Degradado vertical en bandas (barato y sin texturas).
	var bands := 24
	for i in bands:
		var t := float(i) / (bands - 1)
		draw_rect(Rect2(0, h * i / bands, w, h / bands + 1), ArenaStyle.INK_DEEP.lerp(Color("1a2a55"), t * t))
	# Franjas diagonales deportivas.
	var stripes := [[0.56, 120.0, Color(1, 1, 1, 0.035)], [0.66, 46.0, Color(accent, 0.10)], [0.71, 14.0, Color(accent, 0.35)], [0.79, 90.0, Color(1, 1, 1, 0.03)]]
	for stripe in stripes:
		var x0: float = w * stripe[0]
		var thick: float = stripe[1]
		var slant := h * 0.42
		draw_colored_polygon(PackedVector2Array([Vector2(x0 + slant, 0), Vector2(x0 + slant + thick, 0), Vector2(x0 + thick, h), Vector2(x0, h)]), stripe[2])
	# Motivo hexagonal «Prisma» en la esquina inferior derecha.
	var center := Vector2(w * 0.86, h * 0.78)
	for ring in 3:
		var r := 120.0 + ring * 70.0
		var points := PackedVector2Array()
		for k in 7:
			var a := TAU * k / 6.0 + PI / 6
			points.append(center + Vector2(cos(a), sin(a)) * r)
		draw_polyline(points, Color(ArenaStyle.MINT, 0.10 - ring * 0.025), 3.0, true)
	# Línea de luz inferior.
	draw_rect(Rect2(0, h - 4, w, 4), Color(ArenaStyle.MINT, 0.5))
