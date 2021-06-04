extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 2020
var connected = false
var message = ""
var LoggedIn = false
var canRegister = false
var MultiThreading = true
var Nick = ""
var ChatID
var Buffer = {}
var MobBuffer = {}




func ConnectToServer():
	network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("server_disconnected", self, "_server_disconnected")
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _process(delta):
	pass

func _server_disconnected():
	LogOut()
	print("Server disconnected")

func _OnConnectionFailed():
	network = null
	ConnectToServer()
	print("Failed to connect")
	

func _OnConnectionSucceeded():
	connected = true
	print("Succesfully connected")

func Register(USER, PASS):
	rpc_id(1, "RegisterPlayer", USER, PASS.sha256_text())
	

func Login(USER, PASS):
	rpc_id(1, "LoginPlayer", USER, PASS.sha256_text())

func LogOut():
	connected = false
	network = null
	message = ""
	get_tree().change_scene("res://Scenes/Menu.tscn")

remote func LoginStatus(Message, BOOL, Position, Name):
	Global.player_position = Position
	LoggedIn = BOOL
	message = Message
	if LoggedIn:
		Nick = Name

remote func RegisterStatus(Message):
	message = Message

func FetchChunk(X, Y, PlayerPosition):
	rpc_id(1,"GenerateChunk", X, Y, PlayerPosition)
	

func SendPlayerPosition(PlayerPosition):
	rpc_unreliable_id(1, "SetPlayerPosition", PlayerPosition)

func FetchPlayerAttribute(attribute, requester):
	rpc_id(1,"FetchPlayerAttribute", attribute, requester )

remote func ReturnChunk(return_data):
	instance_from_id(Global.GameNode).ReturnChunk(return_data)
	


func CheckUsername(Name, instance_id):
	rpc_id(1, "CheckUsername", Name, instance_id)

remote func ReturnCheckUsername(isValid, instance_id):
	if isValid:
		canRegister == true
		instance_from_id(instance_id).text = "Available!"
	else:
		canRegister == false
		instance_from_id(instance_id).text = ""

remote func ReturnPeerData(Data):
	Buffer[Data["ID"]] = Data
	
remote func ReturnMobData(Data):
	MobBuffer[Data["ID"]] = Data

func Chat(Message, Channel):
	rpc_id(1, "Chat", Message, Channel)
	
remote func ReturnChat(Message, Channel):
	instance_from_id(ChatID).ReturnChat(Message, Channel)
	
remote func ChangePosition(X, Y):
	instance_from_id(Global.PLAYER).global_position = Vector2(X,Y)
