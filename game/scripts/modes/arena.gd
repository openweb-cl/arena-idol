class_name IdolArena
extends Node3D
const PLAYER_SCENE := preload("res://scenes/actors/player.tscn")
enum Phase { PLAYING, PAUSED, FINISHED }
@export var config: MatchConfig = preload("res://data/match.tres")
var phase := Phase.PLAYING
var rules: MatchRules
var human: ArenaPlayer
var bot: ArenaPlayer
var brain := ArenaBot.new()
var hud: ArenaHUD
var camera: ArenaCamera
var light: DirectionalLight3D
var aim_marker: MeshInstance3D
var projectiles: Array[CombatProjectile] = []
var elapsed := 0.0
var mouse_aim := false
var impacts := 0
var last_message_at := 0.0

func _ready() -> void:
	rules = MatchRules.new(config)
	add_child(ArenaPitch.new())
	light = ArenaGeometry.world(self)
	GraphicsSettings.apply(get_viewport(), light)
	camera = ArenaCamera.new()
	add_child(camera)
	human = spawn_player(GameSession.selected, 0, Vector3(-10, 0, 0))
	var other := CharacterCatalog.AVAILABLE[1] if GameSession.selected.id == "turbo" else CharacterCatalog.AVAILABLE[0]
	bot = spawn_player(other, 1, Vector3(10, 0, 0))
	rules.finished.connect(on_finished)
	hud = ArenaHUD.new()
	add_child(hud)
	hud.pause_requested.connect(toggle_pause)
	hud.replay_requested.connect(func() -> void: get_tree().reload_current_scene())
	hud.menu_requested.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/menu/main.tscn"))
	hud.message.text = "Usa la cobertura · %d eliminaciones para ganar" % config.target_eliminations
	aim_marker = ArenaGeometry.ring(self, 0.25, ArenaStyle.GOLD)
	aim_marker.visible = false
	get_viewport().gui_release_focus()

func spawn_player(def: CharacterDefinition, team: int, point: Vector3) -> ArenaPlayer:
	var actor: ArenaPlayer = PLAYER_SCENE.instantiate()
	actor.definition = def
	actor.team = team
	actor.respawn_duration = config.respawn_seconds
	actor.spawn_point = point
	actor.position = point
	actor.facing = Vector3.RIGHT if team == 0 else Vector3.LEFT
	add_child(actor)
	actor.action_requested.connect(on_action)
	actor.ability_started.connect(on_ability)
	actor.eliminated.connect(on_eliminated)
	return actor

func _physics_process(delta: float) -> void:
	projectiles = projectiles.filter(func(p: CombatProjectile) -> bool: return is_instance_valid(p) and not p.is_queued_for_deletion())
	if phase == Phase.PLAYING:
		elapsed += delta
		rules.tick(delta)
		if phase != Phase.PLAYING:
			return
		human.command.move = keyboard_direction()
		if mouse_aim:
			update_aim()
		brain.update(bot, human, projectiles, delta)
		for actor: ArenaPlayer in [human, bot]:
			actor.position.x = clampf(actor.position.x, -12.5, 12.5)
			actor.position.z = clampf(actor.position.z, -6.5, 6.5)
			if actor.dash_time > 0 and not actor.dash_hit and actor.definition.ability.contact_damage > 0:
				var rival := bot if actor == human else human
				if actor.position.distance_to(rival.position) < 1.6:
					actor.dash_hit = true
					apply_damage(rival, actor, actor.definition.ability.contact_damage, actor.dash_direction * 9)
		if elapsed - last_message_at > 4:
			hud.message.text = ""
	hud.update_state(rules, human)

func keyboard_direction() -> Vector2:
	var x := float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
	var y := float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	return Vector2(x, y).limit_length()

func update_aim() -> void:
	var point := get_viewport().get_mouse_position()
	var origin := camera.project_ray_origin(point)
	var ray := camera.project_ray_normal(point)
	var hit: Variant = Plane(Vector3.UP, 0).intersects_ray(origin, ray)
	if hit != null:
		var at: Vector3 = hit
		aim_marker.position = at + Vector3.UP * 0.03
		aim_marker.visible = true
		var aim := at - human.position
		human.command.aim = Vector2(aim.x, aim.z).normalized()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_aim = true
	if phase == Phase.PLAYING and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			human.command.shoot = true
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			human.command.super_shot = true
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_ESCAPE: toggle_pause()
		KEY_F3: hud.show_metrics = not hud.show_metrics
		KEY_SPACE:
			if phase == Phase.PLAYING: human.command.shoot = true
		KEY_E, KEY_SHIFT:
			if phase == Phase.PLAYING: human.command.ability = true
		KEY_Q:
			if phase == Phase.PLAYING: human.command.super_shot = true

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(hud) and phase == Phase.PLAYING:
		toggle_pause()

func on_action(actor: ArenaPlayer, kind: String) -> void:
	if phase != Phase.PLAYING:
		return
	var is_super := kind == "super"
	if actor.definition.attack_type == "Ranged":
		var projectile := CombatProjectile.new()
		projectile.source = actor
		projectile.damage = actor.definition.super_damage if is_super else actor.definition.attack_damage
		projectile.direction = actor.facing
		projectile.speed = actor.definition.projectile_speed * (1.45 if is_super else 1.0)
		projectile.max_distance = actor.definition.attack_range * (1.3 if is_super else 1.0)
		projectile.power = is_super
		projectile.position = actor.position + Vector3.UP * 0.85
		projectile.hit.connect(apply_damage)
		add_child(projectile)
		projectiles.append(projectile)
		spawn_effect(actor, "turbo_super" if is_super else "sprint", Color("62e7ff"))
	else:
		var rival := bot if actor == human else human
		var offset := rival.position - actor.position
		var reach := actor.definition.super_radius if is_super else actor.definition.attack_range
		if not rival.knocked_out and offset.length() <= reach and (is_super or actor.facing.dot(offset.normalized()) > 0.25) and brain.line_clear(actor, rival):
			apply_damage(rival, actor, actor.definition.super_damage if is_super else actor.definition.attack_damage, offset.normalized() * actor.definition.attack_push * (2 if is_super else 1))
		spawn_effect(actor, "rey_super" if is_super else "charge", Color("ba8bff") if is_super else actor.definition.color)

func apply_damage(target: ArenaPlayer, source: ArenaPlayer, damage: int, push: Vector3) -> void:
	if phase != Phase.PLAYING or target.team == source.team:
		return
	if target.take_damage(damage, push):
		impacts += 1
		source.super_charge = minf(100, source.super_charge + source.definition.charge_per_hit)
		spawn_effect(target, "hit", Color("ffbb85"))

func on_ability(actor: ArenaPlayer) -> void:
	spawn_effect(actor, "sprint" if actor.definition.attack_type == "Ranged" else "charge", actor.definition.ability.effect_color)

func spawn_effect(actor: ArenaPlayer, kind: String, color: Color) -> void:
	var effect := AbilityEffect.new()
	effect.kind = kind
	effect.color = color
	effect.quality = not GraphicsSettings.low
	effect.position = actor.position
	effect.rotation.y = atan2(-actor.facing.x, -actor.facing.z)
	add_child(effect)

func on_eliminated(actor: ArenaPlayer) -> void:
	if phase != Phase.PLAYING:
		return
	hud.message.text = "¡Eliminación rival!" if actor == bot else "Te han eliminado · Reaparecerás pronto"
	last_message_at = elapsed
	rules.score(1 - actor.team)

func freeze_combat(freeze: bool) -> void:
	human.active = not freeze
	bot.active = not freeze
	human.command.clear_actions()
	bot.command.clear_actions()
	for projectile in projectiles:
		if is_instance_valid(projectile):
			projectile.enabled = not freeze

func toggle_pause() -> void:
	if phase == Phase.FINISHED:
		return
	if phase == Phase.PAUSED:
		phase = Phase.PLAYING
		hud.overlay.hide()
		freeze_combat(false)
		get_viewport().gui_release_focus()
	else:
		phase = Phase.PAUSED
		freeze_combat(true)
		hud.show_overlay("PAUSA", "Combate, reloj y reapariciones detenidos.", true)

func on_finished() -> void:
	phase = Phase.FINISHED
	freeze_combat(true)
	hud.message.text = ""
	human.visual.celebration = rules.scores[0] > rules.scores[1]
	bot.visual.celebration = rules.scores[1] > rules.scores[0]
	hud.update_state(rules, human)
	hud.show_overlay(rules.result(), "Eliminaciones: %d — %d\nBatalla de entrenamiento local" % rules.scores, false)
