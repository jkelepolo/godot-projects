extends Node

var savePath = "res://save/"
var save = "res://save/DG_Save.res"
var save_vars = ["save"]

var game_save_class := preload("res://save/save_script.gd")

var level = 0
var High_Score = 0
var SWITCHES = 5
var LIVES = 3
var CHECKPOINT = 0
var ads = 0
var bd_count = 0
var Life_Level = 0
var difficulty = 0

var MenuAudioPosition = 0
var AudioNode = load("res://Audio/Audio.tscn").instance()

var found_easteregg = false
var is_mute = false


var Smile_Anim = false
var SWITCH_ON = false
var BOMB_EXPLODE = false
var died = false


var game_seed = (High_Score * level) + level
var rng = RandomNumberGenerator.new()

func _ready():
	add_child(AudioNode)
	rng.seed = game_seed
	var isLoaded = load_data()
	if not isLoaded:
		save_data()


func _process(delta):
	if Input.is_action_just_pressed("ui_end"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func DungeonRNG(x,y,type):
	rng.seed = game_seed
	if type == "f":
		return rng.randf_range(x,y)
	else:
		return rng.randi_range(x,y)
		
		
		
# Save and Load Systems
func verify_save(data):
	for v in data:
		if data.get(v) == null:
			return false

func load_data():
	var dir = Directory.new()
	if not dir.dir_exists(savePath):
		return false
	
	var data = load(save)
#	if not verify_save(data):
#		return false
	
	level = data.level
	High_Score = data.highscore
	CHECKPOINT = data.checkpoint
	LIVES = data.lives
	ads = data.ads
	is_mute = data.is_mute
	bd_count = data.BD_Count
	found_easteregg = data.found_easteregg
	Life_Level = data.Life_Level
	difficulty = data.difficulty

func save_data():
	var new_save = game_save_class.new()
	new_save.level = level
	new_save.highscore = High_Score
	new_save.checkpoint = CHECKPOINT
	new_save.lives = LIVES
	new_save.ads = ads
	new_save.is_mute = is_mute
	new_save.BD_Count = bd_count
	new_save.found_easteregg = found_easteregg
	new_save.Life_Level = Life_Level
	new_save.difficulty = difficulty
	
	var dir = Directory.new()
	if not dir.dir_exists(savePath):
		dir.make_dir_recursive(savePath)
	
	ResourceSaver.save(save, new_save)

