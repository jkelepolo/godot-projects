extends Node2D


func _process(delta):
	if Global.is_mute:
		Global.get_node("Audio").MuteCheck()
	if not Global.get_node("Audio").get_node("MenuMusic").playing and not Global.is_mute:
		Global.get_node("Audio").get_node("MenuMusic").play(0)
	
	$UI/HighScore_Label/Highscore_Count.text = str(Global.High_Score+1)
	
	$UI/Bouncing_Death_Label/BD_Count.text = str(Global.bd_count)
	
	if Global.is_mute:
		$UI/Mute.set_frame(1)
	else:
		$UI/Mute.set_frame(0)
	
	if Global.found_easteregg == false:
		$UI/Bouncing_Death_Label.hide()
	else:
		$UI/Bouncing_Death_Label.show()

func _on_Info_pressed():
	if not Global.get_node("Audio").MuteCheck():
		Global.get_node("Audio").get_node("ButtonClick").play(0)
	get_tree().change_scene("res://Gameplay Scenes/Info.tscn")


func _on_ContinueGame_pressed():
	if not Global.get_node("Audio").MuteCheck():
		Global.get_node("Audio").get_node("ButtonClick").play(0)
	get_tree().change_scene("res://Gameplay Scenes/Dungeon.tscn")



func _on_Mute_BTN_pressed():
	if not Global.get_node("Audio").MuteCheck():
		Global.get_node("Audio").get_node("ButtonClick").play(0)
		
	if Global.is_mute:
		Global.is_mute = false
	else:
		Global.is_mute = true
	Global.save_data()


func _on_NewGame_BTN_pressed():
	if not Global.get_node("Audio").MuteCheck():
		Global.get_node("Audio").get_node("ButtonClick").play(0)
	get_tree().change_scene("res://Gameplay Scenes/NewGame.tscn")
