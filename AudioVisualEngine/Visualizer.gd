extends Node2D

# Gonkee's audio visualiser for Godot 3.2 - full tutorial https://youtu.be/AwgSICbGxJM
# If you use this, I would prefer if you gave credit to me and my channel

onready var spectrum = AudioServer.get_bus_effect_instance(0, 0)

var mag
var RANGE = 20
var Scale
var bgColor = Vector3(0,0,0)

var definition = RANGE
var total_w = 400
var total_h = 200
var min_freq = RANGE
var max_freq = 20000

var max_db = 0
var min_db = -40

var accel = RANGE
var histogram = []

func _ready():
	max_db += get_parent().volume_db
	min_db += get_parent().volume_db
	
	for i in range(definition):
		histogram.append(0)

func _process(delta):
	
	
	var freq = min_freq
	var interval = (max_freq - min_freq) / definition
	
	for i in range(definition):
		
		var freqrange_low = float(freq - min_freq) / float(max_freq - min_freq)
		freqrange_low = freqrange_low * freqrange_low * freqrange_low * freqrange_low
		freqrange_low = lerp(min_freq, max_freq, freqrange_low)
		
		freq += interval
		
		var freqrange_high = float(freq - min_freq) / float(max_freq - min_freq)
		freqrange_high = freqrange_high * freqrange_high * freqrange_high * freqrange_high
		freqrange_high = lerp(min_freq, max_freq, freqrange_high)
		
		mag = spectrum.get_magnitude_for_frequency_range(freqrange_low, freqrange_high)
		mag = linear2db(mag.length())
		mag = (mag - min_db) / (max_db - min_db)
		
		mag += 0.3 * (freq - min_freq) / (max_freq - min_freq)
		mag = clamp(mag, 0.05, 1)
		
		histogram[i] = lerp(histogram[i], mag, accel * delta)
		
		
		
	var left = -1
	var right = 1
	var Detected = 0.5
	
	
	var Bass = histogram[0]
	var Vocal = histogram[5]
	var HighHat = histogram[16]
	
	for child in $Particles.get_children():
		if Bass > 0.45:
			bgColor = bgColor.move_toward(Vector3(Bass+0.4,0,0),0.005)
			child.gravity.y = -90
		elif Vocal > 0.45:
			bgColor = bgColor.move_toward(Vector3(0,0,Vocal+0.4),0.005)
			child.gravity.y = 70
		else:
			child.gravity.y = 100
		bgColor = bgColor.move_toward(Vector3(histogram[8]/2, histogram[16], histogram[10]/2),0.009)
#		bgColor = bgColor.move_toward(Vector3(histogram[7] + histogram[9], histogram[11] + histogram[13], histogram[15] + histogram[16]),0.009)
	
#	get_owner().get_node("ColorRect").set_modulate(Color(bgColor.x, bgColor.y, bgColor.z))
		child.set_modulate(Color(bgColor.x, bgColor.y, bgColor.z))
		
	$Border.set_modulate(Color(bgColor.x, bgColor.y, bgColor.z))

	$Sprite.scale = $Sprite.scale.move_toward(Vector2((histogram[8]+0.06), (histogram[5]+0.06)),0.009).clamped(0.15)
	$Sprite.scale = $Sprite.scale.move_toward(Vector2((0.08), (0.08)),0.007)
	
	
	get_node("../CanvasLayer/Label").text = ""
	for i in range(RANGE):
		get_node("../CanvasLayer/Label").text += "\n"+str(histogram[i])
	get_node("../CanvasLayer/Label").text += "\n"+str(mag)
	
	
	update()


func _on_AudioStreamPlayer_finished():
	Global.isPlaying = false
