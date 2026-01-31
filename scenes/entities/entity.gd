@tool
extends StaticBody2D
class_name Entity

## How this Entity interacts with each Player.
## GHOST: does not block movement. MOVABLE: can be pushed. IMMOVABLE: blocks movement.
## CONTROLLED: responds to the respective player's Input actions (p1_*, p2_*).
enum Relationship {
	GHOST = 0,
	MOVABLE = 1,
	IMMOVABLE = 2,
	CONTROLLED = 3
}

## Maps input actions (p1_up, p1_down, etc.) to [player_id, direction].
const ACTION_TO_PLAYER_AND_DIRECTION := {
	"p1_up": [1, Vector2.UP],
	"p1_down": [1, Vector2.DOWN],
	"p1_left": [1, Vector2.LEFT],
	"p1_right": [1, Vector2.RIGHT],
	"p2_up": [2, Vector2.UP],
	"p2_down": [2, Vector2.DOWN],
	"p2_left": [2, Vector2.LEFT],
	"p2_right": [2, Vector2.RIGHT]
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
	return TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE # fallback

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
	return Vector2.RIGHT # fallback

signal moved(entity: Entity, direction: TileSet.CellNeighbor)
signal blocked(entity: Entity, direction: TileSet.CellNeighbor)
## Emitted when a CONTROLLED entity successfully pushes another Entity.
signal pushed(controller: Entity, collider: Entity, direction: Vector2)

@export var visible_to_player1: bool = true:
	set(value):
		visible_to_player1 = value
		apply_visibility_for_players()
@export var visible_to_player2: bool = true:
	set(value):
		visible_to_player2 = value
		apply_visibility_for_players()
@export var relationship_with_player1: Relationship = Relationship.GHOST:
	set(value):
		relationship_with_player1 = value
		apply_relationship_with_players()
@export var relationship_with_player2: Relationship = Relationship.GHOST:
	set(value):
		relationship_with_player2 = value
		apply_relationship_with_players()

@export var tween_properties: TweenProperties

var current_tween: Tween = null

## Queue for CONTROLLED entities (direction, pusher_player_id).
var _queued_direction: Vector2 = Vector2.ZERO
var _queued_pusher_id: int = 0
var is_moving: bool = false

func apply_name() -> void:
	var description: String = ""
	if visible_to_player1 and visible_to_player2:
		description += "Both"
	elif visible_to_player1:
		description += "Blue"
	elif visible_to_player2:
		description += "Red"
	else:
		description += "None"
	if relationship_with_player1 == Relationship.GHOST:
		description += " Ghost"
	elif relationship_with_player1 == Relationship.MOVABLE:
		description += " Movable"
	elif relationship_with_player1 == Relationship.IMMOVABLE:
		description += " Immovable"
	elif relationship_with_player1 == Relationship.CONTROLLED:
		description += " Controlled"
	if relationship_with_player2 == Relationship.GHOST:
		description += " Ghost"
	elif relationship_with_player2 == Relationship.MOVABLE:
		description += " Movable"
	elif relationship_with_player2 == Relationship.IMMOVABLE:
		description += " Immovable"
	elif relationship_with_player2 == Relationship.CONTROLLED:
		description += " Controlled"
	name = description
	$Label.text = description.replace(" ", "\n")

func apply_relationship_with_players() -> void:
	# Initialize all layers and masks to true
	for i in range(1, 4):
		set_collision_layer_value(i, true)
		set_collision_mask_value(i, true)
	# Remove Player masks
	if relationship_with_player1 == Relationship.CONTROLLED:
		set_collision_mask_value(1, false)
	if relationship_with_player2 == Relationship.CONTROLLED:
		set_collision_mask_value(2, false)
	# Remove Ghost layers
	if relationship_with_player1 == Relationship.GHOST:
		set_collision_layer_value(2, false)
	if relationship_with_player2 == Relationship.GHOST:
		set_collision_layer_value(1, false)
	$RayCast2D.collision_mask = collision_mask
	apply_name()

func apply_visibility_for_players() -> void:
	if visible_to_player1 and visible_to_player2:
		$Sprite2D.color_key = Globals.ColorFlag.BOTH
		# $Sprite2D.modulate = Globals.color_settings[Globals.ColorFlag.BOTH]
	elif visible_to_player1:
		$Sprite2D.color_key = Globals.ColorFlag.BLUE
		# $Sprite2D.modulate = Globals.color_settings[Globals.ColorFlag.BLUE]
	elif visible_to_player2:
		$Sprite2D.color_key = Globals.ColorFlag.RED
		# $Sprite2D.modulate = Globals.color_settings[Globals.ColorFlag.RED]
	else:
		$Sprite2D.color_key = Globals.ColorFlag.NONE
		# $Sprite2D.modulate = Globals.color_settings[Globals.ColorFlag.NONE]
	apply_name()

func _on_renamed() -> void:
	pass
	# var _color: String = "Default"
	# var _type: String = name
	# if name.count(" ") > 0:
	# 	_color = name.split(" ")[0]
	# 	match _color:
	# 		"Blue":
	# 			$Sprite2D.color_key = Globals.ColorFlag.BLUE
	# 		"Red":
	# 			$Sprite2D.color_key = Globals.ColorFlag.RED
	# 		"Both":
	# 			$Sprite2D.color_key = Globals.ColorFlag.BOTH
	# 		"None":
	# 			$Sprite2D.color_key = Globals.ColorFlag.NONE
	# 	_type = name.split(" ")[1]
	# match _type:
	# 	"Box":
	# 		relationship_with_player1 = Relationship.MOVABLE
	# 		relationship_with_player2 = Relationship.MOVABLE
	# 	"Wall":
	# 		relationship_with_player1 = Relationship.IMMOVABLE
	# 		relationship_with_player2 = Relationship.IMMOVABLE
	# 	"Player":
	# 		relationship_with_player1 = Relationship.CONTROLLED
	# 		relationship_with_player2 = Relationship.CONTROLLED
	# 	_:
	# 		relationship_with_player1 = Relationship.GHOST
	# 		relationship_with_player2 = Relationship.GHOST
	# $Label.text = _color + "\n" + _type
	pass

func _ready() -> void:
	# Defer so TileMapLayer has finished positioning scene tiles (batched at end of frame)
	apply_relationship_with_players()
	apply_visibility_for_players()
	await get_tree().process_frame
	call_deferred("_register_at_map_coords")
	renamed.connect(_on_renamed)

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
## Uses $RayCast2D with collision_mask aligned to pusher (GHOST/CONTROLLED-by-same-player excluded).
## pusher_player_id: 1 = Blue (P1), 2 = Red (P2) — determines which relationship to use for neighbors.
func can_move(direction: TileSet.CellNeighbor, pusher_player_id: int = 1) -> bool:
	if current_tween != null and current_tween.is_valid():
		return false

	var layer := _get_tile_map_layer()
	if layer == null:
		return false

	var ray := $RayCast2D
	if ray == null:
		return false

	# Configure RayCast: aim in direction, length = one tile
	var tile_size := Vector2(64, 64)
	if layer.tile_set != null:
		tile_size = Vector2(layer.tile_set.tile_size)
	var dir_vec := cell_neighbor_to_vector(direction) * tile_size
	ray.target_position = dir_vec

	# Mask matches apply_relationship_with_players: exclude same-player (CONTROLLED pass-through)
	# Layer 1 = P1, Layer 2 = P2. CONTROLLED entities set mask 1/2 false for their controller.
	var ray_mask := 7  # layers 1, 2, 3
	if pusher_player_id == 1:
		ray_mask = 6  # exclude layer 1 — don't detect P1-controlled (same-player pass-through)
	elif pusher_player_id == 2:
		ray_mask = 5  # exclude layer 2 — don't detect P2-controlled
	ray.collision_mask = ray_mask
	ray.force_raycast_update()

	if not ray.is_colliding():
		return true

	var collider = ray.get_collider()
	var neighbor := collider as Entity
	if neighbor == null:
		return false  # Hit non-Entity (e.g. tilemap collision)

	# Only MOVABLE can be pushed; IMMOVABLE blocks. GHOST/same-player CONTROLLED excluded by mask.
	if neighbor._get_relationship_for_pusher(pusher_player_id) == Relationship.MOVABLE:
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
		var success := await neighbor.move(direction)
		if not success:
			blocked.emit(self, direction)
			return false

	# Now move self
	Globals.unregister_entity(my_coords)
	Globals.register_entity(new_coords, self)

	var target_position := layer.map_to_local(new_coords)

	if current_tween != null and current_tween.is_valid():
		current_tween.kill()
	current_tween = create_tween().set_ease(tween_properties.ease_type).set_trans(tween_properties.transition_type)
	current_tween.tween_property(self, "position", target_position, tween_properties.duration)
	await current_tween.finished
	current_tween = null

	moved.emit(self, direction)
	return true

## Attempts to move (for CONTROLLED entities). Sets pusher context, emits pushed if applicable.
func try_move(direction: Vector2, pusher_player_id: int) -> bool:
	Globals.pusher_player_id = pusher_player_id
	var cell_dir := vector_to_cell_neighbor(direction)

	var layer := _get_tile_map_layer()
	if layer != null:
		var my_coords := get_map_coords()
		var new_coords := layer.get_neighbor_cell(my_coords, cell_dir)
		var neighbor := Globals.get_entity_at(new_coords) as Entity
		if neighbor != null and neighbor != self and neighbor._get_relationship_for_pusher(pusher_player_id) == Relationship.MOVABLE:
			pushed.emit(self, neighbor, direction)

	return await move(cell_dir)

func _unhandled_input(_event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not _is_controlled():
		return
	if is_moving:
		return

	for action in ACTION_TO_PLAYER_AND_DIRECTION:
		if Input.is_action_just_pressed(action):
			var data: Array = ACTION_TO_PLAYER_AND_DIRECTION[action]
			var player_id: int = data[0]
			var direction: Vector2 = data[1]
			if _get_relationship_for_pusher(player_id) == Relationship.CONTROLLED:
				_queued_direction = direction
				_queued_pusher_id = player_id
			return

func _physics_process(_delta: float) -> void:
	if not _is_controlled():
		return
	if _queued_direction == Vector2.ZERO or is_moving:
		return

	is_moving = true
	var dir := _queued_direction
	var pid := _queued_pusher_id
	_queued_direction = Vector2.ZERO
	_queued_pusher_id = 0
	call_deferred("_do_controlled_move", dir, pid)

func _do_controlled_move(direction: Vector2, pusher_player_id: int) -> void:
	await try_move(direction, pusher_player_id)
	is_moving = false

func _is_controlled() -> bool:
	return relationship_with_player1 == Relationship.CONTROLLED or relationship_with_player2 == Relationship.CONTROLLED
