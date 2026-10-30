class_name ArenaPlayer
extends CharacterBody3D
signal action_requested(actor: ArenaPlayer, kind: String)
signal ability_started(actor: ArenaPlayer)
signal eliminated(actor: ArenaPlayer)
@export var definition: CharacterDefinition = preload("res://data/characters/turbo.tres")
var team := 0
var health := 0
var facing := Vector3.RIGHT
var command := PlayerCommand.new()
var cooldown := 0.0
var attack_cooldown := 0.0
var dash_time := 0.0
var respawn_time := 0.0
var respawn_duration := 4.0
var invulnerable := 0.0
var super_charge := 0.0
var push_velocity := Vector3.ZERO
var move_velocity := Vector3.ZERO
var active := true
var spawn_point := Vector3.ZERO
var visual: CharacterVisual
var dash_direction := Vector3.RIGHT
var knocked_out := false
var dash_hit := false
var health_label: Label3D

func _ready() -> void:
	health = definition.max_health
	collision_layer = 2
	collision_mask = 1 | 2
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.6
	collider.shape = capsule
	collider.position.y = 0.8
	add_child(collider)
	visual = CharacterVisual.new()
	visual.definition = definition
	add_child(visual)
	ArenaGeometry.ring(self, 0.6, Color("35c78a") if team == 0 else Color("ff6464"))
	health_label = Label3D.new()
	health_label.position.y = 2.75
	health_label.font_size = 40
	health_label.pixel_size = 0.011
	health_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	health_label.modulate = Color("aaffd2") if team == 0 else Color("ffaaa2")
	add_child(health_label)

func _physics_process(delta: float) -> void:
	if not active:
		command.clear_actions()
		return
	cooldown = maxf(0, cooldown - delta)
	attack_cooldown = maxf(0, attack_cooldown - delta)
	invulnerable = maxf(0, invulnerable - delta)
	if knocked_out:
		respawn_time -= delta
		if respawn_time <= 0:
			reset_at_spawn()
		command.clear_actions()
		return
	if command.aim.length() > 0.1:
		facing = Vector3(command.aim.x, 0, command.aim.y).normalized()
	if command.ability:
		ability()
	if command.super_shot:
		act("super")
	elif command.shoot:
		act("shot")
	command.clear_actions()
	var direction := Vector3(command.move.x, 0, command.move.y).limit_length()
	if command.aim.length() > 0.1:
		facing = Vector3(command.aim.x, 0, command.aim.y).normalized()
	elif direction.length() > 0.12 and dash_time <= 0:
		facing = direction.normalized()
	var target := direction * definition.speed
	if dash_time > 0:
		dash_time = maxf(0, dash_time - delta)
		target = dash_direction * definition.speed * definition.ability.speed_multiplier
	var acceleration := definition.braking if direction.length() < 0.1 else definition.acceleration
	move_velocity = move_velocity.move_toward(target, acceleration * delta)
	velocity = move_velocity + push_velocity
	push_velocity = push_velocity.move_toward(Vector3.ZERO, 35 * delta)
	move_and_slide()
	position.y = 0
	visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-facing.x, -facing.z), minf(1, definition.turn_speed * delta))
	visual.speed_ratio = minf(1, velocity.length() / definition.speed)
	health_label.text = "#%d · %d PV" % [definition.number, health]

func act(kind: String = "shot") -> bool:
	if not active or knocked_out or attack_cooldown > 0:
		return false
	if kind == "super" and super_charge < 100:
		return false
	attack_cooldown = definition.attack_interval
	if kind == "super":
		super_charge = 0
	visual.trigger("kick")
	action_requested.emit(self, kind)
	return true

func ability() -> bool:
	if not active or knocked_out or cooldown > 0 or definition.ability == null:
		return false
	cooldown = definition.ability.cooldown
	dash_time = definition.ability.duration
	dash_direction = facing
	if definition.attack_type == "Ranged" and command.move.length() > 0.1:
		dash_direction = Vector3(command.move.x, 0, command.move.y).normalized()
	dash_hit = false
	invulnerable = maxf(invulnerable, definition.ability.shield_seconds)
	ability_started.emit(self)
	return true

func take_damage(amount: int, push: Vector3 = Vector3.ZERO) -> bool:
	if knocked_out or invulnerable > 0:
		return false
	health = maxi(0, health - amount)
	push_velocity = push
	visual.trigger("hit")
	if health == 0:
		knocked_out = true
		respawn_time = respawn_duration
		visible = false
		set_collision_layer_value(2, false)
		eliminated.emit(self)
	return true

func reset_at_spawn() -> void:
	position = spawn_point
	velocity = Vector3.ZERO
	command.move = Vector2.ZERO
	command.clear_actions()
	push_velocity = Vector3.ZERO
	move_velocity = Vector3.ZERO
	knocked_out = false
	respawn_time = 0
	health = definition.max_health
	invulnerable = 1.0
	dash_time = 0
	cooldown = 0
	attack_cooldown = 0
	facing = Vector3.RIGHT if team == 0 else Vector3.LEFT
	visible = true
	set_collision_layer_value(2, true)
