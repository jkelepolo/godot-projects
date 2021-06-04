extends KinematicBody2D

var speed = 150
var collision_info = null
var velocity = Vector2(speed,speed)
func _physics_process(delta):
	collision_info = move_and_collide(delta * velocity * Vector2(1,0))
	
	if collision_info:
		velocity = velocity.bounce(collision_info.normal)


func _on_Player_Detect_body_shape_entered(body_id, body, body_shape, area_shape):
	body.queue_free()
