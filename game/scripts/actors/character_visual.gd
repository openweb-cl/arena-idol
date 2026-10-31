class_name CharacterVisual
extends Node3D
## Única frontera del arte. Recursos actuales: PLACEHOLDER, NO ARTE FINAL.
var definition: CharacterDefinition
var model: Node3D
var limbs: Array[Node3D] = []
var animation_player: AnimationPlayer
var phase := 0.0
var speed_ratio := 0.0
var action := ""
var action_time := 0.0
var celebration := false

func _ready() -> void:
	if definition.model_scene != null:
		model = definition.model_scene.instantiate()
		add_child(model)
		model.scale = definition.model_scale
		model.rotation_degrees = definition.model_rotation_degrees
		animation_player = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
		if animation_player == null:
			push_warning("Modelo asignado sin AnimationPlayer; revisar CONTRATO_ARTE_3D.md")
		else:
			for clip in ["idle", "run", "kick", "hit", "celebrate"]:
				if not animation_player.has_animation(clip):
					push_warning("Modelo sin clip: " + clip)
	else:
		create_placeholder()

func create_placeholder() -> void:
	model = Node3D.new()
	model.name = "PLACEHOLDER_REPLACE_WITH_GLB"
	add_child(model)
	var c := definition.color
	var tank := definition.id == "rey"
	var width := 0.72 if tank else 0.52
	ArenaGeometry.box(model, Vector3(0, 1.02, 0), Vector3(width, 0.64, 0.4), c)
	ArenaGeometry.box(model, Vector3(0, 0.69, 0), Vector3(width * 0.85, 0.22, 0.36), Color("242744"))
	var helmet := ArenaGeometry.sphere(model, Vector3(0, 1.67, 0), 0.35, c.lightened(0.22))
	helmet.scale = Vector3(1.0, 1.05, 0.9)
	ArenaGeometry.box(model, Vector3(0, 1.7, -0.29), Vector3(0.48, 0.14, 0.08), Color("101a33"))
	ArenaGeometry.box(model, Vector3(0, 1.71, -0.34), Vector3(0.35, 0.035, 0.02), Color("c4fff2"))
	if tank:
		for x in [-0.49, 0.49]:
			ArenaGeometry.box(model, Vector3(x, 1.27, 0), Vector3(0.28, 0.28, 0.48), Color("615493"))
	else:
		for x in [-0.31, 0.31]:
			var fin := ArenaGeometry.box(model, Vector3(x, 1.65, 0.06), Vector3(0.09, 0.42, 0.22), Color("254a88"))
			fin.rotation_degrees.z = -25 if x < 0 else 25
	for i in 4:
		var pivot := Node3D.new()
		pivot.name = ["ArmL", "ArmR", "LegL", "LegR"][i]
		var side := -1 if i % 2 == 0 else 1
		pivot.position = Vector3(side * (width / 2 + 0.08), 1.24, 0) if i < 2 else Vector3(side * 0.18, 0.64, 0)
		model.add_child(pivot)
		limbs.append(pivot)
		ArenaGeometry.box(pivot, Vector3(0, -0.21, 0), Vector3(0.18, 0.4, 0.22), c.darkened(0.16) if i < 2 else Color("202d4f"))
		ArenaGeometry.sphere(pivot, Vector3(0, -0.4, 0), 0.13, c.lightened(0.12))
		if i >= 2:
			ArenaGeometry.box(pivot, Vector3(0, -0.48, -0.1), Vector3(0.23, 0.17, 0.42), c.lightened(0.3))
	for z in [-0.207, 0.207]:
		var number := Label3D.new()
		number.text = str(definition.number)
		number.font_size = 64
		number.pixel_size = 0.006
		number.position = Vector3(0, 1.07, z)
		number.rotation.y = 0 if z > 0 else PI
		number.modulate = Color("101a33")
		number.outline_size = 0
		model.add_child(number)

func trigger(clip: String) -> void:
	action = clip
	action_time = 0.4
	if animation_player != null and animation_player.has_animation(clip):
		animation_player.play(clip, 0.08)

func _process(delta: float) -> void:
	phase += delta * (4 + speed_ratio * 10)
	action_time = maxf(0, action_time - delta)
	if animation_player != null:
		var clip := "celebrate" if celebration else ("run" if speed_ratio > 0.08 else "idle")
		if action_time <= 0 and animation_player.has_animation(clip) and animation_player.current_animation != clip:
			animation_player.play(clip, 0.12)
		# La zancada sigue a la velocidad real para que los pies no patinen sobre el suelo.
		var running := animation_player.current_animation == "run"
		animation_player.speed_scale = clampf(speed_ratio * definition.speed / definition.run_clip_speed, 0.8, 2.2) if running else 1.0
		return
	if model == null or limbs.size() != 4:
		return
	model.position.y = sin(phase * 0.5) * 0.025 + absf(sin(phase)) * speed_ratio * 0.07
	model.rotation.z = 0
	for i in 4:
		limbs[i].rotation = Vector3(sin(phase + (i % 2) * PI) * speed_ratio * 0.75 * (-1 if i < 2 else 1), 0, 0)
	if celebration:
		model.position.y = absf(sin(phase * 1.4)) * 0.35
		limbs[0].rotation.z = -2.5
		limbs[1].rotation.z = 2.5
	elif action_time > 0:
		if action == "kick":
			limbs[3].rotation.x = -sin(action_time / 0.4 * PI) * 1.4
		elif action == "hit":
			model.rotation.z = sin(action_time * 35) * 0.15
