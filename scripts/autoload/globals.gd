@tool
extends Node

enum ColorFlag {
	NONE = 0,
	RED = 1 << 0,
	BLUE = 1 << 1,
	BOTH = RED | BLUE
}

const TILE_SIZE := Vector2(60, 60)

## Player ID used when checking entity relationships (1 = Blue/P1, 2 = Red/P2).
## Set by the Player before attempting a push so Entity.can_move knows which relationship to use.
var pusher_player_id: int = 1

## Runtime registry: map coords -> Entity. Populated when entities enter the tree.
## Level Designer: entities auto-register; use this only for debugging.
var entity_at_coords: Dictionary = {}  # Vector2i -> Entity

var colors := {
	ColorFlag.NONE: Color.WHITE,
	ColorFlag.RED: Color8(55, 252, 255),
	ColorFlag.BLUE: Color8(255, 196, 250),
	ColorFlag.BOTH: Color.BLACK
}

signal color_updated(color_flag: ColorFlag)

func register_entity(coords: Vector2i, entity: Node) -> void:
	entity_at_coords[coords] = entity

func unregister_entity(coords: Vector2i) -> void:
	entity_at_coords.erase(coords)

func get_entity_at(coords: Vector2i) -> Node:
	return entity_at_coords.get(coords, null)

## Returns the number of CONTROLLED entities still registered in the level.
func count_controlled_entities() -> int:
	var count := 0
	for entity in entity_at_coords.values():
		if entity.has_method("_is_controlled") and entity._is_controlled():
			count += 1
	return count

func update_color(color_flag: ColorFlag, color: Color) -> void:
	colors[color_flag] = color
	color_updated.emit(color_flag)
