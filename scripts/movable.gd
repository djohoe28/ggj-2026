@tool
extends Entity
class_name Movable

#region Signals

## The Movable has successfully moved.
signal moved(movable: Movable, direction: Vector2)

## The Movable's movement was blocked by a collider.
signal blocked(movable: Movable, collider: Node2D, direction: Vector2)

#endregion

#region Properties

@export var move_duration: float = 0.15
@export var ease_type: Tween.EaseType = Tween.EASE_OUT
@export var trans_type: Tween.TransitionType = Tween.TRANS_QUINT

#endregion

#region Variables

var is_tweening: bool = false

#endregion

#region Methods

func move(direction: Vector2) -> void:
	var target_position = position + direction * Globals.TILE_SIZE
	
	is_tweening = true
	var tween = create_tween()
	tween.set_ease(ease_type).set_trans(trans_type).tween_property(self, "position", target_position, move_duration)
	await tween.finished
	is_tweening = false
	
	moved.emit(self, direction)

func try_move(direction: Vector2) -> bool:
	if can_move(direction):
		await move(direction)
		return true
	blocked.emit(self, $RayCast2D.get_collider(), direction)
	return false

#endregion

func can_move(direction: Vector2) -> bool:
	# Don't attempt move if already tweening
	if is_tweening:
		return false
	
	# Check for collision
	$RayCast2D.target_position = direction * Globals.TILE_SIZE
	$RayCast2D.force_raycast_update()
	
	if not $RayCast2D.is_colliding():
		return true
	
	return false
