extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not Input.is_action_just_pressed("ui_left") and not Input.is_action_just_pressed("ui_right") and not Input.is_action_just_pressed("ui_up") and not Input.is_action_just_pressed("ui_down"):
		$RayCast2D.target_position = Vector2.ZERO
		return
	var xinput := Input.get_axis("ui_left", "ui_right")
	var yinput := Input.get_axis("ui_up", "ui_down")
	# Prevent diagonal movement (prioritize horizontal movement)
	if xinput != 0:
		yinput = 0
	$RayCast2D.target_position = Vector2(xinput, yinput) * Globals.TILE_SIZE
	$RayCast2D.force_raycast_update()
	if not $RayCast2D.is_colliding():
		position += Vector2(xinput, yinput) * Globals.TILE_SIZE
	else:
		print("Collision detected!")
