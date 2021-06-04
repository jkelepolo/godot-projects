extends Node
class_name Worlds

var NAME = ""
var Description = ""
var maxSize = 0
var minSize = 0
var biomeList = []
var biomeWeight = {}
var WEIGHT = 0
var claimable = true

var PATH = ""

func NewBiome(BIOME, WEIGHT):
	biomeList.append(BIOME)
	biomeWeight[BIOME.NAME] = WEIGHT
	
