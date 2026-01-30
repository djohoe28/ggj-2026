extends Node2D

@export var blue: Color = Globals.colors['blue']
@export var red: Color = Globals.colors['red']
@export var both = Globals.colors['both']

func _ready():
	Globals.update_color('blue', blue)
	Globals.update_color('red', red)
	Globals.update_color('both', both)
