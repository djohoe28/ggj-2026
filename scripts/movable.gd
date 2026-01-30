extends StaticBody2D
class_name Movable

#region Signals

## The Movable has successfully moved.
signal moved(movable: Movable, direction: Vector2)

## The Movable's movement was blocked by a collider.
signal blocked(movable: Movable, collider: Node2D, direction: Vector2)

#endregion

#region Methods

## Move the Movable in the specified direction.
func move(direction: Vector2) -> void:
	position += direction * Globals.TILE_SIZE
	moved.emit(self, direction)

## Attempt to move the Movable in the specified direction.
func try_move(direction: Vector2) -> bool:
	# Check for collision
	$RayCast2D.target_position = direction * Globals.TILE_SIZE
	$RayCast2D.force_raycast_update()
	
	if not $RayCast2D.is_colliding():
		move(direction)
		return true
	
	blocked.emit(self, $RayCast2D.get_collider(), direction)
	return false

#endregion