class_name AbilityEffect
extends Node3D
## VFX originales de combate (muestra V1, provisional). Sin autoridad sobre daño,
## movimiento ni puntuación: solo representa eventos que emite gameplay.
## Posición en los pies del actor; -Z local es su frente. Duración 0,2–0,7 s.
## Tipos: shot, turbo_sprint, turbo_super, melee, rey_charge, rey_super, hit,
## shield, impact_cover, elimination. Alias heredados: sprint, charge.
## Príncipe (preparados para su gameplay): principe_shot, principe_buff,
## principe_field_warning, principe_field. Los dos campos se colocan en el centro
## del área (no en el actor) y usan `radius` y `duration` de gameplay.
var color := Color.CYAN
var kind := "sprint"
var age := 0.0
var life := 0.5
var quality := true
var follow: Node3D  ## opcional: el efecto acompaña al actor (sprint, embestida)
var radius := 4.5  ## alcance real de la súper radial, para que la onda lo muestre
var duration := 0.0  ## si > 0 sustituye la vida por defecto (tiempos que dicta gameplay)
var parts: Array[Node3D] = []
var bolts: Node3D
var bolt_timer := 0.0

const LIVES := {
	"shot": 0.2, "turbo_sprint": 0.45, "turbo_super": 0.5, "melee": 0.3, "rey_charge": 0.4,
	"rey_super": 0.65, "hit": 0.3, "shield": 0.35, "impact_cover": 0.25, "elimination": 0.7,
	"principe_shot": 0.2, "principe_buff": 0.8, "principe_field_warning": 0.6, "principe_field": 3.0,
}

func _ready() -> void:
	kind = {"sprint": "turbo_sprint", "charge": "rey_charge"}.get(kind, kind)
	life = duration if duration > 0.0 else LIVES.get(kind, 0.5)
	match kind:
		"shot": _build_shot()
		"turbo_sprint": _build_sprint()
		"turbo_super": _build_turbo_super()
		"melee": _build_melee()
		"rey_charge": _build_charge()
		"rey_super": _build_rey_super()
		"hit": _build_hit()
		"shield": _build_shield()
		"impact_cover": _build_cover()
		"elimination": _build_elimination()
		"principe_shot": _build_principe_shot()
		"principe_buff": _build_principe_buff()
		"principe_field_warning": _build_field_warning()
		"principe_field": _build_field()
		_:
			parts.append(VFXKit.ring(self, Vector3(0, 0.05, 0), 0.6, 0.07, color))

func amount(full: int) -> int:
	return full if quality else maxi(1, full / 3)

# --- Construcción ----------------------------------------------------------
func _build_shot() -> void:
	# Chispazo en la boca de disparo de Turbo, a la altura del socket Muzzle.
	var muzzle := Vector3(0, 1.05, -0.55)
	parts.append(VFXKit.star(self, muzzle, 0.75, 0.06, VFXKit.TURBO_SPARK))
	parts.append(VFXKit.sphere(self, muzzle, 0.14, VFXKit.TURBO_BLUE, 8))
	for p in parts:
		VFXKit.on_top(p)
	VFXKit.sparks(self, muzzle, amount(8), VFXKit.TURBO_BOLT, 5.0, 0.2, Vector3.FORWARD, 25, 0)

func _build_sprint() -> void:
	# Estelas de velocidad detrás del cuerpo y anillo eléctrico donde arranca.
	for i in 5:
		var h := 0.35 + i * 0.28
		var streak := VFXKit.box(self, Vector3((i - 2) * 0.12, h, 0.9), Vector3(0.05, 0.05, 1.2), VFXKit.TURBO_BLUE if i % 2 else VFXKit.TURBO_BOLT)
		parts.append(streak)
	_spawn_static("start_ring")
	if quality:
		bolts = VFXKit.bolt(self, Vector3(-0.3, 1.4, 0.2), Vector3(0.3, 0.3, 0.5), 5, 0.12, 0.035, VFXKit.TURBO_BOLT)

func _build_turbo_super() -> void:
	# Bombazo: carga en el suelo, rayos verticales y abanico de esquirlas al frente.
	parts.append(VFXKit.ring(self, Vector3(0, 0.05, 0), 0.8, 0.09, VFXKit.TURBO_BOLT))
	parts.append(VFXKit.ring(self, Vector3(0, 0.07, 0), 0.5, 0.06, VFXKit.TURBO_RED))
	parts.append(VFXKit.star(self, Vector3(0, 1.05, -0.7), 1.1, 0.08, VFXKit.TURBO_SPARK))
	var fan := amount(5)
	for i in fan:
		var offset := (i - (fan - 1) / 2.0)
		var shard := VFXKit.box(self, Vector3(offset * 0.28, 0.9, -0.9 - absf(offset) * 0.12), Vector3(0.07, 0.07, 1.1), VFXKit.TURBO_BLUE if i % 2 else VFXKit.TURBO_BOLT)
		shard.rotation.y = -offset * 0.18
		parts.append(shard)
	if quality:
		bolts = Node3D.new()
		add_child(bolts)
		for a in 3:
			var ang := TAU * a / 3.0
			VFXKit.bolt(bolts, Vector3(cos(ang) * 0.7, 0.05, sin(ang) * 0.7), Vector3(cos(ang) * 0.4, 1.9, sin(ang) * 0.4), 5, 0.1, 0.04, VFXKit.TURBO_BOLT)
	VFXKit.sparks(self, Vector3(0, 1.0, -0.6), amount(16), VFXKit.TURBO_BOLT, 7.0, 0.35, Vector3.FORWARD, 35, -2)

func _build_melee() -> void:
	# Golpe real de Rey: arco dorado que barre de derecha a izquierda.
	var swipe := VFXKit.arc(self, Vector3(0, 1.0, 0), 1.35, 150, 0.5, 0.0, VFXKit.REY_GOLD)
	swipe.rotation_degrees = Vector3(-10, 50, 0)
	parts.append(swipe)
	var core := VFXKit.arc(self, Vector3(0, 1.0, 0), 1.35, 110, 0.18, 0.0, VFXKit.HIT_CORE)
	core.rotation_degrees = Vector3(-10, 50, 0)
	parts.append(core)
	VFXKit.sparks(self, Vector3(0, 0.08, -0.9), amount(10), Color("d9c7a3"), 2.5, 0.35, Vector3.UP, 70, -4)

func _build_charge() -> void:
	# Embestida Real: escudo ámbar frontal que acompaña al Rey y polvo a sus pies.
	var wall := VFXKit.arc(self, Vector3(0, 0.15, 0), 0.95, 120, 0.12, 1.5, VFXKit.REY_AMBER)
	parts.append(wall)
	var rim := VFXKit.arc(self, Vector3(0, 0.15, 0), 1.0, 100, 0.06, 1.2, VFXKit.REY_GOLD)
	parts.append(rim)
	_spawn_static("dust")

func _build_rey_super() -> void:
	# Dominio Real: onda violeta hasta el radio real de daño y corona dorada que emerge.
	parts.append(VFXKit.ring(self, Vector3(0, 0.06, 0), 1.0, 0.16, VFXKit.REY_VIOLET))
	parts.append(VFXKit.ring(self, Vector3(0, 0.08, 0), 1.0, 0.06, VFXKit.REY_GOLD))
	var crown := Node3D.new()
	add_child(crown)
	for i in 5:
		var ang := TAU * i / 5.0
		var spike := VFXKit.box(crown, Vector3(cos(ang) * 0.85, 0.5, sin(ang) * 0.85), Vector3(0.14, 1.0, 0.14), VFXKit.REY_GOLD)
		spike.rotation.z = cos(ang) * 0.25
		spike.rotation.x = -sin(ang) * 0.25
	parts.append(crown)
	if quality:
		for i in 8:
			var ang := TAU * i / 8.0 + 0.2
			var crack := VFXKit.box(self, Vector3(cos(ang) * 1.6, 0.04, sin(ang) * 1.6), Vector3(0.06, 0.02, 1.8), VFXKit.REY_VIOLET)
			crack.rotation.y = -ang + PI / 2
			parts.append(crack)
	VFXKit.sparks(self, Vector3(0, 0.2, 0), amount(18), VFXKit.REY_VIOLET, 6.0, 0.5, Vector3.UP, 85, -8)

func _build_hit() -> void:
	# Impacto recibido: estrella blanca con borde naranja y chispas radiales.
	parts.append(VFXKit.star(self, Vector3(0, 1.1, 0), 1.3, 0.09, VFXKit.HIT_EDGE))
	parts.append(VFXKit.star(self, Vector3(0, 1.1, 0), 0.8, 0.11, VFXKit.HIT_CORE))
	for p in parts:
		VFXKit.on_top(p)
	VFXKit.sparks(self, Vector3(0, 1.0, 0), amount(10), VFXKit.HIT_EDGE, 4.5, 0.3, Vector3.UP, 180, -6)

func _build_shield() -> void:
	# Golpe bloqueado por protección: burbuja translúcida breve (única transparencia).
	parts.append(VFXKit.sphere(self, Vector3(0, 0.95, 0), 0.85, VFXKit.SHIELD, 10))
	parts.append(VFXKit.ring(self, Vector3(0, 0.05, 0), 0.85, 0.06, Color("c8ecff")))

func _build_cover() -> void:
	# Proyectil detenido por cobertura: estallido ámbar contra el muro.
	parts.append(VFXKit.star(self, Vector3.ZERO, 0.5, 0.05, VFXKit.COVER))
	VFXKit.sparks(self, Vector3.ZERO, amount(8), VFXKit.COVER, 3.5, 0.25, Vector3.UP, 120, -8)

func _build_elimination() -> void:
	# Eliminación: columna de luz y esquirlas con el color del héroe.
	parts.append(VFXKit.box(self, Vector3(0, 1.4, 0), Vector3(0.5, 2.8, 0.5), Color.WHITE))
	parts.append(VFXKit.ring(self, Vector3(0, 0.05, 0), 0.9, 0.12, color))
	VFXKit.sparks(self, Vector3(0, 1.0, 0), amount(20), color, 6.0, 0.6, Vector3.UP, 60, -9, 0.1)

# --- Príncipe #20 ------------------------------------------------------------
func _build_principe_shot() -> void:
	# Pulso Certero: destello rojo y claro, estrecho y recto (precisión).
	var muzzle := Vector3(0, 1.05, -0.5)
	parts.append(VFXKit.star(self, muzzle, 0.6, 0.05, VFXKit.PRINCIPE_RED))
	parts.append(VFXKit.sphere(self, muzzle, 0.1, VFXKit.PRINCIPE_LIGHT, 8))
	for p in parts:
		VFXKit.on_top(p)
	VFXKit.sparks(self, muzzle, amount(6), VFXKit.PRINCIPE_RED, 6.0, 0.18, Vector3.FORWARD, 10, 0)

func _build_principe_buff() -> void:
	# Impulso Táctico: anillo y chevrones que suben, más texto (no solo color).
	parts.append(VFXKit.ring(self, Vector3(0, 0.05, 0), 0.75, 0.07, VFXKit.PRINCIPE_RED))
	var chevrons := Node3D.new()
	add_child(chevrons)
	for column in [-0.62, 0.62]:
		for k in 3:
			for s in [-1, 1]:
				var arm := VFXKit.box(chevrons, Vector3(column + s * 0.1, 0.5 + k * 0.4, 0), Vector3(0.24, 0.07, 0.07), VFXKit.PRINCIPE_RED if k % 2 == 0 else VFXKit.PRINCIPE_LIGHT)
				arm.rotation.z = s * deg_to_rad(-35)
	parts.append(chevrons)
	var label := Label3D.new()
	label.text = "PODER +20 %"
	label.font_size = 40
	label.outline_size = 10
	label.pixel_size = 0.008
	label.modulate = VFXKit.PRINCIPE_LIGHT
	label.outline_modulate = VFXKit.PRINCIPE_RED.darkened(0.3)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.position = Vector3(0, 2.3, 0)
	add_child(label)
	parts.append(label)

func _build_field_warning() -> void:
	# Aviso de Campo de Dominio: contorno fijo del radio real, anillo que se cierra
	# como cuenta atrás, marcador central y flechas hacia adentro.
	parts.append(VFXKit.ring(self, Vector3(0, 0.03, 0), radius, 0.1, VFXKit.PRINCIPE_RED))
	parts.append(VFXKit.ring(self, Vector3(0, 0.035, 0), radius, 0.06, VFXKit.PRINCIPE_LIGHT))
	var marker := Node3D.new()
	add_child(marker)
	for r in [45.0, -45.0]:
		var bar := VFXKit.box(marker, Vector3(0, 0.04, 0), Vector3(0.7, 0.03, 0.1), VFXKit.PRINCIPE_RED)
		bar.rotation_degrees.y = r
	parts.append(marker)
	for i in 6:
		var ang := TAU * i / 6.0
		var holder := Node3D.new()
		holder.position = Vector3(cos(ang), 0.04, sin(ang)) * (radius - 0.35)
		holder.rotation.y = -ang
		add_child(holder)
		for s in [-1, 1]:
			var arm := VFXKit.box(holder, Vector3(0, 0, s * 0.1), Vector3(0.28, 0.03, 0.06), VFXKit.PRINCIPE_LIGHT)
			arm.rotation.y = s * deg_to_rad(40)

func _build_field() -> void:
	# Campo de Dominio activo: pulso inicial hasta el radio y zona lenta opaca a ras
	# de suelo con marcas de lentitud que giran despacio.
	parts.append(VFXKit.ring(self, Vector3(0, 0.05, 0), radius, 0.18, VFXKit.PRINCIPE_LIGHT))
	var zone := Node3D.new()
	add_child(zone)
	VFXKit.disk(zone, Vector3(0, 0.02, 0), radius, VFXKit.PRINCIPE_ZONE)
	VFXKit.ring(zone, Vector3(0, 0.03, 0), radius, 0.09, VFXKit.PRINCIPE_RED)
	VFXKit.ring(zone, Vector3(0, 0.03, 0), radius * 0.6, 0.04, VFXKit.PRINCIPE_BLUE)
	parts.append(zone)
	var slow := Node3D.new()
	add_child(slow)
	for i in (6 if quality else 3):
		var ang := TAU * i / (6.0 if quality else 3.0)
		var glyph := Node3D.new()
		glyph.position = Vector3(cos(ang), 0.045, sin(ang)) * radius * 0.78
		glyph.rotation.y = -ang + PI / 2
		slow.add_child(glyph)
		for k in 2:
			for s in [-1, 1]:
				var arm := VFXKit.box(glyph, Vector3(s * 0.11, 0, k * 0.22), Vector3(0.26, 0.02, 0.07), VFXKit.PRINCIPE_LIGHT)
				arm.rotation.y = s * deg_to_rad(35)
	parts.append(slow)
	VFXKit.sparks(self, Vector3(0, 0.15, 0), amount(16), VFXKit.PRINCIPE_RED, 5.0, 0.4, Vector3.UP, 85, -8)

func _spawn_static(variant: String) -> void:
	## Parte que se queda en el lugar de inicio aunque el efecto siga al actor.
	var holder := get_parent() as Node3D
	if holder == null:
		return
	var anchor := Node3D.new()
	anchor.position = position
	anchor.rotation = rotation
	holder.add_child.call_deferred(anchor)
	if variant == "start_ring":
		VFXKit.ring(anchor, Vector3(0, 0.05, 0), 0.55, 0.07, VFXKit.TURBO_BOLT)
		VFXKit.sparks(anchor, Vector3(0, 0.1, 0), amount(10), VFXKit.TURBO_BOLT, 3.0, 0.3, Vector3.UP, 80, -6)
	else:
		VFXKit.sparks(anchor, Vector3(0, 0.08, 0.3), amount(12), Color("d9c7a3"), 2.0, 0.45, Vector3.BACK, 60, -3)
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(anchor.queue_free)

# --- Animación -------------------------------------------------------------
func _process(delta: float) -> void:
	# Un tirón (p. ej. compilación de shaders) no debe consumir el efecto entero de golpe.
	delta = minf(delta, 1.0 / 20.0)
	age += delta
	var t := clampf(age / life, 0, 1)
	var fade := VFXKit.fade(t)
	if is_instance_valid(follow) and kind in ["turbo_sprint", "rey_charge", "principe_buff"]:
		position = follow.position
		rotation.y = atan2(-follow.facing.x, -follow.facing.z) if "facing" in follow else rotation.y
	match kind:
		"shot", "hit", "impact_cover", "principe_shot":
			for p in parts:
				p.scale = Vector3.ONE * (0.4 + VFXKit.ease_out(t * 2.5)) * maxf(0.001, fade)
				p.rotation.z += delta * 6
		"turbo_sprint":
			for p in parts:
				p.scale = Vector3(1, 1, 0.2 + VFXKit.ease_out(t * 3)) * maxf(0.001, fade)
			_flicker(delta, Vector3(-0.3, 1.4, 0.2), Vector3(0.3, 0.3, 0.6))
		"turbo_super":
			for p in parts:
				p.scale = Vector3.ONE * maxf(0.001, (0.6 + t * 1.2) * fade)
			if bolts:
				bolts.scale = Vector3.ONE * maxf(0.001, fade)
		"melee":
			for p in parts:
				p.rotation.y = deg_to_rad(50 - 100 * VFXKit.ease_out(t * 1.6))
				p.scale = Vector3.ONE * maxf(0.001, fade)
		"rey_charge":
			for p in parts:
				p.scale = Vector3(1, VFXKit.fade(maxf(0, t - 0.5) * 2), 1)
		"rey_super":
			var reach := VFXKit.ease_out(t * 1.4) * radius
			# La onda nunca supera el radio real de daño (radius = super_radius).
			parts[0].scale = Vector3(maxf(0.001, reach), maxf(0.001, fade), maxf(0.001, reach))
			parts[1].scale = Vector3(maxf(0.001, reach * 0.96), maxf(0.001, fade), maxf(0.001, reach * 0.96))
			parts[2].position.y = -0.9 + VFXKit.ease_out(t * 4) * 0.9
			parts[2].scale = Vector3.ONE * maxf(0.001, fade)
			for i in range(3, parts.size()):
				parts[i].scale = Vector3(1, 1, VFXKit.ease_out(t * 2)) * maxf(0.001, fade)
		"shield":
			for p in parts:
				p.scale = Vector3.ONE * (0.85 + 0.25 * t) * maxf(0.001, fade)
		"elimination":
			parts[0].scale = Vector3(maxf(0.001, fade), 1.0 + t, maxf(0.001, fade))
			parts[1].scale = Vector3.ONE * (1 + t * 1.5) * maxf(0.001, fade)
		"principe_buff":
			parts[0].scale = Vector3.ONE * (1 + t * 0.6) * fade
			parts[1].position.y = t * 0.6
			parts[1].scale = Vector3.ONE * fade
			parts[2].position.y = 2.3 + t * 0.3
			parts[2].scale = Vector3.ONE * VFXKit.fade(maxf(0, t - 0.6) * 2.5)
		"principe_field_warning":
			parts[1].scale = Vector3(maxf(0.001, 1.0 - t), 1, maxf(0.001, 1.0 - t))
			parts[0].scale = Vector3(1, 1 + 0.5 * sin(age * 30.0), 1)
		"principe_field":
			var pulse := clampf(age / 0.3, 0, 1)
			parts[0].scale = Vector3(maxf(0.001, VFXKit.ease_out(pulse)), 1, maxf(0.001, VFXKit.ease_out(pulse))) * (1.0 if age < 0.35 else 0.001)
			var end_fade := VFXKit.fade(maxf(0, t - 0.85) / 0.15)
			parts[1].scale = Vector3(1, end_fade, 1)
			parts[2].rotation.y += delta * 0.4
			parts[2].scale = Vector3.ONE * end_fade
		_:
			for p in parts:
				p.scale = Vector3.ONE * (1 + t * 1.5)
	if age >= life:
		queue_free()

func _flicker(delta: float, from: Vector3, to: Vector3) -> void:
	if bolts == null:
		return
	bolt_timer -= delta
	if bolt_timer > 0:
		return
	bolt_timer = 0.06
	bolts.queue_free()
	bolts = VFXKit.bolt(self, from, to, 5, 0.12, 0.035, VFXKit.TURBO_BOLT)
