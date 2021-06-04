extends AudioStreamPlayer


func _process(delta):
	if Input.is_action_just_pressed("start"):
		self.play(0)
