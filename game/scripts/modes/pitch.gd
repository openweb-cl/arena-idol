class_name ArenaPitch
extends Node3D
## Arena Prisma, geometría provisional. No porterías ni objetivos deportivos.
const HALF_WIDTH := 13.0
const HALF_DEPTH := 7.0
@export var definition: ArenaDefinition = preload("res://data/maps/prisma_a.tres")
## true: aspecto artístico de ArenaDressing; false: graybox provisional anterior.
@export var dressed := true

func _ready() -> void:
	# Colliders: siempre los mismos, derivados del Resource (gameplay y navegación).
	for z in [-7.2, 7.2]:
		wall(Vector3(0, 0.6, z), Vector3(26.8, 1.2, 0.4), Color("263b56"))
	for x in [-13.2, 13.2]:
		wall(Vector3(x, 0.6, 0), Vector3(0.4, 1.2, 14.4), Color("263b56"))
	for index in definition.obstacles.size():
		var rect := definition.obstacles[index]
		var center := rect.get_center()
		var obstacle := wall(Vector3(center.x, 0.75, center.y), Vector3(rect.size.x, 1.5, rect.size.y), definition.wall_color)
		obstacle.set_meta("obstacle_index", index)
	if dressed:
		# Aspecto artístico (Claude Code): solo visual, exacto sobre cada Rect2.
		var dressing := ArenaDressing.new()
		dressing.name = "ArenaDressing"
		dressing.definition = definition
		add_child(dressing)
		return
	# Graybox provisional anterior (dressed = false).
	ArenaGeometry.box(self, Vector3(0, -0.5, 0), Vector3(29, 0.8, 19), Color("152b3e"))
	for i in 13:
		ArenaGeometry.box(self, Vector3(-12 + i * 2, -0.04, 0), Vector3(2, 0.08, 14), Color("286756") if i % 2 else Color("2c6f5f"))
	for z in [-7.2, 7.2]:
		ArenaGeometry.box(self, Vector3(0, 1.21, z), Vector3(26.6, 0.05, 0.15), Color("55c5b0"))
	for rect in definition.obstacles:
		var center := rect.get_center()
		ArenaGeometry.box(self, Vector3(center.x, 1.51, center.y), Vector3(rect.size.x * 0.8, 0.06, 0.15), Color("9bccc3"))
	for spawn: Vector3 in [definition.player_spawn, definition.bot_spawn]:
		var pad := Node3D.new()
		pad.position = spawn
		add_child(pad)
		ArenaGeometry.ring(pad, 1.05, Color("64cffe") if spawn.x < 0 else Color("ff9a72"))
	for side in [-1, 1]:
		for row in 2:
			var z: float = side * (8.3 + row * 0.75)
			ArenaGeometry.box(self, Vector3(0, row * 0.6, z), Vector3(26, 0.7, 0.75), Color("202d4f"))
			for seat in 17:
				ArenaGeometry.box(self, Vector3(-12 + seat * 1.5, 0.5 + row * 0.6, z), Vector3(0.6, 0.23, 0.5), Color("446582") if seat % 3 else Color("ddaf52"))

func wall(at: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = at
	body.collision_layer = 1
	body.collision_mask = 0
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)
	if not dressed:
		ArenaGeometry.box(body, Vector3.ZERO, size, color)
	return body
