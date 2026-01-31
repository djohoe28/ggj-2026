extends Node2D

@export var none: Color = Globals.colors[Globals.ColorFlag.NONE]
@export var blue: Color = Globals.colors[Globals.ColorFlag.BLUE]
@export var red: Color = Globals.colors[Globals.ColorFlag.RED]
@export var both: Color = Globals.colors[Globals.ColorFlag.BOTH]

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
