extends Area2D



func _on_Heart_body_shape_entered(body_id, body, body_shape, area_shape):
	if Global.LIVES < 3:
		Global.LIVES += 1
		Global.Life_Level = Global.level
		Global.save_data()
		queue_free()
	
