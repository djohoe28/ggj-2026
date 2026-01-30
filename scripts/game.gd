extends Node2D

@export var blue: Color = Color.BLUE
@export var red: Color = Color.RED
@export var both: Color = Color.BLACK

## TileMapLayer containing entities (Level Designer: entities must be direct children).
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

func _ready() -> void:
	Globals.update_color('blue', blue)
	Globals.update_color('red', red)
	Globals.update_color('both', both)
