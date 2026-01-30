extends Node2D

func _on_button_pressed() -> void:
	get_parent().get_parent()._on_win_level()
