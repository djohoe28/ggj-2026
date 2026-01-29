extends StaticBody2D

signal moved
signal pushed
signal blocked

const ActionToVector = {
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
}

func try_move(direction: Vector2) -> void:
	# Check for collision
	$RayCast2D.target_position = direction * Globals.TILE_SIZE
	$RayCast2D.force_raycast_update()
	# Move if no collision
	if not $RayCast2D.is_colliding():
		position += direction * Globals.TILE_SIZE
		emit_signal("moved")
		print("Player moved to ", position)
	else:
		if $RayCast2D.get_collider().is_in_group("Pushable"):
			# TODO: Push the object first!
			emit_signal("pushed", $RayCast2D.get_collider(), direction)
			# TODO: Move player if push successful(?)
			# position += direction * Globals.TILE_SIZE
			print("Player pushed an object at ", $RayCast2D.get_collider().position)
		else:
			emit_signal("blocked")
			print("Player movement blocked at ", position + direction * Globals.TILE_SIZE)

func _unhandled_input(_event: InputEvent) -> void:
	# Handle movement input; Order is determined by `ActionToVector.keys()`.
	for action in ActionToVector.keys():
		if Input.is_action_just_pressed(action):
			try_move(ActionToVector[action])
