extends CanvasLayer

func _ready():
	Server.ChatID = get_instance_id()

func _process(delta):
	
	if $Chat/LineEdit.has_focus():
		Global.busy = true
	else:
		Global.busy = false
	
	
	if $Chat/LineEdit.has_focus() and Input.is_action_just_pressed("ui_enter"):
		if $Chat/LineEdit.text == "/clear":
			$Chat/RichTextLabel.clear()
			$Chat/LineEdit.text = ""
			$Chat/LineEdit.release_focus()
			return
		if $Chat/LineEdit.text != "":
			Server.Chat($Chat/LineEdit.text,"World")
#			$Chat/RichTextLabel.add_text($Chat/LineEdit.text+"\n\n")
			$Chat/LineEdit.text = ""
		$Chat/LineEdit.release_focus()
	elif not $Chat/LineEdit.has_focus() and Input.is_action_just_pressed("ui_enter"):
		$Chat/LineEdit.grab_focus()

func ReturnChat(Message, Channel):
	$Chat/RichTextLabel.add_text(str(Message)+"\n\n")
