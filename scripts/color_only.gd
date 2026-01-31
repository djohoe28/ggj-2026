@tool
extends Sprite2D

@export var color_key: Globals.ColorFlag = Globals.ColorFlag.BOTH

func _ready() -> void:
	modulate = Globals.colors[color_key]
	Globals.color_updated.connect(_on_update_color)

func _on_update_color(color: Globals.ColorFlag) -> void:
	if color == color_key:
		modulate = Globals.colors[color_key]
