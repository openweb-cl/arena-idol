class_name ShotFeedback
extends Node3D
var text := ""
var color := Color.WHITE
var age := 0.0
var lifetime := 2.0

func _ready() -> void:
	ArenaGeometry.ring(self, 0.25, color)
	var label := Label3D.new()
	label.text = text
	label.font_size = 36
	label.pixel_size = 0.01
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position.y = 0.4
	label.modulate = color
	add_child(label)

func _process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
