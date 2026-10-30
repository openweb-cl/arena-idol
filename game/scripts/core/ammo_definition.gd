class_name AmmoDefinition
extends Resource
@export var enabled := true
@export_range(1, 12, 1) var capacity: int = 3
@export_range(0.1, 10, 0.1) var seconds_per_charge: float = 1.5
