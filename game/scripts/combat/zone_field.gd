class_name ZoneField
extends Node3D
## Súper de zona (Campo de Dominio): aviso fijo en el mundo, pulso único de daño y
## empuje radial, y campo lento temporal. La arena lo avanza; pausa = no avanzar.
## Cobertura entre el centro y el actor bloquea pulso, empuje y ralentización.
## Aspecto delegado a AbilityEffect (Claude Code); aquí no se decide estilo.
var source: ArenaPlayer
var team := 0
var radius := 3.0
var warning := 0.6
var duration := 3.0
var slow := 0.25
var push := 10.0
var damage := 900
var fallback_direction := Vector3.RIGHT  ## salida si un actor coincide con el centro
var enabled := true
var age := 0.0
var triggered := false
var cancelled := false
var pulse_hits := 0
var effects: Array[Node] = []
var effect_kind := "principe_field"

func setup(owner_actor: ArenaPlayer, center: Vector3) -> void:
	source = owner_actor
	team = owner_actor.team
	var def := owner_actor.definition
	radius = def.super_radius
	warning = def.field_warning
	duration = def.field_duration
	slow = def.field_slow
	push = def.field_push
	damage = def.super_damage
	fallback_direction = owner_actor.facing
	effect_kind = def.field_effect
	position = Vector3(center.x, 0, center.z)

func finished() -> bool:
	return cancelled or age >= warning + duration

func active() -> bool:
	return triggered and not finished()

## Avanza el campo; `hit` recibe (objetivo, fuente, daño, empuje) solo en el pulso.
func tick(delta: float, actors: Array[ArenaPlayer], hit: Callable) -> void:
	if not enabled or finished():
		return
	age += delta
	if triggered:
		return
	# Eliminado antes de activar: se cancela sin devolver carga.
	if not is_instance_valid(source) or source.knocked_out:
		cancelled = true
		return
	if age >= warning:
		triggered = true
		for actor in actors:
			if affects(actor):
				var away := actor.global_position - global_position
				away.y = 0
				var direction := away.normalized() if away.length() > 0.05 else fallback_direction
				hit.call(actor, source, damage, direction * push)
				pulse_hits += 1

func affects(actor: ArenaPlayer) -> bool:
	if not is_instance_valid(actor) or actor.knocked_out or actor.team == team:
		return false
	var offset := actor.global_position - global_position
	offset.y = 0
	if offset.length() > radius:
		return false
	var from := global_position + Vector3.UP * CombatAim.HEIGHT
	var query := PhysicsRayQueryParameters3D.create(from, CombatAim.origin(actor), 1)
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

## Ralentización que este campo aplica ahora a `actor` (0 si no le afecta).
func slow_for(actor: ArenaPlayer) -> float:
	if not active() or actor.invulnerable > 0 or not affects(actor):
		return 0.0
	return slow

func set_paused(paused: bool) -> void:
	enabled = not paused
	for effect in effects:
		if is_instance_valid(effect):
			effect.set_process(not paused)
