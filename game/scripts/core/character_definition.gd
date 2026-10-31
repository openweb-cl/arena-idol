class_name CharacterDefinition
extends Resource
## Catálogo público. Editar .tres en el inspector; no requiere cambiar scripts.
@export var id: String = ""
@export var display_name: String = ""
@export_range(1, 99) var number: int = 1
@export var role: String = ""
@export_multiline var description: String = ""
@export var color: Color = Color.CYAN
@export_group("Movimiento / metros y segundos")
@export_range(1, 15, 0.1) var speed: float = 7.0
@export_range(5, 100, 1) var acceleration: float = 38.0
@export_range(5, 100, 1) var braking: float = 48.0
@export_range(3, 30, 0.5) var turn_speed: float = 14.0
@export_group("Combate")
@export_range(100, 15000, 100) var max_health: int = 4000
@export_range(50, 3000, 50) var attack_damage: int = 900
@export_enum("Ranged", "Melee") var attack_type: String = "Ranged"
@export_range(0.2, 2, 0.05) var attack_interval: float = 0.5
@export_range(1, 25, 0.1) var attack_range: float = 12.0
@export_range(4, 50, 0.5) var projectile_speed: float = 18.0
@export_range(0, 15, 0.5) var attack_push: float = 3.0
@export_range(500, 5000, 100) var super_damage: int = 2000
@export_range(1, 8, 0.1) var super_radius: float = 4.0
@export_range(5, 50, 1) var charge_per_hit: float = 25.0
@export var ability: AbilityDefinition
@export var ammo: AmmoDefinition
@export_group("Arte / integración Claude Code")
@export var model_scene: PackedScene
@export var model_scale: Vector3 = Vector3.ONE
@export var model_rotation_degrees: Vector3 = Vector3.ZERO
## m/s que avanzan los pies en el clip `run` a escala 1; ajusta su velocidad para no patinar.
@export_range(1, 10, 0.1) var run_clip_speed: float = 3.3
