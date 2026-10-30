class_name ProjectileVisual
extends Node3D
## Aspecto del proyectil eléctrico de Turbo (muestra V1, provisional). Solo visual:
## el collider, la velocidad y el daño siguen en CombatProjectile (gameplay).
## Espacio local del proyectil: -Z es la dirección de vuelo.
var power := false
var quality := true
var age := 0.0
var core: MeshInstance3D
var rings: Array[Node3D] = []
var tail: Node3D
var tail_timer := 0.0

func _ready() -> void:
	quality = not GraphicsSettings.low
	var radius := 0.32 if power else 0.16
	# Núcleo amarillo siempre a la vista desde la cámara de juego: nada opaco lo
	# envuelve. El halo azul es menor que el núcleo y va detrás (cabeza de cometa),
	# y los anillos giran en horizontal, por fuera de la silueta del núcleo.
	core = VFXKit.sphere(self, Vector3.ZERO, radius, VFXKit.TURBO_SPARK, 12)
	VFXKit.sphere(self, Vector3(0, 0, radius * 1.35), radius * 0.62, VFXKit.TURBO_BLUE, 10)
	for i in (2 if power else 1):
		var holder := Node3D.new()
		add_child(holder)
		VFXKit.ring(holder, Vector3.ZERO, radius * (1.75 + i * 0.35), 0.05 if power else 0.035, VFXKit.TURBO_BOLT if i == 0 else VFXKit.TURBO_RED)
		rings.append(holder)
	if power:
		VFXKit.box(self, Vector3(0, 0, 0.5), Vector3(0.16, 0.16, 0.9), VFXKit.TURBO_BLUE)
	else:
		VFXKit.box(self, Vector3(0, 0, 0.38), Vector3(0.07, 0.07, 0.62), VFXKit.TURBO_BLUE)
	_rebuild_tail()

func _rebuild_tail() -> void:
	if tail != null:
		tail.queue_free()
	var length := 1.4 if power else 0.9
	tail = VFXKit.bolt(self, Vector3(0, 0, 0.1), Vector3(0, 0, length), 4 if quality else 2,
		0.09 if power else 0.06, 0.05 if power else 0.03, VFXKit.TURBO_BOLT)

func _process(delta: float) -> void:
	age += delta
	for i in rings.size():
		rings[i].rotation.y += delta * (14.0 if i == 0 else -10.0)
	# Pulso que solo agranda: el núcleo nunca se ve menor que el radio del collider.
	core.scale = Vector3.ONE * (1.04 + 0.04 * sin(age * 40.0))
	if quality:
		tail_timer -= delta
		if tail_timer <= 0:
			tail_timer = 0.05
			_rebuild_tail()
