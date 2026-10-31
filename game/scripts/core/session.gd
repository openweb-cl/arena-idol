class_name GameSession
extends RefCounted
static var selected: CharacterDefinition = preload("res://data/characters/turbo.tres")
## Rival del bot elegido en el menú; null = el primero distinto del héroe propio.
static var selected_rival: CharacterDefinition = null

static var reload_enabled := true

const ARENAS: Array[ArenaDefinition] = [preload("res://data/maps/prisma_a.tres"), preload("res://data/maps/prisma_b.tres")]
static var selected_arena: ArenaDefinition = preload("res://data/maps/prisma_a.tres")

