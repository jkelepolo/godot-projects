extends Node


onready var currentPlanet = "Terran Planet"
#onready var currentPlanet = rand_weighted(Global.planetWeights, 0)

var player_position = Vector2.ZERO
var NavigationNode
var biomeList = []
var biomeWeights = {}
var planetList = []
var planetWeights = {}

var chunk_render_range = 1
var tile_size = 32
var game_seed = -13
var nullTiles = []


func _ready():
	
	
	# Populate Biomes
	var ForestBiome = Biome.new()

	ForestBiome.NAME = "ForestBiome"

	ForestBiome.NewMob("BasicMob", "res://Entities/BasicMob/BasicMob.tscn", 10)
	ForestBiome.NewMob(null, null, 10)

	ForestBiome.NewForegroundTile("Tree", "res://Tiles/Tile_Scenes/ForestBiome/Tree.tscn", 1, true, [])
	ForestBiome.NewForegroundTile("ForestLog", "res://Tiles/Tile_Scenes/ForestBiome/ForestLog.tscn", 0.4,true, [])
	ForestBiome.NewForegroundTile(null, null, 11, false, [])

	ForestBiome.NewForegroundTile("GrassyGrass", "res://Tiles/Tile_Scenes/ForestBiome/GrassyGrass.tscn", 6, false, [])

	ForestBiome.mainBackGroundTile = "nullTiles"
	# ForestBiome.mainBackGroundTile = "res://Tiles/Tile_Scenes/ForestBiome/Grass.tscn"


	ForestBiome.RGB = Color(0.290196, 0.596078, 0)
	
#	biomeWeights[ForestBiome.NAME] = ForestBiome.biomeWeight
	biomeList.append(ForestBiome)

	var AshenBiome = Biome.new()
	AshenBiome.NAME = "AshenBiome"

	AshenBiome.NewMob(null, null, 10)

	AshenBiome.NewForegroundTile(null, null, 50, false, [])
	AshenBiome.NewForegroundTile("BurntTree","res://Tiles/Tile_Scenes/AshenBiome/BurntTree.tscn",3, true, [])
	AshenBiome.NewForegroundTile("ObsidianCrystal","res://Tiles/Tile_Scenes/AshenBiome/ObsidianCrystal.tscn",0.004, true, [])
	
	AshenBiome.NewForegroundTile("AshenTile2","res://Tiles/Tile_Scenes/AshenBiome/AshenTile2.tscn", 2, false, [])
	AshenBiome.NewForegroundTile("Lava","res://Tiles/Tile_Scenes/AshenBiome/Lava.tscn",3, false, ["Liquid"])
	
	# AshenBiome.mainBackGroundTile = "res://Tiles/Tile_Scenes/AshenBiome/AshenTile.tscn"
	AshenBiome.mainBackGroundTile = "nullTiles"
	
	AshenBiome.RGB = Color(0.109804, 0.078431, 0.047059)
	
#	biomeWeights[AshenBiome.NAME] = AshenBiome.biomeWeight
	biomeList.append(AshenBiome)
	
	
	# Populate Planets
	var TerranPlanet = Planet.new()
	
	TerranPlanet.NAME = "Terran Planet"
	TerranPlanet.Description = "This earth-like planet is home to mostly green landscapes and mostly docile creatures"
	TerranPlanet.maxSize = 4000
	TerranPlanet.minSize = 1000
	TerranPlanet.claimable = true
	TerranPlanet.WEIGHT = 50
	
	
	TerranPlanet.NewBiome(AshenBiome,10)
	TerranPlanet.NewBiome(ForestBiome,50)
	
	planetWeights[TerranPlanet.NAME] = TerranPlanet.WEIGHT
	planetList.append(TerranPlanet)
	
	var TestPlanet = Planet.new()
	
	TestPlanet.NAME = "Test"
	TestPlanet.Description = "This is a test planet"
	TestPlanet.maxSize = 2000
	TestPlanet.minSize = 1000
	TestPlanet.claimable = false
	TestPlanet.WEIGHT = 20
	
	TestPlanet.NewBiome(AshenBiome, 1)
	
	planetWeights[TestPlanet.NAME] = TestPlanet.WEIGHT
	planetList.append(TestPlanet)
	
	
	
	
	
	for object in planetList:
		if str(object.NAME) == str(currentPlanet):
			currentPlanet = object




func CheckChunk(X, Y, PlayerPosition):
	var player_pos = $Chunks.world_to_map(PlayerPosition)
	var chunk_list = []
	for chunk_x in range(-chunk_render_range,chunk_render_range+1):
		for chunk_y in range(-chunk_render_range,chunk_render_range+1):
			chunk_list.append(Vector2(chunk_x+player_pos.x,chunk_y+player_pos.y))
		
	if Vector2(X, Y) in chunk_list:
		return true
	else:
		return false

func GenerateChunk(X, Y):
	var SeedIteration = 0
	var chunk_width = $Chunks.cell_size.x/tile_size
	var chunk_height = $Chunks.cell_size.y/tile_size
	var scale = Vector2(chunk_width,chunk_height)
	var key = Vector2(X,Y)
	var region = make_key($Regions.world_to_map($Chunks.map_to_world(key)))
	var invalidTiles = []
	var EXACT_POSITION = $Chunks.map_to_world(key)
	var liquid = [Vector2(tile_size, 0),Vector2(-tile_size, 0),Vector2(0, tile_size),Vector2(0, -tile_size)]
	var chunk_data = {}
	
	var SEED = make_key(key)
	var rng = RandomNumberGenerator.new()
	rng.seed = SEED
	
	var biome = str(rand_weighted(currentPlanet.biomeWeight,region))
	
	
	#Find biome node
	for object in currentPlanet.biomeList:
		if str(object.NAME) == str(biome):
			biome = object
	
	chunk_data["nullTiles"] = []
	chunk_data["RGB"] = biome.RGB
	chunk_data["Biome"] = biome.NAME
	chunk_data["Planet"] = currentPlanet.NAME
	chunk_data["BGTile"] = biome.mainBackGroundTile
	chunk_data["EXACT_POSITION"] = EXACT_POSITION
	chunk_data[biome.mainBackGroundTile] = []
	
	var empty_data = chunk_data
	# Generate the chunk by iterating through each possible position and generating according to the rng seed
	for row in range(chunk_width):
		for collumn in range(chunk_height):
			SeedIteration += chunk_width + chunk_height
			var foreGroundTile = rand_weighted(biome.foreGroundTiles, SEED+SeedIteration)
			
			if biome.mainBackGroundTile != "Default":
				chunk_data[biome.mainBackGroundTile].append(EXACT_POSITION + Vector2(row*tile_size,collumn*tile_size))
			
			if foreGroundTile != null:
				if not biome.foreGroundPaths[foreGroundTile] in chunk_data:
					chunk_data[biome.foreGroundPaths[foreGroundTile]] = []
				
				chunk_data[biome.foreGroundPaths[foreGroundTile]].append(EXACT_POSITION + Vector2(row*tile_size,collumn*tile_size))


			elif foreGroundTile == null:
				chunk_data["nullTiles"].append(EXACT_POSITION + Vector2(row*tile_size,collumn*tile_size))
				
	if X < 100 and Y < 100 and X > -100 and Y > -100:
		return chunk_data
	else:
		return chunk_data["EXACT_POSITION"]


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
	
func make_key(KEY: Vector2):
	var sum = KEY.x + KEY.y * 29
	var makekey = str(game_seed)+str(sum)
	
	return int(makekey)
