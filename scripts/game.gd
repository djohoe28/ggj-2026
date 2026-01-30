extends Node2D

@export var none: Color = Color.WHITE
@export var blue: Color = Color.BLUE
@export var red: Color = Color.RED
@export var both: Color = Color.BLACK

@export var levels: Array[PackedScene]
@export var current_level: int = 0
@onready var level_container: Node2D = $"./LevelContainer"

func _ready() -> void:
	Globals.update_color(Globals.ColorFlag.NONE, none)
	Globals.update_color(Globals.ColorFlag.BLUE, blue)
	Globals.update_color(Globals.ColorFlag.RED, red)
	Globals.update_color(Globals.ColorFlag.BOTH, both)
	load_level()

func _on_win_level() -> void:
	current_level += 1
	load_level()

func load_level() -> void:
	var level = levels[current_level].instantiate()
	for child in level_container.get_children():
		child.queue_free()
	level_container.add_child(level)
