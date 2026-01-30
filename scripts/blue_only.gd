extends Sprite2D

func _ready() -> void:
	modulate = Globals.BLUE_COLOR
	Globals.update_blue_color.connect(_on_update_color)

func _on_update_color(color):
	modulate = color
