extends Node

const TILE_SIZE := Vector2(64, 64)

var colors := {
	'red': Color.RED,
	'blue': Color.BLUE,
	'both': Color.BLACK
}

signal color_updated(str)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func update_color(key: String, color: Color):
	colors[key] = color
	color_updated.emit(key)
