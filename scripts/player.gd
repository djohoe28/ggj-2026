extends Movable
class_name Player

signal pushed(player: Player, collider: Movable, direction: Vector2)

@export var moves_after_push: bool = true

const ActionToVector = {
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
}

func try_move(direction: Vector2) -> bool:
	# Check for collision
	$RayCast2D.target_position = direction * Globals.TILE_SIZE
	$RayCast2D.force_raycast_update()
	
	if not $RayCast2D.is_colliding():
		move(direction)
		return true
	
	var collider = $RayCast2D.get_collider()
	
	# Try to push movable objects
	if collider is Movable and collider.try_move(direction):
		pushed.emit(self, collider, direction)
		if moves_after_push:
			move(direction)
		return true
	
	# Movement blocked
	blocked.emit(self, collider, direction)
	return false

func _unhandled_input(_event: InputEvent) -> void:
	for action in ActionToVector:
		if Input.is_action_just_pressed(action):
			try_move(ActionToVector[action])
