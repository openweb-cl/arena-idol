class_name CharacterCatalog
extends RefCounted
const CAPACITY := 16
const AVAILABLE: Array[CharacterDefinition] = [
	preload("res://data/characters/turbo.tres"),
	preload("res://data/characters/rey.tres"),
	preload("res://data/characters/principe.tres"),
	preload("res://data/characters/pitbull.tres"),
]

## Rival del bot: el preferido si es distinto del propio; si no, el primero distinto.
static func rival_for(own: CharacterDefinition, preferred: CharacterDefinition = null) -> CharacterDefinition:
	if preferred != null and preferred.id != own.id:
		return preferred
	for def in AVAILABLE:
		if def.id != own.id:
			return def
	return own
