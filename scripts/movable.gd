extends StaticBody2D
class_name Movable

signal moved(movable: Movable, direction: Vector2)
signal blocked(movable: Movable, collider: Node2D, direction: Vector2)

func move(direction: Vector2) -> void:
	position += direction * Globals.TILE_SIZE
	moved.emit(self, direction)

func try_move(direction: Vector2) -> bool:
	# Check for collision
	$RayCast2D.target_position = direction * Globals.TILE_SIZE
	$RayCast2D.force_raycast_update()
	
	if not $RayCast2D.is_colliding():
		move(direction)
		return true
	
	blocked.emit(self, $RayCast2D.get_collider(), direction)
	return false
