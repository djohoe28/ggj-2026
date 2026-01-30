extends StaticBody2D

signal moved
signal pushed
signal blocked

@export var moves_after_push: bool = true

const ActionToVector = {
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
}

func move(direction: Vector2) -> void:
	position += direction * Globals.TILE_SIZE
	emit_signal("moved")

func try_move(direction: Vector2) -> void:
	# Check for collision
	$RayCast2D.target_position = direction * Globals.TILE_SIZE
	$RayCast2D.force_raycast_update()
	# Move if no collision
	if not $RayCast2D.is_colliding():
		move(direction)
	else:
		var collider = $RayCast2D.get_collider() as Node2D
		# If colliding with a pushable object, try to push it
		if collider.is_in_group("Pushable"):
			collider.call("try_push", direction)
			emit_signal("pushed", collider, direction)
			# Move after pushing if toggled
			if moves_after_push:
				move(direction)
			print(name, " pushed ", collider.name)
		else:
			emit_signal("blocked")
			print(name, " blocked by ", collider.name)

func _unhandled_input(_event: InputEvent) -> void:
	# Handle movement input; Order is determined by `ActionToVector.keys()`.
	for action in ActionToVector.keys():
		if Input.is_action_just_pressed(action):
			try_move(ActionToVector[action])
