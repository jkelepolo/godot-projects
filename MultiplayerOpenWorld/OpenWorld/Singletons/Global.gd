extends Node

var busy = false

var player_position = Vector2.ZERO
var NavigationNode
var GameNode
var MessageNode
var PLAYER
var biomeList = []
var biomeWeights = {}
var planetList = []
var planetWeights = {}

var game_save_class := preload("res://Save/Save.gd")
var savePath = "res://save/"
var saveName = "Regions.tres"
var save_vars = ["Regions"]


func _exit_tree():
	Server.LogOut()
	


func _process(delta):
	Engine.set_target_fps(Engine.get_iterations_per_second())

	if Input.is_action_just_pressed("ui_escape"):
		Server.LogOut()
	

func Pathfind(START, END):
	return NavigationNode.get_simple_path(START,END)


# Save and Load Systems
func verify_save(data):
	for v in data:
		if data.get(v) == null:
			return false

func load_data():
	var dir = Directory.new()
	if not dir.dir_exists(savePath+saveName):
		return false
	
	var Load = load(savePath+saveName)
#	if not verify_save(Load):
#		return false
	
#	Regions = Load.Regions


func save_data():
	var Save = game_save_class.new()
	
	
	var dir = Directory.new()
	if not dir.dir_exists(savePath):
		dir.make_dir_recursive(savePath)
	
	ResourceSaver.save(savePath + saveName, Save)
