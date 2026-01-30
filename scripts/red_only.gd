extends Sprite2D

func _ready() -> void:
	modulate = Globals.RED_COLOR
	Globals.update_red_color.connect(_on_update_color)

func _on_update_color(color):
	modulate = color
