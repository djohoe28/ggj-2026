extends Node

const TILE_SIZE := Vector2(64, 64)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()