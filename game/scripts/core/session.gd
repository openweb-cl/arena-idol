class_name GameSession
extends RefCounted
static var selected: CharacterDefinition = preload("res://data/characters/turbo.tres")

static var reload_enabled := true

const ARENAS: Array[ArenaDefinition] = [preload("res://data/maps/prisma_a.tres"), preload("res://data/maps/prisma_b.tres")]
static var selected_arena: ArenaDefinition = preload("res://data/maps/prisma_a.tres")
