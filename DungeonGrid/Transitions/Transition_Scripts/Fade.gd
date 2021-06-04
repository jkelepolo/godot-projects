extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.died == true:
		Global.died = false
		$AnimationPlayer.play("Red_Fade")

func _process(delta):
	pass
