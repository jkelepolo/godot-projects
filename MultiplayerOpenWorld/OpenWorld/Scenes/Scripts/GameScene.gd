extends Node2D

export var debug = true
export var show_borders = true
export var camera_zoomed_out = true
export var chunk_refresh_rate = 5
export var StarterChunk = Vector2(0,0)

onready var chunk_grid = $Chunks/Chunk_Grid
onready var player = $Chunks/Loaded/YSort/Player
onready var Ysort = $Chunks/Loaded/YSort
onready var current_chunk = chunk_grid.world_to_map(player.global_position)
onready var chunk_render_range = 1
#onready var currentPlanet = rand_weighted(Global.planetWeights, 0)
onready var currentPlanet = ""

var game_seed = -6
var tile_size = 32
var active_chunk_list = []
var chunks_to_load = []
var chunks_to_free = []
var nullTiles = []
var frames = 0



func _ready():
	Global.PLAYER = player.get_instance_id()
	player.position = Global.player_position
	
	# Generate chunks and paths when Position data is received
	chunk_refresh()
	path_refresh()
	
	generate_chunk(StarterChunk.x, StarterChunk.y)
	
	for coordinate in nullTiles:
		if chunk_grid.world_to_map(coordinate) == current_chunk:
			player.global_position = coordinate
	
	for object in Global.planetList:
		if str(object.NAME) == str(currentPlanet):
			currentPlanet = object
	
	# Making the navigation node global and accessable by other children nodes, including scenes
	Global.NavigationNode = get_node("Navigation")
	Global.GameNode = get_instance_id()
#	print(Global.GameNode)
	
	
	if camera_zoomed_out:
		$Chunks/Loaded/YSort/Player/Camera.set_zoom(Vector2(1,1))
	
	if debug:
		pass
	else:
		$CanvasLayer/Chunk_Pos.queue_free()
	
	
	
	



func _process(delta):
	if Server.connected == false:
		Server.LogOut()
	else:
		for Peer in Server.Buffer:
			if Server.Buffer[Peer]["Name"] != Server.Nick:
				if not is_instance_valid(Ysort.get_node(Peer)):
					var newPeer = load("res://Entities/Peer/Peer.tscn").instance()
					newPeer.global_position = Server.Buffer[Peer]["Coordinates"]
					newPeer.name = Peer
					
					Ysort.add_child(newPeer, true)
		
		for Mob in Server.MobBuffer:
			if not is_instance_valid(Ysort.get_node(Mob)):
				var newMob = load("")
	
	
	$Navigation/map.set_cellv($Navigation/map.world_to_map(player.global_position+Vector2(16,16)),0)
	

	Server.SendPlayerPosition(player.global_position)
	
	if frames >= 1000:
		frames = 0
	frames += 1
	
	# Makes the player nodes position always accessable by keeping it in the Global singleton
	Global.player_position = player.global_position
	
	
	chunk_process()
	
	if debug:
	

		$CanvasLayer/Chunk_Pos.text = "Planet Type: " + currentPlanet + "\nTile Count: "+ str($Chunks/Loaded.get_child_count()) + "\nChunk: " + str(chunk_grid.world_to_map(player.global_position)) + "\nCoordinates: " + str($Navigation/map.world_to_map(player.global_position))

	# Player enters a new chunk
	if current_chunk != chunk_grid.world_to_map(player.global_position):
		call_deferred("chunk_refresh")
		call_deferred("path_refresh")
		
		# resetting the players current chunk
		current_chunk = chunk_grid.world_to_map(player.global_position)
		
	
#	# Input
#	if Input.is_action_just_released("Scroll_Down"):
#		if $Chunks/Loaded/YSort/Player/Camera.zoom < Vector2(0.38, 0.38):
#			$Chunks/Loaded/YSort/Player/Camera.set_zoom($Chunks/Loaded/YSort/Player/Camera.zoom + Vector2(0.01, 0.01))
##			print($Chunks/Loaded/YSort/Player/Camera.zoom)
#
#	if Input.is_action_just_released("Scroll_Up"):
#		if $Chunks/Loaded/YSort/Player/Camera.zoom > Vector2(0.05,0.05):
#			$Chunks/Loaded/YSort/Player/Camera.set_zoom($Chunks/Loaded/YSort/Player/Camera.zoom - Vector2(0.01, 0.01))
##			print($Chunks/Loaded/YSort/Player/Camera.zoom)


	if Input.is_action_just_pressed("ui_select"):
		
#		for i in range(9):
#			Server.SendPlayerPosition(player.global_position + Vector2(10,0))
#			player.global_position += Vector2(10,0)
#		player.global_position = get_global_mouse_position()
		pass



func chunk_refresh():
	active_chunk_list = []
	chunks_to_load = []
	chunks_to_free = []
	nullTiles = []
	var loaded_chunks = []
	var player_pos = chunk_grid.world_to_map(player.global_position)
		
	# Creating a list of possible chunks that can be loaded based on the render range
	for chunk_x in range(-chunk_render_range,chunk_render_range+1):
		for chunk_y in range(-chunk_render_range,chunk_render_range+1):
			active_chunk_list.append(Vector2(chunk_x+player_pos.x,chunk_y+player_pos.y))
#	print(active_chunk_list)
	
	# Checking if any current chunks are not in the possible chunks list and then adding them to the chunks_to_free list
	for object in $Chunks/Loaded.get_children():
		if not chunk_grid.world_to_map(object.global_position) in active_chunk_list:
			if not chunk_grid.world_to_map(object.global_position) in chunks_to_free:
				chunks_to_free.append(chunk_grid.world_to_map(object.global_position))
#			object.call_deferred('free')
		elif object != Ysort:
			loaded_chunks.append(chunk_grid.world_to_map(object.global_position))
			
	# Checking if any current chunks are not loaded add them to the chunks_to_load list
	for chunk in active_chunk_list:
		if not chunk in loaded_chunks:
			chunks_to_load.append(chunk)
	

func ReturnChunk(DATA):
	if typeof(DATA) == TYPE_DICTIONARY:
		currentPlanet = DATA["Planet"]
		var chunk_width = chunk_grid.cell_size.x/tile_size
		var chunk_height = chunk_grid.cell_size.y/tile_size
		
		var scale = Vector2(chunk_width,chunk_height)
		
		var exclusions = ["nullTiles", "RGB", "Biome", "Planet", "BGTile", "EXACT_POSITION"]
		
		for tileType in DATA:
	#		print(tileType)
			if not tileType in exclusions:
				for tile in DATA[tileType]:
					if tileType.left(2) == "y_":
						var newTile = load(tileType.right(2)).instance()
						newTile.global_position = tile 
						Ysort.add_child(newTile)
					else:
						var newTile = load(tileType).instance()
						newTile.global_position = tile
						$Chunks/Loaded.add_child(newTile)
		$Chunks/Loaded.move_child(Ysort,$Chunks/Loaded.get_child_count())
		
		var ChunkBG = load("res://Tiles/Tile_Scenes/ChunkBG.tscn").instance()
		ChunkBG.global_position = DATA["EXACT_POSITION"]
		ChunkBG.set_scale(scale + Vector2(0.1, 0.1))
		ChunkBG.self_modulate = DATA["RGB"]

		$Chunks/Loaded.add_child(ChunkBG)
		$Chunks/Loaded.move_child(ChunkBG,0)
		
		if show_borders:
			var Chunk_Border = load("res://Tiles/Tile_Scenes/Chunk_Border.tscn").instance()
			Chunk_Border.global_position = DATA["EXACT_POSITION"]
			Chunk_Border.set_scale(scale)

			$Chunks/Loaded.add_child(Chunk_Border)
	else:
		var chunk_width = chunk_grid.cell_size.x/tile_size
		var chunk_height = chunk_grid.cell_size.y/tile_size
		
		var scale = Vector2(chunk_width,chunk_height)
		
		var boundary = load("res://Tiles/Tile_Scenes/Boundary.tscn").instance()
		boundary.global_position = DATA + Vector2(128,128)
		boundary.set_scale(scale*1.6)
		$Chunks/Loaded.add_child(boundary)


func generate_chunk(X,Y):
	var SeedIteration = 0
	var chunk_width = chunk_grid.cell_size.x/tile_size
	var chunk_height = chunk_grid.cell_size.y/tile_size
	var scale = Vector2(chunk_width,chunk_height)
	var key = Vector2(X,Y)
	var region = make_key($Chunks/Regions.world_to_map($Chunks/Chunk_Grid.map_to_world(key)))
	var SEED = make_key(key)
	var rng = RandomNumberGenerator.new()
	rng.seed = SEED
	
	Server.FetchChunk(X,Y, Global.player_position)
	
	
func free_chunk(CHUNK):
	for object in $Chunks/Loaded.get_children():
		if chunk_grid.world_to_map(object.global_position) == CHUNK and object != Ysort:
			object.call_deferred("free")
	for object in Ysort.get_children():
		if chunk_grid.world_to_map(object.global_position) == CHUNK and object != player:
			object.call_deferred("free")


func path_refresh():
	var nav = $Navigation/map
	for cell in $Navigation/map.get_used_cells():
		nav.set_cellv(cell,-1)
	

func make_key(KEY: Vector2):
	var sum = KEY.x + KEY.y * 29
	var makekey = str(game_seed)+str(sum)
	
	return int(makekey)

func chunk_process():
		# Checks if there are any chunks to unload and then unloading one per frame
	if len(chunks_to_free) != 0 and frames % chunk_refresh_rate == 0:
		call_deferred("free_chunk", chunks_to_free[0])
		chunks_to_free.remove(0)
		path_refresh()
	# After all chunks are loaded generate any chunks that are needing to be loaded
	elif len(chunks_to_load) != 0 and frames % chunk_refresh_rate == 0:
		var X = chunks_to_load[0].x
		var Y = chunks_to_load[0].y 
		chunks_to_load.remove(0)
		call_deferred("generate_chunk", X, Y)


func rand_weighted(options, randseed):
	var rng = RandomNumberGenerator.new()
	rng.seed = randseed
	var total_weight = 0
	
	for option in options:
		total_weight += options[option]
		
	var rand = rng.randf() * total_weight
	
	for option in options:
		rand -= options[option]
		if rand < 0:
			return option
	return null
