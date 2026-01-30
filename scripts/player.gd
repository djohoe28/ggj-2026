@tool
extends Movable
class_name Player

#region Signals

## The Player has successfully pushed a Movable object.
signal pushed(player: Player, collider: Movable, direction: Vector2)

#endregion

#region Properties

## If true, the player will move into the space after successfully pushing an object.
@export var moves_after_push: bool = true

## Mapping of input actions to movement vectors
@export var ActionToVector = {
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
}

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
	
	for action in ActionToVector:
		if Input.is_action_just_pressed(action):
			queued_direction = ActionToVector[action]
			break

func _physics_process(_delta: float) -> void:
	# Process queued movement after physics update
	if queued_direction != Vector2.ZERO and not is_moving:
		is_moving = true
		await try_move(queued_direction)
		queued_direction = Vector2.ZERO
		is_moving = false

#endregion
