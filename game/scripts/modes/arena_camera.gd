class_name ArenaCamera
extends Camera3D
@export_range(15, 40, 0.5) var base_size: float = 23.0

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	position = Vector3(0, 27, 22)
	look_at(Vector3.ZERO)
	current = true
	get_viewport().size_changed.connect(fit_arena)
	fit_arena()

func fit_arena() -> void:
	var rect := get_viewport().get_visible_rect().size
	if rect.y > 0:
		size = maxf(base_size, 32 / (rect.x / rect.y))
