extends StaticBody2D
class_name Entity

## How this Entity interacts with each Player.
## GHOST: does not block movement. MOVABLE: can be pushed. IMMOVABLE: blocks movement.
enum Relationship {
	GHOST,
	MOVABLE,
	IMMOVABLE
}

## Cardinal directions for square tile layouts (Level Designer: use these for movement).
const CARDINAL_NEIGHBORS := [
	TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE
]

## Converts Vector2 (e.g. Vector2.RIGHT) to CellNeighbor for square tile layouts.
static func vector_to_cell_neighbor(v: Vector2) -> TileSet.CellNeighbor:
	if v == Vector2.RIGHT:
		return TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE
	if v == Vector2.LEFT:
		return TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE
	if v == Vector2.UP:
		return TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE
	if v == Vector2.DOWN:
		return TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE
	return TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE  # fallback

## Converts CellNeighbor to Vector2 for square tile layouts.
static func cell_neighbor_to_vector(n: TileSet.CellNeighbor) -> Vector2:
	match n:
		TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE:
			return Vector2.RIGHT
		TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE:
			return Vector2.LEFT
		TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE:
			return Vector2.UP
		TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE:
			return Vector2.DOWN
	return Vector2.RIGHT  # fallback

signal moved(entity: Entity, direction: TileSet.CellNeighbor)
signal blocked(entity: Entity, direction: TileSet.CellNeighbor)

@export var visible_to_player1: bool = true
@export var visible_to_player2: bool = true
@export var relationship_with_player1: Relationship = Relationship.GHOST
@export var relationship_with_player2: Relationship = Relationship.GHOST

@export var tween_duration: float = 0.15
@export var tween_ease: Tween.EaseType = Tween.EASE_OUT
@export var tween_trans: Tween.TransitionType = Tween.TRANS_QUINT

var current_tween: Tween = null

func _ready() -> void:
	# Defer so TileMapLayer has finished positioning scene tiles (batched at end of frame)
	call_deferred("_register_at_map_coords")

func _exit_tree() -> void:
	_unregister_at_map_coords()

## Returns the TileMapLayer this Entity lives in (parent).
## Level Designer: entities must be direct children of a TileMapLayer.
func _get_tile_map_layer() -> TileMapLayer:
	return get_parent() as TileMapLayer

## Returns this Entity's current map coordinates.
func get_map_coords() -> Vector2i:
	var layer := _get_tile_map_layer()
	if layer == null:
		return Vector2i(-999, -999)
	return layer.local_to_map(position)

func _register_at_map_coords() -> void:
	var layer := _get_tile_map_layer()
	if layer != null:
		Globals.register_entity(get_map_coords(), self)

func _unregister_at_map_coords() -> void:
	var layer := _get_tile_map_layer()
	if layer != null:
		Globals.unregister_entity(get_map_coords())

## Returns the neighbor's Relationship for the given pusher (1 = Blue/P1, 2 = Red/P2).
func _get_relationship_for_pusher(pusher_player_id: int) -> Relationship:
	return relationship_with_player1 if pusher_player_id == 1 else relationship_with_player2

## Iteratively checks whether self can move in the given direction.
## pusher_player_id: 1 = Blue (P1), 2 = Red (P2) — determines which relationship to use for neighbors.
func can_move(direction: TileSet.CellNeighbor, pusher_player_id: int = 1) -> bool:
	if current_tween != null and current_tween.is_valid():
		return false

	var layer := _get_tile_map_layer()
	if layer == null:
		return false

	var my_coords := get_map_coords()
	var neighbor_coords := layer.get_neighbor_cell(my_coords, direction)

	# Check if neighbor cell has an entity
	var neighbor := Globals.get_entity_at(neighbor_coords) as Entity
	if neighbor == null:
		return true  # Empty cell — can move

	var rel := neighbor._get_relationship_for_pusher(pusher_player_id)
	match rel:
		Relationship.GHOST:
			return true
		Relationship.IMMOVABLE:
			return false
		Relationship.MOVABLE:
			return neighbor.can_move(direction, pusher_player_id)
	return false

## Moves self within the TileMapLayer and tweens the sprite to the new position.
## Pushes MOVABLE neighbors first (recursive chain), then moves self.
## Returns true if move succeeded, false if blocked.
func move(direction: TileSet.CellNeighbor) -> bool:
	if not can_move(direction, Globals.pusher_player_id):
		blocked.emit(self, direction)
		return false

	var layer := _get_tile_map_layer()
	if layer == null:
		return false

	var my_coords := get_map_coords()
	var new_coords := layer.get_neighbor_cell(my_coords, direction)
	var neighbor := Globals.get_entity_at(new_coords) as Entity

	# Push MOVABLE neighbor first (recursive chain: farthest entity moves first)
	if neighbor != null and neighbor._get_relationship_for_pusher(Globals.pusher_player_id) == Relationship.MOVABLE:
		var pushed := await neighbor.move(direction)
		if not pushed:
			blocked.emit(self, direction)
			return false

	# Now move self
	Globals.unregister_entity(my_coords)
	Globals.register_entity(new_coords, self)

	var target_position := layer.map_to_local(new_coords)

	if current_tween != null and current_tween.is_valid():
		current_tween.kill()
	current_tween = create_tween()
	current_tween.set_ease(tween_ease).set_trans(tween_trans)
	current_tween.tween_property(self, "position", target_position, tween_duration)
	await current_tween.finished
	current_tween = null

	moved.emit(self, direction)
	return true
