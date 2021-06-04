extends Node

var temp = {
	"isTeleporting":false,
	"TargetLocation":Vector2(0,0),
	"move_packets_per_second":0,
	"move_packet_unix":0,
}

var InfluencerCode = null
var isInfluencer = false
var isMob = false

var NickName = ""
var AdminLevel = 0
var AdminSettings = {
	"Invisible": false,
	"NoClip": false,
}
var STATE = 0 
var current_level = 0
var xp = 0

var credits = 0

var history_queue = []
var discipline_history = []
var isBanned = false
var BanDuration = 0

var isMuted = false
var MuteDuration = 0

var CurrentLocation = {"System":"","Planet":""}
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
	
