extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	play("default")
	set_frame(0)


func _process(delta):
	if get_frame() >= get_sprite_frames().get_frame_count("default")-1:
		queue_free()


func _on_Body_Detect_body_shape_entered(body_id, body, body_shape, area_shape):
	Global.Smile_Anim = true
	body.queue_free()

