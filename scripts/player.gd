@tool
extends Entity
class_name Player

# ## The Player has successfully pushed another Entity.
# signal pushed(player: Player, collider: Entity, direction: Vector2)

# enum PlayerID {
# 	P1 = 1,
# 	P2 = 2
# }

# const P1ActionToVector = {
# 	"p1_left": Vector2.LEFT,
# 	"p1_right": Vector2.RIGHT,
# 	"p1_up": Vector2.UP,
# 	"p1_down": Vector2.DOWN
# }

# const P2ActionToVector = {
# 	"p2_left": Vector2.LEFT,
# 	"p2_right": Vector2.RIGHT,
# 	"p2_up": Vector2.UP,
# 	"p2_down": Vector2.DOWN
# }

# ## Mapping of input actions to movement vectors
# @onready var action_to_vector = P1ActionToVector if player_id == PlayerID.P1 else P2ActionToVector

# @export var player_id: PlayerID = PlayerID.P1:
# 	set(value):
# 		player_id = value
# 		apply_player_id()

# func apply_player_id():
# 	action_to_vector = P1ActionToVector if player_id == PlayerID.P1 else P2ActionToVector

# ## If true, the player will move into the space after successfully pushing an object.
# @export var moves_after_push: bool = true

# ## Queue for movement input (to be processed after physics update)
# var queued_direction: Vector2 = Vector2.ZERO

# ## Flag to indicate if the player is currently moving
# var is_moving: bool = false

# ## Attempt to move the Player in the specified direction.
# ## Sets pusher context and delegates to Entity.move().
# func try_move(direction: Vector2) -> bool:
# 	Globals.pusher_player_id = int(player_id)
# 	var cell_dir := Entity.vector_to_cell_neighbor(direction)

# 	# Emit pushed if we're about to push an Entity (before move handles it)
# 	var layer := _get_tile_map_layer()
# 	if layer != null:
# 		var my_coords := get_map_coords()
# 		var new_coords := layer.get_neighbor_cell(my_coords, cell_dir)
# 		var neighbor := Globals.get_entity_at(new_coords) as Entity
# 		if neighbor != null and neighbor != self and neighbor._get_relationship_for_pusher(int(player_id)) == Entity.Relationship.MOVABLE:
# 			pushed.emit(self, neighbor, direction)

# 	return await move(cell_dir)

# func _unhandled_input(_event: InputEvent) -> void:
# 	if is_moving:
# 		return

# 	for action in action_to_vector:
# 		if Input.is_action_just_pressed(action):
# 			queued_direction = action_to_vector[action]
# 			break

# func _physics_process(_delta: float) -> void:
# 	if queued_direction != Vector2.ZERO and not is_moving:
# 		is_moving = true
# 		await try_move(queued_direction)
# 		queued_direction = Vector2.ZERO
# 		is_moving = false
