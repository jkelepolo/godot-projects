extends Node


func PlayerCheck(PlayerPosition, player_id):
	var Player = get_owner().get_node("Active").get_node(str(player_id))
	var last_position = Vector2(Player.X, Player.Y)
	if last_position.distance_to(PlayerPosition) > 10 and not Player.temp["isTeleporting"] and not PlayerPosition == Player.temp["TargetLocation"]:
		print(str(PlayerPosition) + " | " + str(last_position))
#		get_owner().network.disconnect_peer(player_id)
		get_owner().rpc_id(player_id,"ChangePosition", Player.X, Player.Y)
		Player.temp["isTeleporting"] = false
		return false
	else:
		get_owner().get_node("Active").get_node(str(player_id)).X = PlayerPosition.x
		get_owner().get_node("Active").get_node(str(player_id)).Y = PlayerPosition.y
		Player.temp["isTeleporting"] = false
		return true
		

