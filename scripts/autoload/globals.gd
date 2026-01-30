extends Node

const TILE_SIZE := Vector2(64, 64)

var BLUE_COLOR := Color.BLUE
var RED_COLOR := Color.RED

signal update_red_color(Color)
signal update_blue_color(Color)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func update_red(color: Color):
	RED_COLOR = color
	update_red_color.emit(color)

func update_blue(color: Color):
	BLUE_COLOR = color
	update_blue_color.emit(color)
	print(BLUE_COLOR)
