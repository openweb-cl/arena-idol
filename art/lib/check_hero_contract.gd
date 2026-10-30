extends SceneTree
## Verificación del contrato de arte de un héroe (muestras provisionales).
## Vive fuera de game/ para no empaquetarse ni tocar las pruebas de Codex.
## Uso: godot --headless --path game --script ../art/lib/check_hero_contract.gd -- --hero=turbo
var hero := "turbo"
const CLIPS := {"idle": true, "run": true, "kick": false, "hit": false, "celebrate": true}
var passed := 0
var failed := 0

func check(ok: bool, label: String) -> void:
	if ok:
		passed += 1
		print("  OK  ", label)
	else:
		failed += 1
		print("  FALLO  ", label)

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--hero="):
			hero = arg.trim_prefix("--hero=")
	call_deferred("run")

func run() -> void:
	print("HÉROE ", hero)
	var scene: PackedScene = load("res://assets/models/%s/%s.glb" % [hero, hero])
	check(scene != null, "GLB importado sin Blender")
	var model := scene.instantiate() as Node3D
	root.add_child(model)
	var player := model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	check(player != null, "AnimationPlayer con nombre exacto")
	for clip in CLIPS:
		var has := player != null and player.has_animation(clip)
		check(has, "clip " + clip)
		if has:
			var anim := player.get_animation(clip)
			var looped := anim.loop_mode != Animation.LOOP_NONE
			check(looped == CLIPS[clip], "%s loop=%s (%.2f s)" % [clip, looped, anim.length])
			check(not _moves_root(anim), clip + " sin root motion (hueso root inmóvil)")
	check(model.find_children("*", "Camera3D", true, false).is_empty(), "sin cámaras embebidas")
	check(model.find_children("*", "Light3D", true, false).is_empty(), "sin luces embebidas")
	check(model.find_children("*", "CollisionShape3D", true, false).is_empty(), "sin física embebida")
	var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
	check(skeleton != null, "Skeleton3D presente")
	check(model.find_child("Muzzle", true, false) != null, "socket Muzzle")
	check(model.find_child("VFXOrigin", true, false) != null, "socket VFXOrigin")
	var meshes := model.find_children("*", "MeshInstance3D", true, false)
	var triangles := 0
	var materials := {}
	var bounds := AABB()
	var first := true
	for node in meshes:
		var mi := node as MeshInstance3D
		for s in mi.mesh.get_surface_count():
			var arrays := mi.mesh.surface_get_arrays(s)
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			triangles += indices.size() / 3 if indices.size() > 0 else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
			var mat := mi.get_active_material(s)
			if mat != null:
				materials[mat.resource_name] = mat
		var box := mi.global_transform * mi.mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	print("MÉTRICAS triángulos=%d superficies/materiales=%d huesos=%d altura=%.2f m ancho=%.2f m fondo=%.2f m" % [
		triangles, materials.size(), skeleton.get_bone_count() if skeleton else 0, bounds.size.y, bounds.size.x, bounds.size.z])
	check(triangles <= 8000, "presupuesto <=8000 triángulos (%d)" % triangles)
	check(materials.size() <= 8, "presupuesto <=8 materiales (%d)" % materials.size())
	check(absf(bounds.size.y - 2.0) <= 0.15, "altura aproximada 2 m (%.2f)" % bounds.size.y)
	check(absf(bounds.position.y) <= 0.03, "pies en el origen (min y %.3f)" % bounds.position.y)
	var center := bounds.get_center()
	check(absf(center.x) <= 0.05 and absf(center.z) <= 0.08, "centrado en X/Z (%.3f, %.3f)" % [center.x, center.z])
	for mat in materials.values():
		var std := mat as StandardMaterial3D
		check(std != null and std.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED, "material opaco " + str(mat.resource_name))
	# Frente -Z: la punta de las botas y el socket Muzzle deben quedar en -Z.
	var muzzle := model.find_child("Muzzle", true, false) as Node3D
	if muzzle != null:
		check(muzzle.global_position.z < -0.3, "frente hacia -Z (Muzzle z=%.2f)" % muzzle.global_position.z)
	model.queue_free()
	# Integración real a través del adaptador de Codex, sin modificarlo.
	var definition: CharacterDefinition = load("res://data/characters/%s.tres" % hero)
	check(definition.model_scene != null, hero + ".tres usa model_scene")
	var visual := CharacterVisual.new()
	visual.definition = definition
	root.add_child(visual)
	await process_frame
	check(visual.animation_player != null, "CharacterVisual encuentra AnimationPlayer")
	check(visual.find_child("PLACEHOLDER_REPLACE_WITH_GLB", true, false) == null, "sin placeholder procedural")
	visual.speed_ratio = 1.0
	await process_frame
	check(visual.animation_player.current_animation == "run", "velocidad normalizada activa run")
	visual.trigger("kick")
	await process_frame
	check(visual.animation_player.current_animation == "kick", "trigger kick")
	visual.queue_free()
	print("CONTRATO %s: %d aprobadas; %d fallos" % [hero.to_upper(), passed, failed])
	quit(1 if failed else 0)

func _moves_root(anim: Animation) -> bool:
	for t in anim.get_track_count():
		var path := str(anim.track_get_path(t))
		if path.ends_with(":root") and anim.track_get_type(t) == Animation.TYPE_POSITION_3D:
			var first: Vector3 = anim.track_get_key_value(t, 0)
			for k in anim.track_get_key_count(t):
				if not (anim.track_get_key_value(t, k) as Vector3).is_equal_approx(first):
					return true
	return false
