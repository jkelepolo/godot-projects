extends Node2D

var difficulty = 0


func _on_Yes_BTN_pressed():
	Global.difficulty = difficulty
	Global.level = 0
	Global.CHECKPOINT = 0
	Global.LIVES = 3
	Global.ads = 0
	Global.Life_Level = 0
	Global.save_data()
	get_tree().change_scene("res://Gameplay Scenes/Dungeon.tscn")

func _on_No_BTN_pressed():
	get_tree().change_scene("res://Gameplay Scenes/Menu.tscn")
