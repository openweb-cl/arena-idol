class_name ArenaDefinition
extends Resource
## Cancha común de 26 x 14 m. Colisión, visual y navegación usan estos Rect2 XZ.
const HALF_WIDTH := 13.0
const HALF_DEPTH := 7.0
@export var id := ""
@export var display_name := ""
@export var obstacles: Array[Rect2] = []
@export var player_spawn := Vector3(-10, 0, 0)
@export var bot_spawn := Vector3(10, 0, 0)
@export var wall_color := Color("476783")

func clear_segment(from: Vector2, to: Vector2, clearance: float = 0.55) -> bool:
	for obstacle in obstacles:
		var rect := obstacle.grow(clearance)
		if rect.has_point(from) or rect.has_point(to):
			return false
		var corners := [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
		for i in 4:
			if Geometry2D.segment_intersects_segment(from, to, corners[i], corners[(i + 1) % 4]) != null:
				return false
	return true
