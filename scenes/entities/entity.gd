@tool
extends StaticBody2D
class_name Entity

## Fixed entity types. Each maps to per-player relationship (Movable/Immovable/Controlled/Goal).
## When true, multiple Players can escape from the same Goal. When false, the Goal is consumed by the first Player.
const GOAL_REUSABLE: bool = true

enum EntityKind {
	WALL,    ## Immovable P1, Immovable P2
	BOX,     ## Movable P1, Movable P2
	P1_BOX,  ## Movable P1, Immovable P2
	P2_BOX,  ## Immovable P1, Movable P2
	P1_BODY, ## Controlled P1, Immovable P2
	P2_BODY, ## Immovable P1, Controlled P2
	GOAL     ## Goal P1, Goal P2
}

## Internal: effective relationship for movement logic (derived from EntityKind per pusher).
enum _Relationship {
	MOVABLE = 1,
	IMMOVABLE = 2,
	CONTROLLED = 3,
	GOAL = 4
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

## Returns display string for EntityKind.
static func entity_kind_to_string(kind: EntityKind) -> String:
	match kind:
		EntityKind.WALL:
			return "Wall"
		EntityKind.BOX:
			return "Box"
		EntityKind.P1_BOX:
			return "P1 Box"
		EntityKind.P2_BOX:
			return "P2 Box"
		EntityKind.P1_BODY:
			return "P1 Body"
		EntityKind.P2_BODY:
			return "P2 Body"
		EntityKind.GOAL:
			return "Goal"
	return "Wall"

signal moved(entity: Entity, direction: TileSet.CellNeighbor)
signal blocked(entity: Entity, direction: TileSet.CellNeighbor)
## Emitted when a CONTROLLED entity successfully pushes another Entity.
signal pushed(controller: Entity, collider: Entity, direction: Vector2)

@export var entity_kind: EntityKind = EntityKind.WALL:
	set(value):
		entity_kind = value
		apply_from_kind()

@export var tween_properties: TweenProperties

@onready var move_sfx: AudioStreamPlayer2D = $MoveSFX
@onready var push_sfx: AudioStreamPlayer2D = $PushSFX
@onready var block_sfx: AudioStreamPlayer2D = $BlockSFX
@onready var exit_sfx: AudioStreamPlayer2D = $ExitSFX

var current_tween: Tween = null

## Queue for CONTROLLED entities (direction, pusher_player_id).
var _queued_direction: Vector2 = Vector2.ZERO
var _queued_pusher_id: int = 0
var is_moving: bool = false

## When true, entity has escaped into a Goal: no input, no collision, awaiting free.
var escaped: bool = false

func apply_from_kind() -> void:
	var description := entity_kind_to_string(entity_kind)
	name = description
	# $Label.text = description.replace(" ", "\n")
	# Collision layers: 1=P1, 2=P2, 3=Solid. All entities on layer 3.
	for i in range(1, 4):
		set_collision_layer_value(i, true)
		set_collision_mask_value(i, true)
	# P1_BODY excludes layer 1 from mask (same-player pass-through)
	if entity_kind == EntityKind.P1_BODY:
		set_collision_mask_value(1, false)
	# P2_BODY excludes layer 2 from mask (same-player pass-through)
	if entity_kind == EntityKind.P2_BODY:
		set_collision_mask_value(2, false)
	$RayCast2D.collision_mask = collision_mask
	# # Color: P1_BODY=Blue, P2_BODY=Red, others=Both
	# match entity_kind:
	# 	EntityKind.P1_BODY:
	# 		$Sprite2D.color_key = Globals.ColorFlag.BLUE
	# 	EntityKind.P2_BODY:
	# 		$Sprite2D.color_key = Globals.ColorFlag.RED
	# 	_:
	# 		$Sprite2D.color_key = Globals.ColorFlag.BOTH

func _on_renamed() -> void:
	pass

func _ready() -> void:
	# Defer so TileMapLayer has finished positioning scene tiles (batched at end of frame)
	apply_from_kind()
	await get_tree().process_frame
	call_deferred("_register_at_map_coords")
	renamed.connect(_on_renamed)

func _exit_tree() -> void:
	if escaped:
		return  # Never registered at current position; unregister would erase the Goal
	# Only unregister if we're the entity at this coord (MOVABLE on Goal never registered)
	if Globals.get_entity_at(get_map_coords()) != self:
		return
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

## Returns this entity's effective relationship for the given pusher (1 = Blue/P1, 2 = Red/P2).
## When pusher_is_box is true, P1_BOX and P2_BOX are always MOVABLE (boxes can push each other).
func _get_relationship_for_pusher(pusher_player_id: int, pusher_is_box: bool = false) -> _Relationship:
	match entity_kind:
		EntityKind.WALL:
			return _Relationship.IMMOVABLE
		EntityKind.BOX:
			return _Relationship.MOVABLE
		EntityKind.P1_BOX:
			if pusher_is_box:
				return _Relationship.MOVABLE
			return _Relationship.MOVABLE if pusher_player_id == 1 else _Relationship.IMMOVABLE
		EntityKind.P2_BOX:
			if pusher_is_box:
				return _Relationship.MOVABLE
			return _Relationship.IMMOVABLE if pusher_player_id == 1 else _Relationship.MOVABLE
		EntityKind.P1_BODY:
			return _Relationship.CONTROLLED if pusher_player_id == 1 else _Relationship.IMMOVABLE
		EntityKind.P2_BODY:
			return _Relationship.IMMOVABLE if pusher_player_id == 1 else _Relationship.CONTROLLED
		EntityKind.GOAL:
			return _Relationship.GOAL
	return _Relationship.IMMOVABLE

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
	var tile_size := Globals.TILE_SIZE
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

	var rel := neighbor._get_relationship_for_pusher(pusher_player_id, _is_box())
	# GOAL: Only Players (CONTROLLED) can move into Goals. Boxes cannot.
	if rel == _Relationship.GOAL:
		return _is_controlled()
	# Only MOVABLE can be pushed; IMMOVABLE blocks.
	if rel == _Relationship.MOVABLE:
		return neighbor.can_move(direction, pusher_player_id)
	return false

## Moves self within the TileMapLayer and tweens the sprite to the new position.
## Pushes MOVABLE neighbors first (recursive chain), then moves self.
## Returns true if move succeeded, false if blocked.
func move(direction: TileSet.CellNeighbor) -> bool:
	if not can_move(direction, Globals.pusher_player_id):
		if _is_controlled():
			block_sfx.play()
		blocked.emit(self, direction)
		return false

	var layer := _get_tile_map_layer()
	if layer == null:
		return false

	var my_coords := get_map_coords()
	var new_coords := layer.get_neighbor_cell(my_coords, direction)
	var neighbor := Globals.get_entity_at(new_coords) as Entity
	var neighbor_is_goal := neighbor != null and neighbor._get_relationship_for_pusher(Globals.pusher_player_id, _is_box()) == _Relationship.GOAL
	var is_moving_into_goal := neighbor_is_goal and _is_controlled()

	# Push MOVABLE neighbor first (recursive chain: farthest entity moves first)
	if neighbor != null and neighbor._get_relationship_for_pusher(Globals.pusher_player_id, _is_box()) == _Relationship.MOVABLE:
		var success := await neighbor.move(direction)
		if not success:
			if _is_controlled():
				block_sfx.play()
			blocked.emit(self, direction)
			return false

	# Now move self
	Globals.unregister_entity(my_coords)
	# Don't register when moving into a Goal (keeps Goal in registry for subsequent Players)
	if not neighbor_is_goal:
		Globals.register_entity(new_coords, self)

	var target_position := layer.map_to_local(new_coords)

	if current_tween != null and current_tween.is_valid():
		current_tween.kill()
	current_tween = create_tween().set_ease(tween_properties.ease_type).set_trans(tween_properties.transition_type)
	current_tween.tween_property(self, "position", target_position, tween_properties.duration)
	await current_tween.finished
	current_tween = null

	if is_moving_into_goal:
		if not GOAL_REUSABLE:
			Globals.unregister_entity(new_coords)
			neighbor.queue_free()
		_disable_for_escape()
		exit_sfx.play()
		await exit_sfx.finished
		var remaining_players: int = Globals.count_controlled_entities()
		if remaining_players == 0:
			var game = get_tree().current_scene
			if game.has_method("_on_win_level"):
				game._on_win_level()
		queue_free()
		return true

	if _is_controlled():
		move_sfx.play()
	else:
		push_sfx.play()
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
		if neighbor != null and neighbor != self and neighbor._get_relationship_for_pusher(pusher_player_id, _is_box()) == _Relationship.MOVABLE:
			pushed.emit(self, neighbor, direction)

	return await move(cell_dir)

func _disable_for_escape() -> void:
	escaped = true
	collision_layer = 0
	collision_mask = 0
	set_process_unhandled_input(false)
	set_physics_process(false)

func _unhandled_input(_event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if escaped:
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
			if _get_relationship_for_pusher(player_id) == _Relationship.CONTROLLED:
				_queued_direction = direction
				_queued_pusher_id = player_id
			return

func _physics_process(_delta: float) -> void:
	if escaped:
		return
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
	if escaped:
		return false
	return entity_kind == EntityKind.P1_BODY or entity_kind == EntityKind.P2_BODY

func _is_box() -> bool:
	return entity_kind == EntityKind.BOX or entity_kind == EntityKind.P1_BOX or entity_kind == EntityKind.P2_BOX
