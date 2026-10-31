class_name IdolArena
extends Node3D
const PLAYER_SCENE := preload("res://scenes/actors/player.tscn")
enum Phase { PLAYING, PAUSED, FINISHED }
@export var training_mode := false
@export var laboratory_unlimited_ammo := false
@export var auto_target_enabled := true
@export var force_touch_controls := false
@export var arena_override: ArenaDefinition
@export var config: MatchConfig = preload("res://data/match.tres")
var phase := Phase.PLAYING
var rules: MatchRules
var human: ArenaPlayer
var bot: ArenaPlayer
var brain: ArenaBot
var layout: ArenaDefinition
var pitch: ArenaPitch
var hud: ArenaHUD
var camera: ArenaCamera
var light: DirectionalLight3D
var aim_marker: MeshInstance3D
var aim_guide: AimGuide
var actors: Array[ArenaPlayer] = []
var auto_target: ArenaPlayer
var target_marker: Node3D
var mouse_fire_held := false
var key_fire_held := false
var show_aim_guide := false
var shot_events: Array[Dictionary] = []
var shot_counts: Dictionary = {}
var training_case := 0
const TRAINING_CASES := ["CORTA / 3 m", "MEDIA / 7 m", "LARGA / 12 m", "COBERTURA", "FUERA DE ALCANCE / 14 m"]
var projectiles: Array[CombatProjectile] = []
var elapsed := 0.0
var mouse_aim := false
var aim_position := Vector2.ZERO
var impacts := 0
var basic_attacks: Array[int] = [0, 0]
var super_attacks: Array[int] = [0, 0]
var damage_events: Array[int] = [0, 0]
var close_seconds: Array[float] = [0, 0]
var report_path := ""
var last_message_at := 0.0
var touch_controls: ArenaTouchControls

func _ready() -> void:
	rules = MatchRules.new(config)
	layout = GameSession.ARENAS[0] if training_mode else (arena_override if arena_override != null else GameSession.selected_arena)
	brain = ArenaBot.new(layout)
	pitch = ArenaPitch.new()
	pitch.definition = layout
	add_child(pitch)
	light = ArenaGeometry.world(self)
	GraphicsSettings.apply(get_viewport(), light)
	camera = ArenaCamera.new()
	add_child(camera)
	human = spawn_player(CharacterCatalog.AVAILABLE[0] if training_mode else GameSession.selected, 0, layout.player_spawn)
	var other := CharacterCatalog.AVAILABLE[1] if human.definition.id == "turbo" else CharacterCatalog.AVAILABLE[0]
	bot = spawn_player(other, 1, layout.bot_spawn)
	rules.finished.connect(on_finished)
	hud = ArenaHUD.new()
	add_child(hud)
	hud.arena_name = "A" if layout.id == "prisma-a" else "B"
	hud.pause_requested.connect(toggle_pause)
	hud.replay_requested.connect(func() -> void: get_tree().reload_current_scene())
	hud.menu_requested.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/menu/main.tscn"))
	hud.message.text = "%s · %d eliminaciones para ganar" % [layout.display_name, config.target_eliminations]
	aim_marker = ArenaGeometry.ring(self, 0.25, ArenaStyle.GOLD)
	aim_marker.visible = false
	target_marker = Node3D.new()
	add_child(target_marker)
	ArenaGeometry.ring(target_marker, 0.78, ArenaStyle.GOLD)
	var target_label := Label3D.new()
	target_label.text = "OBJETIVO"
	target_label.position.y = 3.4
	target_label.font_size = 36
	target_label.pixel_size = 0.01
	target_label.modulate = ArenaStyle.GOLD
	target_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	target_marker.add_child(target_label)
	target_marker.hide()
	aim_guide = AimGuide.new()
	add_child(aim_guide)
	if training_mode:
		show_aim_guide = true
		hud.message.hide()
		set_training_case(0)
	get_viewport().gui_release_focus()
	if force_touch_controls or ArenaTouchControls.requested():
		var touch_layer := CanvasLayer.new()
		touch_layer.layer = 5
		add_child(touch_layer)
		touch_controls = ArenaTouchControls.new()
		touch_controls.state.auto_mode = auto_target_enabled
		touch_controls.pause_requested.connect(toggle_pause)
		touch_controls.aim_mode_requested.connect(set_auto_target)
		touch_controls.safe_area_changed.connect(func(safe: Rect2) -> void: TouchHUDLayout.apply(hud, safe))
		touch_layer.add_child(touch_controls)

func spawn_player(def: CharacterDefinition, team: int, point: Vector3) -> ArenaPlayer:
	var actor: ArenaPlayer = PLAYER_SCENE.instantiate()
	actor.definition = def
	actor.team = team
	actor.unlimited_ammo = laboratory_unlimited_ammo or not GameSession.reload_enabled
	actor.respawn_duration = config.respawn_seconds
	actor.spawn_point = point
	actor.position = point
	actor.facing = Vector3.RIGHT if team == 0 else Vector3.LEFT
	add_child(actor)
	actor.action_requested.connect(on_action)
	actor.ability_started.connect(on_ability)
	actor.eliminated.connect(on_eliminated)
	actor.attack_accepted.connect(on_attack_accepted)
	actors.append(actor)
	return actor

func _physics_process(delta: float) -> void:
	# No pasar referencias liberadas a lambdas tipadas: Godot falla al convertirlas.
	for index in range(projectiles.size() - 1, -1, -1):
		if not is_instance_valid(projectiles[index]) or projectiles[index].is_queued_for_deletion():
			projectiles.remove_at(index)
	if phase == Phase.PLAYING:
		if touch_controls != null:
			touch_controls.update_player(human)
		elapsed += delta
		if not training_mode:
			rules.tick(delta)
		if phase != Phase.PLAYING:
			return
		human.command.move = keyboard_direction()
		if touch_controls != null:
			human.command.move = (human.command.move + ArenaTouchControls.world_direction(touch_controls.state.movement, camera)).limit_length()
			human.command.ability = touch_controls.state.consume_ability() or human.command.ability
			human.command.super_shot = touch_controls.state.consume_super() or human.command.super_shot
		if auto_target_enabled:
			auto_target = TargetSelector.nearest(human, actors)
			if is_instance_valid(auto_target):
				var direction := CombatAim.direction(CombatAim.origin(human), CombatAim.origin(auto_target))
				human.command.aim = Vector2(direction.x, direction.z)
			else:
				human.command.aim = Vector2.ZERO
				human.command.shoot = false
		elif touch_controls != null and not touch_controls.state.aim.is_zero_approx():
			human.command.aim = ArenaTouchControls.world_direction(touch_controls.state.aim.normalized(), camera)
		elif mouse_aim:
			update_aim()
		var touch_fire := touch_controls != null and touch_controls.state.fire_held()
		if (mouse_fire_held or key_fire_held or touch_fire) and (not auto_target_enabled or is_instance_valid(auto_target)):
			human.command.shoot = true
		if training_mode:
			bot.command.clear_actions()
			bot.command.move = Vector2.ZERO
			bot.move_velocity = Vector3.ZERO
			bot.push_velocity = Vector3.ZERO
			bot.position = bot.spawn_point
		else:
			brain.update(bot, human, projectiles, delta)
		if not human.knocked_out and not bot.knocked_out:
			for actor: ArenaPlayer in [human, bot]:
				var rival := bot if actor == human else human
				if actor.definition.attack_type == "Melee" and actor.position.distance_to(rival.position) <= actor.definition.attack_range and brain.line_clear(actor, rival):
					close_seconds[actor.team] += delta
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
	target_marker.visible = auto_target_enabled and is_instance_valid(auto_target) and not auto_target.knocked_out and phase == Phase.PLAYING
	if target_marker.visible:
		target_marker.global_position = auto_target.global_position
	aim_marker.visible = not auto_target_enabled and mouse_aim
	hud.assist_status.text = "PUNTERÍA MANUAL · Mantén clic o Espacio para atacar · T: automático"
	if auto_target_enabled:
		hud.assist_status.text = "AUTO · Sin rival libre dentro del alcance · T: manual"
		if is_instance_valid(auto_target) and not auto_target.knocked_out:
			var protection := " · PROTEGIDO %.1f s" % auto_target.invulnerable if auto_target.invulnerable > 0 else ""
			hud.assist_status.text = "AUTO → %s #%d%s · Mantén clic/Espacio para atacar · T: manual" % [auto_target.definition.display_name, auto_target.definition.number, protection]
	aim_guide.visible = (show_aim_guide or (touch_controls != null and not auto_target_enabled)) and not human.knocked_out
	if aim_guide.visible:
		var direction := Vector3(human.command.aim.x, 0, human.command.aim.y) if human.command.aim.length() > 0.1 else human.facing
		aim_guide.update_guide(human, direction.normalized())
	hud.update_state(rules, human)
	if training_mode:
		hud.scoreboard.text = "CAMPO DE TIRO · REY INMÓVIL"
		hud.diagnostics.visible = true
		hud.diagnostics.text = "1 Corta · 2 Media · 3 Larga · 4 Cobertura · 5 Fuera de alcance · L: munición libre
%s | Rey: %d PV | F2: guía %s
Impactos %d · Cobertura %d · Alcance %d
%s" % [TRAINING_CASES[training_case], bot.health, "ON" if show_aim_guide else "OFF", shot_counts.get("impacto", 0), shot_counts.get("cobertura", 0), shot_counts.get("alcance", 0), shot_summary()]

func keyboard_direction() -> Vector2:
	var x := float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
	var y := float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	return Vector2(x, y).limit_length()

func update_aim() -> void:
	var hit: Variant = CombatAim.point(camera, aim_position, human)
	if hit != null:
		var at: Vector3 = hit
		aim_marker.position = at
		aim_marker.visible = true
		var aim := CombatAim.direction(CombatAim.origin(human), at)
		if not aim.is_zero_approx():
			human.command.aim = Vector2(aim.x, aim.z)

func _input(event: InputEvent) -> void:
	# Recibir liberaciones aunque el cursor esté sobre un botón del HUD.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		mouse_fire_held = false
	if event is InputEventKey and event.physical_keycode == KEY_SPACE and not event.pressed:
		key_fire_held = false

func _unhandled_input(event: InputEvent) -> void:
	# La emulación permite tocar botones GUI, pero no debe duplicar ataques/ratón.
	if touch_controls != null and event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if event is InputEventMouseMotion:
		mouse_aim = true
		aim_position = event.position
	if phase == Phase.PLAYING and not human.knocked_out and event is InputEventMouseButton and event.pressed:
		mouse_aim = true
		aim_position = event.position
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_fire_held = true
			human.command.shoot = true
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			human.command.super_shot = true
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_ESCAPE: toggle_pause()
		KEY_F3: hud.show_metrics = not hud.show_metrics
		KEY_F2: show_aim_guide = not show_aim_guide
		KEY_L:
			if training_mode and phase == Phase.PLAYING:
				laboratory_unlimited_ammo = not laboratory_unlimited_ammo
				for actor in actors:
					actor.ammo.unlimited = laboratory_unlimited_ammo or not GameSession.reload_enabled
					actor.ammo.reset()
		KEY_T:
			set_auto_target(not auto_target_enabled)
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5:
			if training_mode and phase == Phase.PLAYING:
				set_training_case(event.physical_keycode - KEY_1)
		KEY_SPACE:
			if phase == Phase.PLAYING and not human.knocked_out:
				key_fire_held = true
				human.command.shoot = true
		KEY_E, KEY_SHIFT:
			if phase == Phase.PLAYING: human.command.ability = true
		KEY_Q:
			if phase == Phase.PLAYING: human.command.super_shot = true

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED] and is_instance_valid(hud) and phase == Phase.PLAYING:
		toggle_pause()

func set_auto_target(enabled: bool) -> void:
	auto_target_enabled = enabled
	auto_target = null
	human.command.aim = Vector2.ZERO
	mouse_fire_held = false
	key_fire_held = false
	human.command.clear_actions()
	if touch_controls != null:
		touch_controls.state.set_auto_mode(enabled)

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
		projectile.position = to_local(CombatAim.origin(actor))
		projectile.hit.connect(apply_damage)
		projectile.resolved.connect(on_projectile_resolved)
		add_child(projectile)
		projectiles.append(projectile)
		spawn_effect(actor, "turbo_super" if is_super else "shot", Color("62e7ff"))
	else:
		var rival := bot if actor == human else human
		var offset := rival.position - actor.position
		var reach := actor.definition.super_radius if is_super else actor.definition.attack_range
		if not rival.knocked_out and offset.length() <= reach and (is_super or actor.facing.dot(offset.normalized()) > 0.25) and brain.line_clear(actor, rival):
			apply_damage(rival, actor, actor.definition.super_damage if is_super else actor.definition.attack_damage, offset.normalized() * actor.definition.attack_push * (2 if is_super else 1))
		spawn_effect(actor, "rey_super" if is_super else "melee", Color("ba8bff") if is_super else actor.definition.color)

func apply_damage(target: ArenaPlayer, source: ArenaPlayer, damage: int, push: Vector3) -> void:
	if phase != Phase.PLAYING or target.team == source.team:
		return
	if target.take_damage(damage, push):
		impacts += 1
		damage_events[source.team] += 1
		source.super_charge = minf(100, source.super_charge + source.definition.charge_per_hit)
		spawn_effect(target, "hit", Color("ffbb85"))
	elif target.invulnerable > 0 and not target.knocked_out:
		spawn_effect(target, "shield", Color.WHITE)

func on_ability(actor: ArenaPlayer) -> void:
	spawn_effect(actor, "turbo_sprint" if actor.definition.attack_type == "Ranged" else "rey_charge", actor.definition.ability.effect_color)

func spawn_effect(actor: ArenaPlayer, kind: String, color: Color) -> void:
	var effect := AbilityEffect.new()
	effect.kind = kind
	effect.color = color
	effect.quality = not GraphicsSettings.low
	effect.position = actor.position
	effect.rotation.y = atan2(-actor.facing.x, -actor.facing.z)
	effect.follow = actor
	effect.radius = actor.definition.super_radius
	add_child(effect)

func spawn_effect_at(at: Vector3, kind: String) -> void:
	var effect := AbilityEffect.new()
	effect.kind = kind
	effect.quality = not GraphicsSettings.low
	effect.position = at
	add_child(effect)

func on_eliminated(actor: ArenaPlayer) -> void:
	if phase != Phase.PLAYING:
		return
	spawn_effect(actor, "elimination", actor.definition.color)
	if actor == human:
		mouse_fire_held = false
		key_fire_held = false
		if touch_controls != null:
			touch_controls.state.cancel_all()
	hud.message.text = "¡Eliminación rival!" if actor == bot else "Te han eliminado · Reaparecerás pronto"
	last_message_at = elapsed
	if not training_mode:
		rules.score(1 - actor.team)

func freeze_combat(freeze: bool) -> void:
	if touch_controls != null:
		touch_controls.set_playing(not freeze)
	mouse_fire_held = false
	key_fire_held = false
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
	call_deferred("save_report")
	hud.show_overlay(rules.result(), "Eliminaciones: %d — %d\nBatalla de entrenamiento local" % rules.scores, false)

func on_projectile_resolved(projectile: CombatProjectile, reason: String, at: Vector3) -> void:
	shot_counts[reason] = shot_counts.get(reason, 0) + 1
	if reason == "cobertura":
		spawn_effect_at(to_local(at), "impact_cover")
	shot_events.append({"reason": reason, "at": at, "distance": projectile.travelled, "age": projectile.age, "team": projectile.source.team})
	if shot_events.size() > 20:
		shot_events.pop_front()
	if training_mode or show_aim_guide or (auto_target_enabled and projectile.source == human):
		var feedback := ShotFeedback.new()
		feedback.text = reason.to_upper()
		feedback.color = Color("35c78a") if reason == "impacto" else (Color("ffb357") if reason == "cobertura" else Color("bd9aff"))
		feedback.position = to_local(at)
		add_child(feedback)

func shot_summary() -> String:
	if shot_events.is_empty():
		return "Apunta al torso y dispara. El Rey no se mueve ni ataca."
	var event: Dictionary = shot_events.back()
	return "Último: %s · %.2f m · %.2f s" % [event.reason.to_upper(), event.distance, event.age]

func set_training_case(index: int) -> void:
	training_case = clampi(index, 0, TRAINING_CASES.size() - 1)
	for projectile in projectiles:
		if is_instance_valid(projectile):
			projectile.queue_free()
	projectiles.clear()
	for feedback in get_children():
		if feedback is ShotFeedback:
			feedback.queue_free()
	human.spawn_point = Vector3(-10, 0, -2)
	bot.spawn_point = Vector3([-7, -3, 2, 3, 2][training_case], 0, -2)
	if training_case == 3:
		human.spawn_point = Vector3(-3, 0, 0)
		bot.spawn_point = Vector3(3, 0, 0)
	elif training_case == 4:
		human.spawn_point = Vector3(-12, 0, -2)
	human.reset_at_spawn()
	bot.reset_at_spawn()
	bot.invulnerable = 0
	human.facing = CombatAim.direction(human.global_position, bot.global_position)
	human.command.aim = Vector2(human.facing.x, human.facing.z)
	mouse_aim = false
	hud.message.text = "Prueba %s · 1–5 cambian ejercicio · F2 alterna guía" % TRAINING_CASES[training_case]
	last_message_at = elapsed

func on_attack_accepted(actor: ArenaPlayer, kind: String) -> void:
	if kind == "shot":
		basic_attacks[actor.team] += 1
	else:
		super_attacks[actor.team] += 1

func report_data() -> Dictionary:
	var participants: Array[Dictionary] = []
	for actor: ArenaPlayer in [human, bot]:
		participants.append({"character": actor.definition.id, "team": actor.team, "controller": "human" if actor == human else "bot", "limited_ammo": actor.ammo.limited(), "capacity": actor.ammo.capacity(), "seconds_per_charge": actor.ammo.interval(), "basic_attacks": basic_attacks[actor.team], "super_attacks": super_attacks[actor.team], "damage_events": damage_events[actor.team], "empty_seconds": actor.ammo.empty_seconds, "empty_periods": actor.ammo.empty_periods, "melee_opportunity_seconds": close_seconds[actor.team]})
	return {"schema": 1, "configuration": "reload-p1-v1" if GameSession.reload_enabled else "reference-pr3", "map": layout.id, "navigation_revision": "shared-layout-p2-v1", "map_obstacles": layout.obstacles.map(func(rect: Rect2) -> Array: return [rect.position.x, rect.position.y, rect.size.x, rect.size.y]), "engine": Engine.get_version_info().string, "aim_mode": "auto" if auto_target_enabled else "manual", "scores": rules.scores.duplicate(), "elapsed_seconds": elapsed, "participants": participants}

func save_report() -> void:
	if not training_mode and report_path.is_empty():
		report_path = MatchReport.save(report_data())
