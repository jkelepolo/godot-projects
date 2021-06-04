extends Node2D

var FRAME = 0
onready var MAX_FRAMES = $Info_Text.get_sprite_frames().get_frame_count("default")-1

func _ready():
	pass

func _on_X_pressed():
	if not Global.get_node("Audio").MuteCheck():
		Global.get_node("Audio").get_node("ButtonClick").play(0)
	get_tree().change_scene("res://Gameplay Scenes/Menu.tscn")

	
func _on_Right_Arrow_pressed():
	if $Right_Arrow.is_visible():
		if not Global.get_node("Audio").MuteCheck():
			Global.get_node("Audio").get_node("ButtonClick").play(0)
		
		if FRAME < MAX_FRAMES-1:
			FRAME += 1

func _on_Left_Arrow_pressed():
	if $Left_Arrow.is_visible():
		if not Global.get_node("Audio").MuteCheck():
			Global.get_node("Audio").get_node("ButtonClick").play(0)
		if FRAME!=0:
			FRAME -= 1

func _on_Easter_Egg_pressed():
	if Global.found_easteregg == false:
		Global.found_easteregg = true
		Global.save_data()
	
	if FRAME == MAX_FRAMES-1:
		FRAME += 1
		if not Global.get_node("Audio").MuteCheck():
			Global.get_node("Audio").get_node("Static").play(0)
		$Static.show()
		$Timer.start()

func _on_Timer_timeout():
	Global.get_node("Audio").get_node("Static").stop()
	$Static.hide()

func _process(delta):
	$Info_Text.set_frame(FRAME)
	
	if FRAME == 0:
		$Left_Arrow.hide()
	else:
		$Left_Arrow.show()
		
	if FRAME == MAX_FRAMES - 1:
		$Right_Arrow.hide()
	else:
		$Right_Arrow.show()
		
	if FRAME == MAX_FRAMES:
		$Left_Arrow.hide()
		$Right_Arrow.hide()

