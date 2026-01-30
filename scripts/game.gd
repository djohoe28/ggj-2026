extends Node2D

@export var blue := Color.BLUE
@export var red := Color.RED


func _ready():
	print(blue, red)
	Globals.update_blue(blue)
	Globals.update_red(red)
