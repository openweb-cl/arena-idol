class_name AbilityEffect
extends Node3D
## VFX provisional; no autoridad sobre daño, movimiento ni puntuación.
var color := Color.CYAN
var kind := "sprint"
var age := 0.0
var life := 0.5
var ring: MeshInstance3D
var quality := true

func _ready() -> void:
	ring = ArenaGeometry.ring(self, 0.6, color)
	if quality and kind == "turbo_super":
		for i in 5:
			var shard := ArenaGeometry.box(self, Vector3((i - 2) * 0.3, 0.4, -0.5 - absf(i - 2) * 0.15), Vector3(0.07, 0.1, 1.2), color)
			shard.rotation.y = (i - 2) * 0.2
	elif kind == "charge":
		ArenaGeometry.box(self, Vector3(0, 0.6, -0.8), Vector3(1.3, 0.1, 0.2), color)

func _process(delta: float) -> void:
	age += delta
	var t := age / life
	if kind == "rey_super":
		scale = Vector3.ONE * (1 + t * 4)
	else:
		scale = Vector3.ONE * (1 + t * 1.5)
	position.y = t * 0.3
	if age >= life:
		queue_free()
