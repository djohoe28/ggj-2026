extends Control

@export var color_key : Globals.ColorFlag = Globals.ColorFlag.BLUE

@onready var slider_hue: HSlider = $HSlider1
@onready var slider_sat: HSlider = $HSlider2
@onready var slider_val: HSlider = $HSlider3

func _ready() -> void:
	slider_hue.value = Globals.color_settings[color_key].h * 360
	slider_sat.value = Globals.color_settings[color_key].s * 100
	slider_val.value = Globals.color_settings[color_key].v * 100
	slider_hue.connect("value_changed", _on_hue_changed)
	slider_sat.connect("value_changed", _on_sat_changed)
	slider_val.connect("value_changed", _on_val_changed)

func _on_hue_changed(value):
	var new_color: Color = Globals.color_settings[color_key]
	new_color.h = value / 360.0
	Globals.update_color(color_key, new_color)
	print(color_key)


func _on_sat_changed(value):
	var new_color: Color = Globals.color_settings[color_key]
	new_color.s = value / 100.0
	Globals.update_color(color_key, new_color)

func _on_val_changed(value):
	var new_color: Color = Globals.color_settings[color_key]
	new_color.v = value / 100.0
	Globals.update_color(color_key, new_color)
