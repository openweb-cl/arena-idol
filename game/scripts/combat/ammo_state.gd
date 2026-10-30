class_name AmmoState
extends RefCounted
## Estado por actor. Recuperación continua de una carga; disparar no reinicia el ciclo.
var definition: AmmoDefinition
var unlimited := false
var charges := 0
var remaining := 0.0
var empty_seconds := 0.0
var empty_periods := 0

func _init(settings: AmmoDefinition = null, unlimited_override: bool = false) -> void:
	definition = settings
	unlimited = unlimited_override
	reset()

func limited() -> bool:
	return definition != null and definition.enabled and not unlimited

func capacity() -> int:
	return maxi(1, definition.capacity) if definition != null else 0

func interval() -> float:
	return maxf(0.1, definition.seconds_per_charge) if definition != null else 1.5

func reset() -> void:
	charges = capacity()
	remaining = 0

func consume() -> bool:
	if not limited():
		return true
	if charges <= 0:
		return false
	charges -= 1
	if charges == 0:
		empty_periods += 1
	if remaining <= 0:
		remaining = interval()
	return true

func tick(delta: float) -> void:
	if not limited() or charges >= capacity() or delta <= 0:
		return
	if charges == 0:
		empty_seconds += minf(delta, remaining)
	remaining -= delta
	while remaining <= 0.000001 and charges < capacity():
		charges += 1
		remaining += interval()
	if charges == capacity():
		remaining = 0

func progress() -> float:
	return 1.0 if not limited() or charges == capacity() else clampf(1.0 - remaining / interval(), 0, 1)
