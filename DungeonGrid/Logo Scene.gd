extends Node2D


func _ready():
	$Studios.play("default")

func MenuScene():
	get_tree().change_scene("res://Gameplay Scenes/Menu.tscn")
