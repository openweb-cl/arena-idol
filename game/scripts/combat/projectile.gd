class_name CombatProjectile
extends CharacterBody3D
signal hit(target: ArenaPlayer, source: ArenaPlayer, damage: int, push: Vector3)
var source: ArenaPlayer
var damage := 850
var direction := Vector3.RIGHT
var speed := 19.0
var max_distance := 13.0
var travelled := 0.0
var power := false
var enabled := true

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 | 2
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	add_collision_exception_with(source)
	var collider := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.32 if power else 0.16
	collider.shape = sphere
	add_child(collider)
	ArenaGeometry.sphere(self, Vector3.ZERO, sphere.radius, Color("c0ffff") if power else Color("65e4ff"))
	var ring := ArenaGeometry.ring(self, sphere.radius * 1.3, Color("248bff"))
	ring.rotation_degrees.x = 90
	var trail := ArenaGeometry.box(self, Vector3(0, 0, 0.4), Vector3(0.06, 0.06, 0.7), Color("2ebdff"))
	trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look_at(position + direction)

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	var step := direction * speed * delta
	var collision := move_and_collide(step)
	travelled += step.length()
	if collision:
		var actor := collision.get_collider() as ArenaPlayer
		if actor != null and actor.team != source.team:
			hit.emit(actor, source, damage, direction * source.definition.attack_push * (2 if power else 1))
		queue_free()
	elif travelled >= max_distance:
		queue_free()
