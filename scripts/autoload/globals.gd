@tool
extends Node

const TILE_SIZE := Vector2(64, 64)

## Player ID used when checking entity relationships (1 = Blue/P1, 2 = Red/P2).
## Set by the Player before attempting a push so Entity.can_move knows which relationship to use.
var pusher_player_id: int = 1

## Runtime registry: map coords -> Entity. Populated when entities enter the tree.
## Level Designer: entities auto-register; use this only for debugging.
var entity_at_coords: Dictionary = {}  # Vector2i -> Entity

var colors := {
	'red': Color.RED,
	'blue': Color.BLUE,
	'both': Color.BLACK
}

signal color_updated(str)

func register_entity(coords: Vector2i, entity: Node) -> void:
	entity_at_coords[coords] = entity

func unregister_entity(coords: Vector2i) -> void:
	entity_at_coords.erase(coords)

func get_entity_at(coords: Vector2i) -> Node:
	return entity_at_coords.get(coords, null)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func update_color(key: String, color: Color):
	colors[key] = color
	color_updated.emit(key)
