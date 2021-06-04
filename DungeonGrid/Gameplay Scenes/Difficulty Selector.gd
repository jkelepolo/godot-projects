extends Node

var difficulty = 0

func _process(delta):
	get_node("../..").difficulty = difficulty
	if difficulty == 0:
		$Selection.set_global_position(Vector2(780,335),true)
	elif difficulty == 1:
		$Selection.set_global_position(Vector2(780,286),true)
	elif difficulty == 2:
		$Selection.set_global_position(Vector2(780,235),true)
	elif difficulty == 3:
		$Selection.set_global_position(Vector2(780,188),true)
	elif difficulty == 4:
		$Selection.set_global_position(Vector2(780,139),true)


func _on_0_pressed():
	difficulty = 0


func _on_1_pressed():
	difficulty = 1


func _on_2_pressed():
	difficulty = 2


func _on_3_pressed():
	difficulty = 3


func _on_4_pressed():
	difficulty = 4
