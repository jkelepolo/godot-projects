extends KinematicBody2D

func _process(delta):
	if Global.isPlaying:
		var dot = load("res://Tools/Dot.tscn").instance()
		dot.global_position = global_position
		
		get_owner().get_node("Dots").add_child(dot)
	else:
		var ZOOM = Vector2(8,8)
		if $Camera2D.zoom < ZOOM:
			$Camera2D.zoom.move_toward(ZOOM, 1)

func _physics_process(delta):
	if Global.isPlaying:
		move_and_slide(Global.DIRECTION * Global.SPEED)
	else:
		var input = Vector2.ZERO
		input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
		input = input.normalized()
		move_and_slide(input * Global.SPEED)


func _on_AudioStreamPlayer_finished():
	global_position = Vector2(0,0)
	
