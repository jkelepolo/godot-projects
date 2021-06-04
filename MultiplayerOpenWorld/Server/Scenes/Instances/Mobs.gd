extends Node
var frame = 0
func _process(delta):
	
	for mob in get_owner().get_node("ActiveMobs").get_children():
		SortData(mob)
	


func SendOutData(Data, ReceiverID):
	get_owner().rpc_unreliable_id(int(ReceiverID), "ReturnMobData", Data)

func SortData(Sender):
	for Receiver in get_owner().get_node("Active").get_children():
#		if Receiver.name != Sender.name:
		var Data = {}
		var chunk = get_owner().get_node("Generation/Chunks").world_to_map(Vector2(Sender.X, Sender.Y))
		if str(Sender.CurrentLocation) == str(Receiver.CurrentLocation) and get_owner().get_node("Generation").CheckChunk(chunk.x, chunk.y, Vector2(Receiver.X, Receiver.Y)):
			Data["Coordinates"] = Vector2(Sender.X, Sender.Y)
			Data["Equipped"] = Sender.Equipped
			Data["State"] = Sender.STATE
			Data["Name"] = Sender.Name
			Data["Unix"] = OS.get_unix_time()
			Data["Quit"] = false
			Data["isMob"] = Sender.isMob
			Data["ID"] = Sender.ID
			
			SendOutData(Data, Receiver.name)
			

