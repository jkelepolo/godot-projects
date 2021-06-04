extends KinematicBody2D

var smooth_speed = 3
var acceleration = 100

func _process(delta):
	if OS.get_unix_time() - Server.Buffer[name]["Unix"] >= 2:
		Server.Buffer.erase(name)
		queue_free()
		return
	elif Server.Buffer[name]["Quit"]:
		Server.Buffer.erase(name)
		queue_free()
		return
	$Username.text = Server.Buffer[name]["Name"]
	global_position = global_position.move_toward(Server.Buffer[name]["Coordinates"],delta * acceleration)
	
	
#func _physics_process(delta):
#	var Target = Server.Buffer[name]["Coordinates"]
#	var speed = global_position.distance_to(Target) * smooth_speed
#	var Target_Direction = Target - global_position
#	Target_Direction = Target_Direction.normalized()
#	move_and_slide(Target_Direction * speed)
