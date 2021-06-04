extends Node2D



func _ready():
	
	Server.LoggedIn = false
	Server.call_deferred("ConnectToServer")
	
	

func _process(delta):
	
	if Server.LoggedIn:
		get_tree().change_scene("res://Scenes/GameScene.tscn")
	
	if Server.connected:
		$UI/ConnectionStatus.text = "Connected!"
	else:
		$UI/ConnectionStatus.text = "Disconnected!"
	
	$UI/Messages.text = Server.message
	
	if $UI/Username/LineEdit.text == "" or $UI/Password/LineEdit.text == "":
		$UI/Login.disabled = true
		$UI/Register.disabled = true
	elif len($UI/Password/LineEdit.text) < 5 or len($UI/Username/LineEdit.text) < 3:
		$UI/Register.disabled = true
		$UI/Login.disabled = false
	else:
		$UI/Login.disabled = false
		$UI/Register.disabled = false


func _on_Login_pressed():
	Server.message = "Logging in.."
#	Server.Login( "grimm", "Test123")
	Server.Login($UI/Username/LineEdit.text, $UI/Password/LineEdit.text )



func _on_Register_pressed():
	Server.message = "Registering.."
	$UI/ValidUser.text = ""
	Server.Register($UI/Username/LineEdit.text, $UI/Password/LineEdit.text )


func _on_LineEdit_text_changed(new_text):
	if len(new_text) >= 3:
		Server.CheckUsername(new_text, $UI/ValidUser.get_instance_id())
	else:
		$UI/ValidUser.text = ""
