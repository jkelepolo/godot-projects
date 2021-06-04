extends TextureButton


func _on_Button_pressed():
	$Sprite.global_position = get_global_mouse_position()
	$Sprite/AnimationPlayer.play("Click")
