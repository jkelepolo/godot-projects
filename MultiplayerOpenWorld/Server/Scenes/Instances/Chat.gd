extends Node


func Chat(Message, Channel, player_id):
	
	var ValidChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 _+=[]{}\\/|'<>,.`~!@#$%^&*()-?\";:"
	var Spaces = 0

	if len(Message) > 100:
		get_owner().rpc_id(player_id,"ReturnChat", "Message too long!", "Server")
		return

	if Message == "" or Message == " ":
		get_owner().rpc_id(player_id,"ReturnChat", "Message is empty!", "Server")
		return

	for chr in Message:

		if not chr in ValidChars:
			get_owner().rpc_id(player_id,"ReturnChat", "Invalid Characters!", "Server")
			return

		if chr == " " or chr == "":
			Spaces += 1

	if Spaces >= len(Message)/2:
		get_owner().rpc_id(player_id,"ReturnChat", "Too many spaces!", "Server")
		return
	
	if not Command(Message, player_id):
		Message = get_owner().get_node("Active").get_node(str(player_id)).NickName + ": " + Message
		if Channel == "Global":
			get_owner().rpc("ReturnChat", Message, Channel)
		else:
			for Receiver in get_owner().get_node("Active").get_children():
				var Sender = get_owner().get_node("Active").get_node(str(player_id))
				var chunk = get_owner().get_node("Generation/Chunks").world_to_map(Vector2(Sender.X, Sender.Y))
				if Channel == "Local":
					if str(Sender.CurrentLocation) == str(Receiver.CurrentLocation) and get_parent().get_node("Generation").CheckChunk(chunk.x, chunk.y, Vector2(Receiver.X, Receiver.Y)):
						get_owner().rpc_id(int(Receiver.name), "ReturnChat", Message, Channel)
				elif Channel == "World":
					if str(Sender.CurrentLocation) == str(Receiver.CurrentLocation):
						get_owner().rpc_id(int(Receiver.name), "ReturnChat", Message, Channel)

func Command(Message, player_id):
	var Sender = get_owner().get_node("Active").get_node(str(player_id))
	var AdminLevel = get_owner().get_node("Active").get_node(str(player_id)).AdminLevel
	var Command = Message.split(" ")
	var used = false
	
	if Message.left(1) != '/':
		return false
	
	if AdminLevel >= 999:
		if Command[0] == '/adminlevel':
			var file = File.new()
			
			if len(Command) > 2:
				if file.file_exists("PlayerData/Players/" + Command[1].to_lower() + ".json"):
					var peerInfo = get_owner().get_node("Data").isOnline(Command[1])
					
					if peerInfo["Bool"]:
						get_owner().get_node("Active").get_node(peerInfo["Peer"]).AdminLevel = int(Command[2])
						get_owner().get_node("Data").SavePlayerData(peerInfo["Peer"])
						
					if not get_owner().get_node("Data").isOnline(Command[1])["Bool"]:
						var data = get_owner().get_node("Data").LoadGeneralData("PlayerData/Players/", Command[1].to_lower() + ".json")
						data["AdminLevel"] = int(Command[2])
						get_owner().get_node("Data").SaveGeneralData("PlayerData/Players/", Command[1].to_lower() + ".json", data)
					get_owner().rpc_id(int(Sender.name),"ReturnChat", "Set " + str(Command[1]) + "'s admin level to " + Command[2], "Server")
				else:
					get_owner().rpc_id(int(Sender.name),"ReturnChat", "Player doesn't exist!", "Server")
			else:
				get_owner().rpc_id(int(Sender.name),"ReturnChat", "Missing argument /adminlevel >>[Name]<< >>[Level]<<", "Server")
			used = true
			
		elif Command[0] == '/help':
			get_owner().rpc_id(int(Sender.name),"ReturnChat", "Developer Commands:\n /adminlevel [Name] [Level]", "Server")
			used = true
	
	if AdminLevel >= 10:
		if Command[0] == '/help':
			get_owner().rpc_id(int(Sender.name),"ReturnChat", "Moderator Commands:\n /nick [Name]\n /invisible\n /warp [Name]\n /summon [Name]\n /teleport [Chunk_X] [Chunk_Y]\n /kick [Name]\n /warn [Name] [Message]", "Server")
			used = true
		
		elif Command[0] == '/nick':
			if len(Command) > 1:
				Sender.NickName = Command[1]
				get_owner().rpc_id(int(Sender.name),"ReturnChat", "Nickname set to: " + Command[1], "Server")
			else:
				get_owner().rpc_id(int(Sender.name),"ReturnChat", "Missing argument /nick >>[Name]<<", "Server")
			used = true
		
		elif Command[0] == '/invisible':
			if Sender.AdminSettings["Invisible"]:
				get_owner().rpc_id(int(Sender.name),"ReturnChat", "You are now visible!", "Server")
				Sender.AdminSettings["Invisible"] = false
			else:
				get_owner().rpc_id(int(Sender.name),"ReturnChat", "You are no longer visible!", "Server")
				Sender.AdminSettings["Invisible"] = true
			used = true
		
		elif Command[0] == '/warp':
			used = true
			if len(Command) > 1:
				var peerInfo = get_owner().get_node("Data").isOnline(Command[1])
				
				if peerInfo["Bool"]:
					var Peer = get_owner().get_node("Active").get_node(peerInfo["Peer"])
					Sender.X = Peer.X
					Sender.Y = Peer.Y
					Sender.temp["isTeleporting"] = true
					Sender.CurrentLocation = Peer.CurrentLocation
					Sender.temp["TargetLocation"] = Vector2(Peer.X, Peer.Y)
					get_owner().rpc_id(int(Sender.name),"ChangePosition", Sender.X, Sender.Y)
					get_owner().rpc_id(int(Sender.name),"ReturnChat", "You have warped to " + Command[1] + "!", "Server")
				else:
					get_owner().rpc_id(int(Sender.name),"ReturnChat", Command[1] + " is not online!", "Server")
			else:
				get_owner().rpc_id(int(Sender.name),"ReturnChat", "Missing argument /warp >>[Name]<<", "Server")
		
		elif Command[0] == '/summon':
			used = true
			if len(Command) > 1:
				var peerInfo = get_owner().get_node("Data").isOnline(Command[1])
				
				if peerInfo["Bool"]:
					var Peer = get_owner().get_node("Active").get_node(peerInfo["Peer"])
					Peer.X = Sender.X
					Peer.Y = Sender.Y
					Peer.temp["isTeleporting"] = true
					Peer.temp["TargetLocation"] = Vector2(Sender.X, Sender.Y)
					Peer.CurrentLocation = Sender.CurrentLocation
					get_owner().rpc_id(int(Peer.name),"ChangePosition", Sender.X, Sender.Y)
					get_owner().rpc_id(int(Peer.name),"ReturnChat", "You have been summoned!", "Server")
					get_owner().rpc_id(int(Sender.name),"ReturnChat", "You have summoned " + Command[1] + "!", "Server")
				else:
					get_owner().rpc_id(int(Sender.name),"ReturnChat", Command[1] + " is not online!", "Server")
			else:
				get_owner().rpc_id(int(Sender.name),"ReturnChat", "Missing argument /summon >>[Name]<<", "Server")
			
		elif Command[0] == '/teleport':
			used = true
			
			if len(Command) > 2:
			
				var ChunkCoords = get_owner().get_node("Generation/Chunks").map_to_world(Vector2(int(Command[1]), int(Command[2])))
				Sender.X = ChunkCoords.x
				Sender.Y = ChunkCoords.y
				Sender.temp["isTeleporting"] = true
				Sender.temp["TargetLocation"] = Vector2(ChunkCoords.x, ChunkCoords.y)
				
				get_owner().rpc_id(int(Sender.name),"ReturnChat", "You have teleported to chunk (" + Command[1] + "," + Command[2] +") !", "Server")
				get_owner().rpc_id(int(Sender.name),"ChangePosition", Sender.X, Sender.Y)
			else:
				get_owner().rpc_id(int(Sender.name),"ReturnChat", "Missing arguments /teleport >>[X]<< >>[Y]<<", "Server")
		
		elif Command[0] == '/kick':
			used = true
			if len(Command) > 1:
				var peerInfo = get_owner().get_node("Data").isOnline(Command[1])
				
				if peerInfo["Bool"]:
					var Peer = get_owner().get_node("Active").get_node(peerInfo["Peer"])
					
					if Peer.AdminLevel >= AdminLevel:
						get_owner().rpc_id(int(Sender.name),"ReturnChat", "Failed to kick " + Command[1] + "! You do not have a high enough admin level to kick this player.", "Server")
					else:
						get_owner().network.disconnect_peer(int(Peer.name))
						get_owner().rpc_id(int(Sender.name),"ReturnChat", "You have kicked " + Command[1] + "!", "Server")
				else:
					get_owner().rpc_id(int(Sender.name),"ReturnChat", Command[1] + " is not online!", "Server")
			else:
				get_owner().rpc_id(int(Sender.name),"ReturnChat", "Missing argument /kick >>[Name]<<", "Server")
				
		elif Command[0] == '/warn':
			used = true
			
			if len(Command) > 2:
				var peerInfo = get_owner().get_node("Data").isOnline(Command[1])
				var warning = ""
				
				if peerInfo["Bool"]:
					# Extract Message From Command Array
					for message in range(len(Command)):
						if message >= 2:
							warning += Command[message] + " "
					
					
					var Peer = get_owner().get_node("Active").get_node(peerInfo["Peer"])
					Peer.discipline_history.append("Warning from Moderator: " + get_owner().peers[Sender.name] + "|"+ Command[2])
					get_owner().rpc_id(int(peerInfo["Peer"]),"ReturnChat", "WARNING FROM ADMIN!\n" + warning, "Server")
				else:
					var Data = get_owner().get_node("Data").LoadGeneralData("PlayerData/Players/", Command[1].to_lower() + ".json")
			else:
				get_owner().rpc_id(int(Sender.name),"ReturnChat", "Missing argument /warn >>[Name]<< >>[Message]<<", "Server")


	if AdminLevel >= 0:
		if Command[0] == '/help':
			get_owner().rpc_id(int(Sender.name),"ReturnChat", "General Commands:\n /help\n /clear", "Server")
			used = true
	if not used:
		get_owner().rpc_id(int(Sender.name),"ReturnChat", "Unknown command '" + Command[0] + "' try /help", "Server")
	return true
