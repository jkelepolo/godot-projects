extends Node2D

export var Testing = false
var level = Global.level
var High_Score = Global.High_Score
var SWITCHES = Global.SWITCHES
var LIVES = Global.LIVES

var on_gate = false

var SWITCH_ON = false
var BOMB_EXPLODE = false


var game_seed = (High_Score * level) + level
var rng = RandomNumberGenerator.new()


var BDGen = []
var HGen = []
var CGen = []
var VGen = []

onready var genMap = $Set/Generators
onready var genList = genMap.get_used_cells()
onready var genCount = genList.size()

enum{UP, DOWN, LEFT, RIGHT}
enum{VENEMY, HENEMY, CYCLOPS, BD}

func _ready():
	
	var RandomSong = RandomNumberGenerator.new()
	RandomSong.randomize()
	var Song = RandomSong.randi_range(1,3)
	
	if not Global.is_mute:
		Global.get_node("Audio").get_node("MenuMusic").stop()
		
		if not Global.get_node("Audio").isSongPlaying():
			Global.get_node("Audio").get_node("Game_Play_Music_"+str(Song)).play(0)
	
	
	var tileMap = $Set/Tiles
	var tileList = tileMap.get_used_cells() 
	var tileCount = tileList.size()
		
	rng.seed = game_seed
	
	$Objects/Bomb.queue_free()
	if Testing == false:
		$Enemies/Vertical_Enemy.queue_free()
		$Enemies/Horizontal_Enemy.queue_free()
		$Enemies/Bouncing_Death.queue_free()
		$Enemies/Happy_Cyclops.queue_free()
	
	# Populate Generator Lists
	for i in range (0,genCount):
			var gen = genMap.get_cellv(genList[i])
			if genMap.tile_set.tile_get_name(gen).left(8) == "HGen.png":
				HGen.append(genList[i])
			elif genMap.tile_set.tile_get_name(gen).left(8) == "VGen.png":
				VGen.append(genList[i])
			elif genMap.tile_set.tile_get_name(gen).left(8) == "CGen.png":
				CGen.append(genList[i])
			elif genMap.tile_set.tile_get_name(gen).left(9) == "BDGen.png":
				BDGen.append(genList[i])
				
	var RANGE = 0
	# Generate Enemies
	if Global.difficulty == 0:
		RANGE = rng.randi_range(0,5)
	elif Global.difficulty == 1:
		RANGE = rng.randi_range(2,5)
	elif Global.difficulty == 2:
		RANGE = rng.randi_range(4,5)
	elif Global.difficulty == 3:
		RANGE = rng.randi_range(6,8)
	elif Global.difficulty == 4:
		RANGE = rng.randi_range(10,15)
	else:
		RANGE = 5
		
	for spawnCount in RANGE:
		GenEnemy()
	
	# Create Vertical Walls
	for i in range(0,tileCount):
		if tileList[i].x != 5:
			var Position = $Set/Tiles.map_to_world(tileList[i]) + Vector2(-1,12)
			CreateWall(Position,0,rng.randi_range(0,1))
	
	# Create Horizontal Walls
	for i in range(0,tileCount):
		if tileList[i].y != 6:
			var Position = $Set/Tiles.map_to_world(tileList[i]) + Vector2(32,43)
			CreateWall(Position,90,rng.randi_range(0,1))
			
	
	# Checkpoint
	if (Global.level+1) % 10 == 0:
		Global.CHECKPOINT = Global.level
		Global.save_data()
		
	# Highscore
	if Global.level > Global.High_Score:
		Global.High_Score = Global.level
		Global.save_data()
		
	if (Global.level+1) % 5 != 0 or Global.level == Global.Life_Level:
		$Heart.queue_free()
	
	#Tutorial
	if Global.level != 0:
		$UI/Text/Tutorial1.queue_free()
func _process(delta):
	
	# Labels
	$UI/Text/Number_Of_Switches.text = str(SWITCHES)
	$UI/Text/Number_Of_Enemies.text = str($Enemies/Instanced_Enemies.get_child_count())
	$UI/Text/Level_Text.text = str(Global.level+1)
	
	# Test for 0 Enemies
	if $Enemies/Instanced_Enemies.get_child_count() == 0 and $Objects/Gate.get_frame() == 0:
		$Objects/Gate.play("Open")
	
	# Player input
	if Input.is_action_just_pressed("ui_left"):
		Move(LEFT)
	elif Input.is_action_just_pressed("ui_right"):
		Move(RIGHT)
	elif Input.is_action_just_pressed("ui_down"):
		Move(DOWN)
	elif Input.is_action_just_pressed("ui_up"):
		Move(UP)
	
	if Input.is_action_just_pressed("switch"):
		SwitchWalls()
		
		
	if Input.is_action_just_pressed("bomb"):
		Bomb()
		
	# Animation frames
	if SWITCH_ON:
		$UI/Switch.set_frame(1)
	else:
		$UI/Switch.set_frame(0)
		
	if $Objects/Instanced_Bombs.get_child_count() == 0:
		$UI/Bomb.set_frame(0)
	else:
		$UI/Bomb.set_frame(1)
		
	# Check if player is dead
	if !is_instance_valid($Player):
		Global.Smile_Anim = false
		Global.died = true
		Global.LIVES -= 1
		Global.save_data()
		get_tree().change_scene("res://Gameplay Scenes/Dungeon.tscn")
	else:
		# Play player smile animation
		if Global.Smile_Anim:
			Global.Smile_Anim = false
			$Player/Player_Sprite.set_frame(0)
			$Player/Player_Sprite.play("Smile")
	
	
	if $Enemies/Instanced_Enemies.get_child_count() == 0 and on_gate == true:
		Global.level += 1
		Global.save_data()
		get_tree().reload_current_scene()
		
	#Player lives
	if Global.LIVES >= 3:
		$UI/Lives.set_frame(0)
	elif Global.LIVES == 2:
		$UI/Lives.set_frame(1)
	elif Global.LIVES == 1:
		$UI/Lives.set_frame(2)
	if Global.LIVES == 0:
		Global.level = Global.CHECKPOINT
		Global.Life_Level = 0
		Global.LIVES = 3
		Global.save_data()
		get_tree().reload_current_scene()

func GenVerticalEnemy():
	if VGen.size() != 0:
		var rand = rng.randi_range(0,VGen.size()-1)
		var enemy = load("res://Entities/Vertical_Enemy.tscn").instance()
		enemy.position = genMap.map_to_world(VGen[rand])+Vector2(32,0)
		VGen.remove(rand)
		
		$Enemies/Instanced_Enemies.add_child(enemy)
#	elif Global.level >= 10:
#		GenCyclopsEnemy()
	
func GenHorizontalEnemy():
	if HGen.size() != 0:
		var rand = rng.randi_range(0,HGen.size()-1)
		var enemy = load("res://Entities/Horizontal_Enemy.tscn").instance()
		enemy.position = genMap.map_to_world(HGen[rand])+Vector2(0,10)
		HGen.remove(rand)
		
		$Enemies/Instanced_Enemies.add_child(enemy)
		
	else:
		GenVerticalEnemy()
	
func GenBdEnemy():
	if BDGen.size() != 0:
		var rand = rng.randi_range(0,BDGen.size()-1)
		var enemy = load("res://Entities/Bouncing_Death.tscn").instance()
		enemy.position = genMap.map_to_world(BDGen[rand])+Vector2(32,0)
		BDGen.remove(rand)
		
		$Enemies/Instanced_Enemies.add_child(enemy)
	else:
		GenCyclopsEnemy()
	
func GenCyclopsEnemy():
	if CGen.size() != 0:
		var rand = rng.randi_range(0,CGen.size()-1)
		var enemy = load("res://Entities/Happy_Cyclops.tscn").instance()
		enemy.position = genMap.map_to_world(CGen[rand])+Vector2(32,0)
		CGen.remove(rand)
		
		$Enemies/Instanced_Enemies.add_child(enemy)
	else:
		GenHorizontalEnemy()
	

func GenEnemy():
	
	if level == 0:
		return
		
	elif level >= 9:
		var gen_number = rng.randi_range(0,3)
		if gen_number == BD:
			GenBdEnemy()
		elif gen_number == CYCLOPS:
			GenCyclopsEnemy()
		elif gen_number == VENEMY:
			GenVerticalEnemy()
		elif gen_number == HENEMY:
			GenHorizontalEnemy()
			
	elif level >= 6:
		var gen_number = rng.randi_range(0,2)
		if gen_number == CYCLOPS:
			GenCyclopsEnemy()
		elif gen_number == VENEMY:
			GenVerticalEnemy()
		elif gen_number == HENEMY:
			GenHorizontalEnemy()
		
	elif level >= 3:
		var gen_number = rng.randi_range(0,1)
		if gen_number == VENEMY:
			GenVerticalEnemy()
		elif gen_number == HENEMY:
			GenHorizontalEnemy()
		
	elif level >= 0:
		GenVerticalEnemy()

func WALL_OVERLAPS(DIRECTION):
	for CHILD in range (0,$Set/Instanced_Walls.get_child_count()):
		if DIRECTION == LEFT:
			if $Target_Loc/Left_Detect.overlaps_area($Set/Instanced_Walls.get_child(CHILD).get_child(0)) and $Set/Instanced_Walls.get_child(CHILD).get_frame() == 1:
				return true
		elif DIRECTION == UP:
			if $Target_Loc/Up_Detect.overlaps_area($Set/Instanced_Walls.get_child(CHILD).get_child(0)) and $Set/Instanced_Walls.get_child(CHILD).get_frame() == 1:
				return true
		elif DIRECTION == RIGHT:
			if $Target_Loc/Right_Detect.overlaps_area($Set/Instanced_Walls.get_child(CHILD).get_child(0)) and $Set/Instanced_Walls.get_child(CHILD).get_frame() == 1:
				return true
		elif DIRECTION == DOWN:
			if $Target_Loc/Down_Detect.overlaps_area($Set/Instanced_Walls.get_child(CHILD).get_child(0)) and $Set/Instanced_Walls.get_child(CHILD).get_frame() == 1:
				return true
	return false

func Move(DIRECTION):
	if is_instance_valid($Safe_Zone):
		$Safe_Zone.queue_free()
	if DIRECTION == UP:
		if WALL_OVERLAPS(UP):
			$Target_Loc.position = $Target_Loc.position + Vector2(0,-64)
	elif DIRECTION == RIGHT:
		if WALL_OVERLAPS(RIGHT):
			$Target_Loc.position = $Target_Loc.position + Vector2(64,0)
	elif DIRECTION == DOWN:
		if WALL_OVERLAPS(DOWN):
			$Target_Loc.position = $Target_Loc.position + Vector2(0,64)
	elif DIRECTION == LEFT:
		if WALL_OVERLAPS(LEFT):
			$Target_Loc.position = $Target_Loc.position + Vector2(-64,0)

func Bomb():
	if is_instance_valid($Safe_Zone):
		$Safe_Zone.queue_free()
	if $Objects/Instanced_Bombs.get_child_count() == 0:
		var bomb = load("res://Objects/Bomb.tscn").instance()
		bomb.position = $Target_Loc.position
		$Objects/Instanced_Bombs.add_child(bomb)
	else:
		var explosion = load("res://Objects/Explosion.tscn").instance()
		explosion.position = $Objects/Instanced_Bombs.get_child(0).position
		
		$Objects.add_child(explosion)
		for child in range(0,$Objects/Instanced_Bombs.get_child_count()):
			$Objects/Instanced_Bombs.get_child(child).queue_free()

func CreateWall(VECTOR2,ROTATION_DEGREES,FRAME):
	
	var tileMap = $Set/Tiles
	var tileList = tileMap.get_used_cells() 
	var tileCount = tileList.size()
	
	var wall = load("res://Objects/Walls.tscn").instance()
	wall.position = VECTOR2
	wall.set_rotation_degrees(ROTATION_DEGREES)
	wall.set_frame(FRAME)
	$Set/Instanced_Walls.add_child(wall)

func SwitchWalls():
	if is_instance_valid($Safe_Zone):
		$Safe_Zone.queue_free()
	if SWITCH_ON:
		SWITCH_ON = false
	else:
		SWITCH_ON = true
	if SWITCHES > 0:
		
		for wall in range(0,$Set/Instanced_Walls.get_child_count()):
			if $Set/Instanced_Walls.get_child(wall).get_frame() == 0:
				$Set/Instanced_Walls.get_child(wall).set_frame(1)
			else:
				$Set/Instanced_Walls.get_child(wall).set_frame(0)
		SWITCHES -= 1
	
	

func _on_To_Menu_Button_pressed():
	if not Global.get_node("Audio").MuteCheck():
		Global.get_node("Audio").get_node("ButtonClick").play(0)
		Global.get_node("Audio").get_node("Game_Play_Music_1").stop()
		Global.get_node("Audio").get_node("Game_Play_Music_2").stop()
		Global.get_node("Audio").get_node("Game_Play_Music_3").stop()
	get_tree().change_scene("res://Gameplay Scenes/Menu.tscn")


func _on_Retry_Button_pressed():
	if not Global.get_node("Audio").MuteCheck():
		Global.get_node("Audio").get_node("ButtonClick").play(0)
	get_tree().change_scene("res://Gameplay Scenes/Dungeon.tscn")



func _on_Switch_Pressed_pressed():
	SwitchWalls()


func _on_Up_Area_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed()) or (event is InputEventScreenTouch and event.is_pressed()):
		Move(UP)


func _on_Right_Area_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed()) or (event is InputEventScreenTouch and event.is_pressed()):
		Move(RIGHT)


func _on_Down_Area_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed()) or (event is InputEventScreenTouch and event.is_pressed()):
		Move(DOWN)


func _on_Left_Area_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed()) or (event is InputEventScreenTouch and event.is_pressed()):
		Move(LEFT)



func _on_Bomb_Button_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed()) or (event is InputEventScreenTouch and event.is_pressed()):
		Bomb()



func _on_Test_For_Player_body_entered(body):
	on_gate = true


func _on_Test_For_Player_body_exited(body):
	on_gate = false
