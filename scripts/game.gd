extends Node2D

@export var blue: Color = Color.BLUE
@export var red: Color = Color.RED
@export var both: Color = Color.BLACK

func _ready():
	Globals.update_color('blue', blue)
	Globals.update_color('red', red)
	Globals.update_color('both', both)
