extends Node2D

@onready var level: TileMapLayer = $"../TileMapLayer"

func _on_button_pressed() -> void:
	level.visible = true
	queue_free()
