extends Node

var network = NetworkedMultiplayerENet.new()
var port = 2020
var max_players = 100

var peers = {}

onready var publicVariables = {"PlayerSpeed": 100, "Seed": $Generation.game_seed}

func _ready():
	$Data.LoadPlayerInfo()
	$Data.SavePlayerInfo()
	$Data.call_deferred("ArchivePlayers")
	
	
	StartServer()

func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(player_id):
	
	
	
	peers[str(player_id)] = ""
	print("User " + str(player_id) + " Connected")
	
func _Peer_Disconnected(player_id):
	if peers[str(player_id)] != "":
		$Data.SavePlayerData(player_id)
		$Data.SavePlayerInfo()
	peers.erase(str(player_id))
	
	
	print("User " + str(player_id) + " Disconnected")


remote func GenerateChunk(X, Y, PlayerPosition):
	
	var player_id = get_tree().get_rpc_sender_id()
	
	if $Anticheat.PlayerCheck(PlayerPosition, player_id):
		if $Generation.CheckChunk(X, Y, PlayerPosition):
			var return_data = $Generation.GenerateChunk(X, Y)
			rpc_id(player_id, "ReturnChunk", return_data)


remote func SetPlayerPosition(PlayerPosition):
	var player_id = get_tree().get_rpc_sender_id()
	
	$Active.get_node(str(player_id)).temp["move_packets_per_second"] += 1
	if OS.get_unix_time() > $Active.get_node(str(player_id)).temp["move_packet_unix"]:
		$Active.get_node(str(player_id)).temp["move_packet_unix"] = OS.get_unix_time()
		$Active.get_node(str(player_id)).temp["move_packets_per_second"] = 0
	
	if $Active.get_node(str(player_id)).temp["move_packets_per_second"] <= 55:
		$Anticheat.PlayerCheck(PlayerPosition, player_id)


remote func CheckUsername(Name, instance_id):
	var player_id = get_tree().get_rpc_sender_id()
	var username = Name.to_lower()
	var validChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
	
	
	for chr in str(Name):
		if not chr in validChars:
			rpc_id(player_id, "ReturnCheckUsername", false, instance_id)
			return
	
	if str(username) in $Data.PlayerInfo or username in $Data.ArchivedList:
		rpc_id(player_id, "ReturnCheckUsername", false, instance_id)
	else:
		rpc_id(player_id, "ReturnCheckUsername", true, instance_id)


remote func RegisterPlayer(USER, PASS):
	var validChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
	var player_id = get_tree().get_rpc_sender_id()
	var username = str(USER).to_lower()
	var password = str(PASS)
	# Username Checks
	if str(username) in $Data.PlayerInfo or username in $Data.ArchivedList:
		rpc_id(player_id, "RegisterStatus", "Username already taken!")
		return
	
	if len(str(username)) < 3:
		rpc_id(player_id, "RegisterStatus", "Username must be at least 3 characters!")
		return
	
	if len(str(username)) > 16:
		rpc_id(player_id, "RegisterStatus", "Username must be less than or equal to 16 characters!")
		return
	
	for chr in str(USER):
		if not chr in validChars:
			rpc_id(player_id, "RegisterStatus", "Please use valid characters!")
			return
	
	if len(password) < 5:
		rpc_id(player_id, "RegisterStatus", "Password must be at least 5 characters!")
		return
	
	rpc_id(player_id, "RegisterStatus", "Successfully registered " + str(USER) + "!")
	
	
	$Data.PlayerInfo[username] = {}
	$Data.PlayerInfo[username]["Unix"] = OS.get_unix_time()
	$Data.PlayerInfo[username]["Salt"] = $Data.GenerateSalt()
	$Data.PlayerInfo[username]["NickName"] = str(USER)
	$Data.PlayerInfo[username]["Password"] = $Data.GenerateHashedPassword(password, $Data.PlayerInfo[username]["Salt"])
	$Data.SavePlayerInfo()

remote func LoginPlayer(USER, PASS):
	
	var player_id = get_tree().get_rpc_sender_id()
	var username = str(USER).to_lower()
	var password = str(PASS)
	var archived = false
	
	if username in $Data.ArchivedList:
		rpc_id(player_id, "LoginStatus", "Unarchiving old player data! Please wait..", false, null, null)
		$Data.PlayerInfo[username] = $Data.ArchivedPlayers[username]
		$Data.ArchivedList.erase(username)
		$Data.ArchivedPlayers.erase(username)
		archived = true

		
	if str(username) in $Data.PlayerInfo:
		if $Data.GenerateHashedPassword(password, $Data.PlayerInfo[username]["Salt"]) != $Data.PlayerInfo[str(username)]["Password"]:
			rpc_id(player_id, "LoginStatus", "Incorrect username or password!", false, null, null)
			return
	
	elif not username in $Data.PlayerInfo:
		rpc_id(player_id, "LoginStatus", "Incorrect username or password!", false, null, null)
		return
	
	if "Banned" in $Data.PlayerInfo[username]:
		if $Data.PlayerInfo[username]["Banned"] == true:
			rpc_id(player_id, "LoginStatus", $Data.PlayerInfo[username]["NickName"] + " is banned!", false, null, null)
	
	for peer in peers:
		if peers[peer] == username:
			rpc_id(player_id, "LoginStatus", $Data.PlayerInfo[username]["NickName"] + " is already logged in! kicking them off...", false, null, null)
			network.disconnect_peer(int(peer))
			
	if archived:
		$Data.SaveGeneralData("PlayerData","Archived.json", $Data.ArchivedPlayers)
		$Data.SaveGeneralData("PlayerData","ArchivedList.json", $Data.ArchivedList)
	
	$Data.PlayerInfo[username]["Unix"] = OS.get_unix_time()
	
	peers[str(player_id)] = username
	
	var Player = load("res://Scenes/Containers/PlayerContainer.tscn").instance()
	Player.name = str(player_id)
	$Active.add_child(Player, true)
	
	$Data.LoadPlayerData(player_id)
	
	$Active.get_node(str(player_id)).NickName = $Data.PlayerInfo[username]["NickName"]
	
	var last_position = Vector2($Active.get_node(str(player_id)).X, $Active.get_node(str(player_id)).Y)
	
	rpc_id(player_id, "LoginStatus", "Succesfully logged in as " + $Data.PlayerInfo[username]["NickName"] + "!", true, last_position, $Data.PlayerInfo[username]["NickName"])

remote func Chat(Message, Channel):
	var player_id = get_tree().get_rpc_sender_id()
	$WorldState/Chat.Chat(Message, Channel, player_id)




