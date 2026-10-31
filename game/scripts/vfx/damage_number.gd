class_name DamageNumber
extends Label3D
## Número de daño flotante (VFX, sin autoridad sobre el combate): sube, crece un
## instante y se desvanece. Blanco = básico, dorado = súper, celeste = escudo.
const LIFE := 0.75
var age := 0.0
var rise := 0.9

func setup(amount: int, kind: String) -> DamageNumber:
	text = ("−%d" % amount) if kind != "shield" else ("ESCUDO −%d" % amount)
	modulate = {"super": Color("ffd34d"), "shield": Color("8fe3ff")}.get(kind, Color("fff6ea"))
	font_size = 52 if kind == "super" else 40
	outline_size = 10
	outline_modulate = Color(0.05, 0.07, 0.14, 0.9)
	pixel_size = 0.01
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	render_priority = 2
	return self

func _process(delta: float) -> void:
	age += minf(delta, 1.0 / 20.0)
	var t := clampf(age / LIFE, 0, 1)
	position.y += rise * delta * (1.0 - t)
	var pop := 1.0 + 0.35 * maxf(0.0, 1.0 - t * 6.0)
	scale = Vector3.ONE * pop
	modulate.a = 1.0 if t < 0.6 else 1.0 - (t - 0.6) / 0.4
	outline_modulate.a = modulate.a * 0.9
	if age >= LIFE:
		queue_free()
