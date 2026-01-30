extends Node2D

func _on_button_pressed() -> void:
	# @ Game / LevelContainer / Calibration -> Game._on_win_level()
	get_parent().get_parent()._on_win_level()
