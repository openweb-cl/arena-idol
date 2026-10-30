extends SceneTree
## Verifica que el vestido visual de la arena respete la geometría de juego:
## 1) dentro de la cancha, todo lo que se eleva del suelo está sobre un Rect2 de
##    cobertura (no hay obstáculos visuales sin collider);
## 2) cada cobertura dibuja las cuatro esquinas exactas de su Rect2 a 0 y 1,5 m;
## 3) colliders y navegación siguen en ArenaPitch (cuenta de obstacle_index).
## Uso: godot --headless --path game --script ../art/lib/check_arena_dressing.gd
const TOLERANCE := 0.02
const FLOOR_HEIGHT := 0.05
var failed := 0
var passed := 0

func check(ok: bool, label: String) -> void:
	if ok:
		passed += 1
		print("  OK  ", label)
	else:
		failed += 1
		print("  FALLO  ", label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for layout: ArenaDefinition in GameSession.ARENAS:
		var pitch := ArenaPitch.new()
		pitch.definition = layout
		root.add_child(pitch)
		await process_frame
		var dressing := pitch.get_node_or_null("ArenaDressing") as ArenaDressing
		check(dressing != null, "%s: ArenaDressing presente" % layout.id)
		var colliders := pitch.get_children().filter(func(n: Node) -> bool: return n.has_meta("obstacle_index")).size()
		check(colliders == layout.obstacles.size(), "%s: %d colliders de cobertura intactos" % [layout.id, colliders])
		var stray := 0
		var corners_found := {}
		for batch in ["Arena_solid", "Arena_glow"]:
			var instance := dressing.get_node(batch) as MeshInstance3D
			var verts: PackedVector3Array = instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
			for v in verts:
				var inside_field := absf(v.x) < ArenaDefinition.HALF_WIDTH - TOLERANCE and absf(v.z) < ArenaDefinition.HALF_DEPTH - TOLERANCE
				if not inside_field or v.y <= FLOOR_HEIGHT:
					continue
				var covered := false
				for index in layout.obstacles.size():
					var rect := layout.obstacles[index].grow(TOLERANCE)
					if rect.has_point(Vector2(v.x, v.z)):
						covered = true
						var exact := layout.obstacles[index]
						for corner in [exact.position, Vector2(exact.end.x, exact.position.y), exact.end, Vector2(exact.position.x, exact.end.y)]:
							if Vector2(v.x, v.z).distance_to(corner) < 0.001 and (absf(v.y - 1.5) < 0.001):
								corners_found["%d/%s" % [index, corner]] = true
						break
				if not covered:
					stray += 1
		check(stray == 0, "%s: sin geometría visual elevada fuera de la cobertura (%d vértices)" % [layout.id, stray])
		check(corners_found.size() == layout.obstacles.size() * 4, "%s: esquinas superiores exactas de cada Rect2 (%d/%d)" % [layout.id, corners_found.size(), layout.obstacles.size() * 4])
		pitch.queue_free()
		await process_frame
	print("ARENA VISUAL: %d aprobadas; %d fallos" % [passed, failed])
	quit(1 if failed else 0)
