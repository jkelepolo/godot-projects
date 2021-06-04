extends Node

class_name Biome

var NAME = ""
var mainBackGroundTile = ""
var RGB = Color(1,1,1,1)
var foreGroundTiles = {}
var foreGroundPaths = {}
var foreGroundAttributes = {}
var mobs = {}
var mobPaths = {}
var size = Vector2.ZERO


func NewMob(NAME ,PATH, WEIGHT):
	mobs[NAME] = WEIGHT
	mobPaths[NAME] = PATH

# Attributes include, ["Liquid"]
func NewForegroundTile(NAME, PATH, WEIGHT, YSORT, ATTRIBUTES):
	if YSORT:
		foreGroundTiles["y_"+NAME] = WEIGHT
		foreGroundPaths["y_"+NAME] = "y_"+PATH
	else:
		foreGroundTiles[NAME] = WEIGHT
		foreGroundPaths[NAME] = PATH
		
	foreGroundAttributes = ATTRIBUTES
	
