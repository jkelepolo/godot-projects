extends AnimatedSprite


func _process(delta):
	if get_frame() == 0:
		$StaticBody/Collision.set_disabled(false)
	else:
		$StaticBody/Collision.set_disabled(true)
