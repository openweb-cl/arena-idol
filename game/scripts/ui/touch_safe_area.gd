class_name TouchSafeArea
extends Node
## Márgenes del menú y conversión de píxeles físicos al canvas lógico estirado.
var padding := Vector4(54, 24, 54, 24)

static func map_rect(display_safe: Rect2, window: Rect2, canvas_size: Vector2) -> Rect2:
	var full := Rect2(Vector2.ZERO, canvas_size)
	if not display_safe.has_area() or not window.has_area():
		return full
	var clipped := display_safe.intersection(window)
	if not clipped.has_area():
		return full
	var factor := canvas_size / window.size
	return Rect2((clipped.position - window.position) * factor, clipped.size * factor)

static func for_canvas(viewport: Viewport, canvas_size: Vector2) -> Rect2:
	return from_screen(Rect2(DisplayServer.get_display_safe_area()), canvas_size, viewport.get_screen_transform())

static func from_screen(display_safe: Rect2, canvas_size: Vector2, canvas_to_screen: Transform2D) -> Rect2:
	var full := Rect2(Vector2.ZERO, canvas_size)
	if not display_safe.has_area():
		return full
	var clipped := (canvas_to_screen.affine_inverse() * display_safe).intersection(full)
	return clipped if clipped.has_area() else full

func _ready() -> void:
	get_viewport().size_changed.connect(refresh)
	call_deferred("refresh")

func refresh() -> void:
	var margin := get_parent() as MarginContainer
	if margin == null:
		return
	var safe := for_canvas(get_viewport(), margin.size)
	margin.add_theme_constant_override("margin_left", ceili(safe.position.x + padding.x))
	margin.add_theme_constant_override("margin_top", ceili(safe.position.y + padding.y))
	margin.add_theme_constant_override("margin_right", ceili(margin.size.x - safe.end.x + padding.z))
	margin.add_theme_constant_override("margin_bottom", ceili(margin.size.y - safe.end.y + padding.w))
