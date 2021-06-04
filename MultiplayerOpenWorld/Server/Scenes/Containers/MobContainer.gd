extends Node

var isMob = true
var Name = ""
var brain = ""

var ID = ""
var HitBox = Vector2.ZERO

var CurrentLocation = {"System":"","Planet":""}
var STATE = 0 
var X = 0
var Y = 0
var Inventory = []
var Ships = []
var Equipped = {
	
	"Head": 0, 
	"Chest": 0, 
	"Leggings": 0,
	"Boots": 0,
	"Back": 0,
	"Primary":0,
	"Secondary":0,
	"Ship":0
	
	}

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var ID = str(rng.randf()).sha256_text()
