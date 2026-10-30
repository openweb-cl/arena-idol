class_name MatchRules
extends RefCounted
signal elimination_scored(team: int)
signal finished
var config: MatchConfig
var scores: Array[int] = [0, 0]
var remaining: float
var ended := false

func _init(settings: MatchConfig = null) -> void:
	config = settings if settings != null else MatchConfig.new()
	remaining = config.duration_seconds

func score(team: int) -> void:
	if ended or team < 0 or team > 1:
		return
	scores[team] += 1
	elimination_scored.emit(team)
	if scores[team] >= config.target_eliminations:
		end()

func tick(delta: float) -> void:
	if ended:
		return
	remaining = maxf(0, remaining - maxf(0, delta))
	if remaining <= 0:
		end()

func end() -> void:
	if ended:
		return
	ended = true
	finished.emit()

func result() -> String:
	if scores[0] == scores[1]:
		return "EMPATE"
	return "¡VICTORIA!" if scores[0] > scores[1] else "GANA EL RIVAL"
