extends Node2D

func _process(delta):
	var X = int(get_global_mouse_position().x/32)
	var Y = int(get_global_mouse_position().y/32)
	
#	for child in $Panel/MarginContainer/ScrollContainer/GridContainer.get_children():
#		if child.global_poisition.x == X and child.global_position.y == Y:
#			$Label.text = str(child.name) + ": " + str(X) + "," + str(Y)


func _ready():
	
	
	for i in range(20):
		var slot = load("res://Scenes/GUI/Slot.tscn").instance()
		slot.name = str(i)
		$Panel/MarginContainer/ScrollContainer/GridContainer.add_child(slot, true)
