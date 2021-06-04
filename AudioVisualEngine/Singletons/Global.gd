extends Node

enum{UP, RIGHT, DOWN, LEFT}
var isPlaying = true

var Directions = [Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0)]
var SPEED = 100
var DIRECTION = Vector2(0,0)
var CurrentDirection = RIGHT

func _process(delta):
	
	DIRECTION = Directions[CurrentDirection]
	


func Turn(TURN):
	
	CurrentDirection += TURN
	
	if CurrentDirection > LEFT:
		CurrentDirection = UP
	elif CurrentDirection < UP:
		CurrentDirection = LEFT
		
	
