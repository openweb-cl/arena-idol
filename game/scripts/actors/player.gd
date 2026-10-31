class_name ArenaPlayer
extends CharacterBody3D
signal action_requested(actor: ArenaPlayer, kind: String)
signal ability_started(actor: ArenaPlayer)
signal eliminated(actor: ArenaPlayer)
signal attack_accepted(actor: ArenaPlayer, kind: String)
@export var definition: CharacterDefinition = preload("res://data/characters/turbo.tres")
@export_range(2.5, 5.0, 0.05) var status_label_height: float = 3.1
var team := 0
var health := 0
var unlimited_ammo := false
var ammo: AmmoState
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
## Estados temporales por actor; nunca se escriben en el Resource compartido.
var power_time := 0.0
var power_multiplier := 1.0
var slow := 0.0  ## ralentización de zonas, la arena la recalcula cada paso físico
var channel_time := 0.0  ## preparación de súper de zona: camina al 50 % y no ataca
var windup_time := 0.0
var pending_kind := ""
var shot_direction := Vector3.RIGHT
var shot_multiplier := 1.0
var super_target: Variant = null  ## centro elegido para una súper de zona (Vector3) o null

func _ready() -> void:
	health = definition.max_health
	ammo = AmmoState.new(definition.ammo, unlimited_ammo)
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
	health_label.position.y = status_label_height
	health_label.font_size = 40
	health_label.pixel_size = 0.009
	health_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
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
	power_time = maxf(0, power_time - delta)
	if power_time <= 0:
		power_multiplier = 1.0
	channel_time = maxf(0, channel_time - delta)
	if knocked_out:
		respawn_time -= delta
		if respawn_time <= 0:
			reset_at_spawn()
		command.clear_actions()
		return
	ammo.tick(delta)
	if windup_time > 0:
		windup_time = maxf(0, windup_time - delta)
		if windup_time <= 0 and not pending_kind.is_empty():
			var kind := pending_kind
			pending_kind = ""
			action_requested.emit(self, kind)
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
	# Zonas y preparación reducen la velocidad propia, también la del sprint/embestida.
	var speed := definition.speed * (1.0 - slow) * (0.5 if channel_time > 0 else 1.0)
	var target := direction * speed
	if dash_time > 0:
		dash_time = maxf(0, dash_time - delta)
		target = dash_direction * speed * definition.ability.speed_multiplier
	var acceleration := definition.braking if direction.length() < 0.1 else definition.acceleration
	move_velocity = move_velocity.move_toward(target, acceleration * delta)
	velocity = move_velocity + push_velocity
	push_velocity = push_velocity.move_toward(Vector3.ZERO, 35 * delta)
	move_and_slide()
	position.y = 0
	visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-facing.x, -facing.z), minf(1, definition.turn_speed * delta))
	visual.speed_ratio = minf(1, velocity.length() / definition.speed)
	health_label.text = "#%d · %d PV" % [definition.number, health]
	if ammo.limited():
		health_label.text += "\n" + ("RECARGANDO" if ammo.charges == 0 else "%d/%d CARGAS" % [ammo.charges, ammo.capacity()])
	if power_time > 0:
		health_label.text += "\nPODER +%d %% · %.1f s" % [roundi((power_multiplier - 1.0) * 100), power_time]
	if slow > 0:
		health_label.text += "\nLENTO −%d %%" % roundi(slow * 100)

func act(kind: String = "shot") -> bool:
	if not active or knocked_out or attack_cooldown > 0 or channel_time > 0 or windup_time > 0:
		return false
	if kind == "super" and super_charge < 100:
		return false
	# Súper de zona sin centro válido: no consume carga.
	if kind == "super" and definition.super_kind == "Field" and super_target == null:
		return false
	if kind == "shot" and not ammo.consume():
		return false
	attack_cooldown = definition.attack_interval
	if kind == "super":
		super_charge = 0
		if definition.super_kind == "Field":
			channel_time = definition.field_warning
	# Dirección y mejora se capturan al aceptar; el proyectil puede salir después.
	shot_direction = facing
	shot_multiplier = damage_multiplier() if kind == "shot" else 1.0
	visual.trigger("kick")
	attack_accepted.emit(self, kind)
	if kind == "shot" and definition.attack_windup > 0:
		windup_time = definition.attack_windup
		pending_kind = kind
	else:
		action_requested.emit(self, kind)
	return true

func damage_multiplier() -> float:
	return power_multiplier if power_time > 0 else 1.0

func ability() -> bool:
	if not active or knocked_out or cooldown > 0 or channel_time > 0 or definition.ability == null:
		return false
	cooldown = definition.ability.cooldown
	if definition.ability.kind == "Power":
		# Igual potencia refresca la duración; una más débil no sustituye a una más fuerte.
		if definition.ability.damage_multiplier >= damage_multiplier():
			power_multiplier = definition.ability.damage_multiplier
			power_time = definition.ability.duration
		ability_started.emit(self)
		return true
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
		windup_time = 0
		pending_kind = ""
		respawn_time = respawn_duration
		visible = false
		set_collision_layer_value(2, false)
		eliminated.emit(self)
	return true

func reset_at_spawn() -> void:
	ammo.reset()
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
	power_time = 0
	power_multiplier = 1.0
	slow = 0
	channel_time = 0
	windup_time = 0
	pending_kind = ""
	super_target = null
	cooldown = 0
	attack_cooldown = 0
	facing = Vector3.RIGHT if team == 0 else Vector3.LEFT
	visible = true
	set_collision_layer_value(2, true)
