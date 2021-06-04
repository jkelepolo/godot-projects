extends Node
class_name Biomes
var NAME = ""
var mainBackGroundTile = ""
var RGB = Color(1,1,1,1)
var foreGroundTiles = {}
var foreGroundPaths = {}
var mobs = {}
var mobPaths = {}
var size = Vector2.ZERO

func NewMob(NAME ,PATH, WEIGHT):
	mobs[NAME] = WEIGHT
	mobPaths[NAME] = PATH

func NewForegroundTile(NAME, PATH, WEIGHT, YSORT):
	if YSORT:
		foreGroundTiles["y_"+NAME] = WEIGHT
		foreGroundPaths["y_"+NAME] = PATH
	else:
		foreGroundTiles[NAME] = WEIGHT
		foreGroundPaths[NAME] = PATH

#func NewBackgroundTile(NAME, PATH, WEIGHT, YSORT):
#	backGroundTiles[NAME] = WEIGHT
#	backGroundPaths[NAME] = PATH
