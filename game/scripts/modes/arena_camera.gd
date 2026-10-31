class_name ArenaCamera
extends Camera3D
@export_range(15, 40, 0.5) var base_size: float = 23.0
## Sacudida breve en golpes grandes (súper, eliminación). Desplaza la imagen con
## h_offset/v_offset: la cámara, el apuntado y la física no se mueven.
@export_range(0.0, 1.0, 0.05) var shake_scale: float = 1.0
var trauma := 0.0
var _time := 0.0

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

func shake(amount: float) -> void:
	trauma = clampf(maxf(trauma, amount), 0.0, 1.0)

func _process(delta: float) -> void:
	_time += delta
	trauma = maxf(0.0, trauma - delta * 2.2)
	var power := trauma * trauma * shake_scale * 0.35
	h_offset = sin(_time * 53.0) * power
	v_offset = cos(_time * 47.0) * power
