class_name PlayerCommand
extends RefCounted
## Plano XZ; usado por teclado, táctil y bot. Adaptador de red futuro.
var move := Vector2.ZERO
var shoot := false
var aim := Vector2.ZERO
var ability := false
var super_shot := false

func clear_actions() -> void:
	shoot = false
	ability = false
	super_shot = false
