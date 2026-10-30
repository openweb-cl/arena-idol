class_name TouchInputState
extends RefCounted
## Solo intención del jugador. No conoce vida, daño, munición o cooldowns.
const DEAD_ZONE := 0.16
var auto_mode := true
var fingers: Dictionary = {}
var move_finger := -1
var attack_finger := -1
var movement := Vector2.ZERO
var aim := Vector2.ZERO
var ability_pending := false
var super_pending := false

func press(index: int, action: String) -> bool:
	if fingers.has(index) or fingers.values().has(action):
		return false
	fingers[index] = action
	match action:
		"move": move_finger = index
		"attack":
			attack_finger = index
			if not auto_mode:
				aim = Vector2.ZERO
		"ability": ability_pending = true
		"super": super_pending = true
	return true

func drag(index: int, offset: Vector2, radius: float) -> bool:
	if not fingers.has(index):
		return false
	var axis := offset / maxf(radius, 1.0)
	var strength := clampf((axis.length() - DEAD_ZONE) / (1.0 - DEAD_ZONE), 0.0, 1.0)
	var value := axis.normalized() * strength
	if index == move_finger:
		movement = value
	elif index == attack_finger and not auto_mode:
		aim = value
	return true

func release(index: int) -> bool:
	if not fingers.has(index):
		return false
	fingers.erase(index)
	if index == move_finger:
		move_finger = -1
		movement = Vector2.ZERO
	if index == attack_finger:
		attack_finger = -1
	return true

func fire_held() -> bool:
	return attack_finger >= 0 and (auto_mode or aim.length() > 0.01)

func consume_ability() -> bool:
	var value := ability_pending
	ability_pending = false
	return value

func consume_super() -> bool:
	var value := super_pending
	super_pending = false
	return value

func set_auto_mode(value: bool) -> void:
	if auto_mode == value:
		return
	auto_mode = value
	if attack_finger >= 0:
		release(attack_finger)
	aim = Vector2.ZERO
	ability_pending = false
	super_pending = false

func cancel_all() -> void:
	fingers.clear()
	move_finger = -1
	attack_finger = -1
	movement = Vector2.ZERO
	aim = Vector2.ZERO
	ability_pending = false
	super_pending = false
