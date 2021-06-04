extends KinematicBody2D

var speed = 180
var collision_info = null
var velocity = Vector2(speed,speed)
var dirx = 0
var diry = 0
var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = Global.game_seed

func _physics_process(delta):
	collision_info = move_and_collide(delta * velocity * Vector2(dirx,diry).normalized())
	
	if collision_info:
		velocity = velocity.bounce(collision_info.normal)


func _on_Change_Direction_timeout():
	dirx = rng.randf_range(-1,1)
	diry = rng.randf_range(-1,1)
	while dirx == 0 and diry == 0:
		dirx = rng.randf_range(-1,1)
		diry = rng.randf_range(-1,1)
	

	$Change_Direction.start( rng.randf_range(0,2))



func _on_Player_Detect_body_shape_entered(body_id, body, body_shape, area_shape):
	body.queue_free()
