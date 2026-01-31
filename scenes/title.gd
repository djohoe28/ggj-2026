@tool
extends Node2D

func _on_button_pressed() -> void:
	var game := get_tree().current_scene
	if game.has_method("_on_win_level"):
		game._on_win_level()
