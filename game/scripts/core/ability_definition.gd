class_name AbilityDefinition
extends Resource
## Ajustable desde inspector. Los efectos no deciden colisiones ni resultados.
## Dash: desplazamiento (Turbo, Rey). Power: mejora temporal del daño básico (Príncipe).
@export_enum("Dash", "Power") var kind: String = "Dash"
@export var display_name := "Sprint"
@export_range(0.5, 15.0, 0.1) var cooldown: float = 5.0
@export_range(0.1, 6.0, 0.01) var duration: float = 0.28
@export_range(1.0, 4.0, 0.1) var speed_multiplier: float = 2.4
@export_range(0.0, 2.0, 0.1) var shield_seconds: float = 0.0
@export_range(0, 2000, 50) var contact_damage: int = 0
## Power: multiplicador del daño básico, capturado al aceptar cada ataque; no se acumula.
@export_range(1.0, 2.0, 0.05) var damage_multiplier: float = 1.0
@export var effect_color: Color = Color.CYAN
