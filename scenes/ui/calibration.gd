@tool
extends Node2D

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	$Control.visible = visible

func _on_button_pressed() -> void:
	get_parent().get_parent()._on_win_level()
