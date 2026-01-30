extends Sprite2D

@export var color_key: Globals.ColorFlag = Globals.ColorFlag.BOTH

func _ready() -> void:
	modulate = Globals.color_settings[color_key]
	Globals.color_updated.connect(_on_update_color)

func _on_update_color(color: Globals.ColorFlag):
	if color == color_key:
		modulate = Globals.color_settings[color_key]
		print(color_key, " modulate: ", modulate)
