extends Sprite2D

@export var color_key: String = 'both'

func _ready() -> void:
	modulate = Globals.colors[color_key]
	Globals.color_updated.connect(_on_update_color)

func _on_update_color(color):
	if color == color_key:
		modulate = Globals.colors[color_key]
