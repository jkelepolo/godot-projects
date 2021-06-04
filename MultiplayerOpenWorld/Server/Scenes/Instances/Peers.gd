extends Node
var frame = 0
func _process(delta):
	
	for player in get_owner().get_node("Active").get_children():
		SortData(player)
	


func SendOutData(Data, ReceiverID):
	get_owner().rpc_unreliable_id(int(ReceiverID), "ReturnPeerData", Data)

func SortData(Sender):
	for Receiver in get_owner().get_node("Active").get_children():
#		if Receiver.name != Sender.name:
		var Data = {}
		var chunk = get_owner().get_node("Generation/Chunks").world_to_map(Vector2(Sender.X, Sender.Y))
		if str(Sender.CurrentLocation) == str(Receiver.CurrentLocation) and get_owner().get_node("Generation").CheckChunk(chunk.x, chunk.y, Vector2(Receiver.X, Receiver.Y)):
			Data["Coordinates"] = Vector2(Sender.X, Sender.Y)
			Data["Equipped"] = Sender.Equipped
			Data["State"] = Sender.STATE
			Data["Name"] = Sender.NickName
			Data["Unix"] = OS.get_unix_time()
			Data["ID"] = Sender.name
			Data["Quit"] = false
			Data["isMob"] = Sender.isMob
			
			if not Sender.name in get_owner().peers:
				Data["Quit"] = true
				if is_instance_valid(Sender):
					Sender.queue_free()
					
			if Sender.AdminSettings["Invisible"] and Sender.AdminLevel <= Receiver.AdminLevel:
				SendOutData(Data, Receiver.name)
			elif not Sender.AdminSettings["Invisible"]:
				SendOutData(Data, Receiver.name)
				
	if not Sender.name in get_owner().peers and is_instance_valid(Sender):
		Sender.queue_free()

