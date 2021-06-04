extends Node

onready var ArchivedList = LoadGeneralData("PlayerData", "ArchivedList.json")
onready var ArchivedPlayers = LoadGeneralData("PlayerData","Archived.json")

var prefix = "res://"
var PlayerInfoDir = "res://PlayerData"
var PlayerInfoPath = "res://PlayerData/PlayerInfo.json"
var PlayerInfo = {}

func ArchivePlayers():
	
	var Names = []
	var current_time = OS.get_unix_time()
	for NAME in PlayerInfo:
		Names.append(NAME)
	for player in Names:
		if true:
			var player_time = PlayerInfo[player]["Unix"]
			var difference_days = (((current_time - player_time)/60)/60)/24
#			var difference_days = (current_time - player_time)/60
#			print(difference_days)
			if difference_days >= 30:
				ArchivedList[player] = ""
				ArchivedPlayers[player] = PlayerInfo[player]
				
				SaveGeneralData("PlayerData","Archived.json", ArchivedPlayers)
				SaveGeneralData("PlayerData","ArchivedList.json", ArchivedList)
				
				PlayerInfo.erase(player)
				SavePlayerInfo()
				print("Archived " + player)
	

func LoadGeneralData(DataPath, DataName):
	var file = File.new()
	
	if not file.file_exists(DataPath + "/" + DataName):
		SaveGeneralData(DataPath, DataName, {})
	
	file.open(prefix + DataPath + "/" + DataName, file.READ)
	
	var text = file.get_as_text()
	
	var Data = parse_json(text)
	
	file.close()
	
	return Data


func SaveGeneralData(DataPath, DataName, Data):
	var dir = Directory.new()
	var file = File.new()
	
	if not dir.dir_exists(DataPath):
		dir.make_dir_recursive(DataPath)
		
	
	file.open(prefix+DataPath + "/" + DataName, File.WRITE)
	
	file.store_line(to_json(Data))
	
	file.close()

func LoadPlayerInfo():
	var file = File.new()
	
	if not file.file_exists(PlayerInfoPath):
		return
	
	file.open(PlayerInfoPath, file.READ)
	
	var text = file.get_as_text()
	
	PlayerInfo = parse_json(text)
	
	file.close()

func SavePlayerInfo():
	var dir = Directory.new()
	var file = File.new()
	
	if not dir.dir_exists(PlayerInfoDir):
		dir.make_dir_recursive(PlayerInfoDir)
		
	
	file.open(PlayerInfoPath, File.WRITE)
	
	file.store_line(to_json(PlayerInfo))
	
	file.close()

func SavePlayerData(player_id):
	var DATA = {}
	var isVar = false
	for property in get_owner().get_node("Active/"+str(player_id)).get_property_list():
		if isVar and not property["name"] == "temp":
		
			DATA[property["name"]] = get_owner().get_node("Active/"+str(player_id)).get(property["name"])
		elif property["name"] == "Script Variables":
			isVar = true
	SaveGeneralData("PlayerData/Players", get_owner().peers[str(player_id)]+".json", DATA)

func LoadPlayerData(player_id):
	var DATA = LoadGeneralData("PlayerData/Players", get_owner().peers[str(player_id)]+".json")
	
	var isVar = false
	for property in get_owner().get_node("Active/"+str(player_id)).get_property_list():
		if isVar:
			if property["name"] in DATA:
				get_owner().get_node("Active/"+str(player_id)).set(property["name"], DATA[property["name"]])
		elif property["name"] == "Script Variables":
			isVar = true
			

func isOnline(player):
	for peer in get_owner().peers:
		if get_owner().peers[peer] == player.to_lower():
			return {"Bool":true, "Peer":peer}
	return {"Bool":false}

func GenerateSalt():
	randomize()
	var salt = str(randi()).sha256_text()
#	print("Salt: " + salt)
	return salt

func GenerateHashedPassword(password, salt):
	var hashed_password = password
	var rounds = pow(2,9)
#	print("Password as input: " + hashed_password)
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	return hashed_password

func StringToVector(Vector):
	print(Vector)
	if typeof(Vector) == TYPE_STRING:
		var STR = ""
		for item in Vector:
			if item != "(" or item != ")":
				STR = STR + item
		
		STR = STR.split(',')
		
		print(STR)
		return Vector2(float(STR[0]), float(STR[1]))
	elif typeof(Vector) == TYPE_VECTOR2:
		return Vector

