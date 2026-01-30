@tool
extends Movable
class_name Player

#region Signals

## The Player has successfully pushed a Movable object.
signal pushed(player: Player, collider: Movable, direction: Vector2)

#endregion

enum PlayerID {
	P1 = 1,
	P2 = 2
}

const P1ActionToVector = {
	"p1_left": Vector2.LEFT,
	"p1_right": Vector2.RIGHT,
	"p1_up": Vector2.UP,
	"p1_down": Vector2.DOWN
}

const P2ActionToVector = {
	"p2_left": Vector2.LEFT,
	"p2_right": Vector2.RIGHT,
	"p2_up": Vector2.UP,
	"p2_down": Vector2.DOWN
}

## Mapping of input actions to movement vectors
@onready var action_to_vector = P1ActionToVector if player_id == PlayerID.P1 else P2ActionToVector

@export var player_id: PlayerID = PlayerID.P1:
	set(value):
		player_id = value
		apply_player_id()

func apply_player_id():
	action_to_vector = P1ActionToVector if player_id == PlayerID.P1 else P2ActionToVector


#region Properties

## If true, the player will move into the space after successfully pushing an object.
@export var moves_after_push: bool = true

#endregion

#region Variables

## Queue for movement input (to be processed after physics update)
var queued_direction: Vector2 = Vector2.ZERO

## Flag to indicate if the player is currently moving
var is_moving: bool = false

#endregion

#region Overrides

## Attempt to move the Player in the specified direction.
## NOTE: This overrides the base Movable `try_move` to add push logic.
func try_move(direction: Vector2) -> bool:
	# Don't attempt move if already tweening
	if is_tweening:
		return false
	
	# Check for collision
	$RayCast2D.target_position = direction * Globals.TILE_SIZE
	$RayCast2D.force_raycast_update()
	
	if not $RayCast2D.is_colliding():
		await move(direction)  # Inherited from Movable
		return true
	
	var collider = $RayCast2D.get_collider()
	
	# Try to push movable objects
	if collider is Movable and collider.can_move(direction):
		collider.try_move(direction)
		pushed.emit(self, collider, direction)
		if moves_after_push:
			await move(direction)  # Inherited from Movable  # TODO: REMOVED AWAIT
		return true
	
	# Movement blocked
	blocked.emit(self, collider, direction)
	return false

func _unhandled_input(_event: InputEvent) -> void:
	# Only queue input if not currently moving
	if is_moving:
		return
	
	for action in action_to_vector:
		if Input.is_action_just_pressed(action):
			queued_direction = action_to_vector[action]
			break

func _physics_process(_delta: float) -> void:
	# Process queued movement after physics update
	if queued_direction != Vector2.ZERO and not is_moving:
		is_moving = true
		await try_move(queued_direction)
		queued_direction = Vector2.ZERO
		is_moving = false

#endregion
