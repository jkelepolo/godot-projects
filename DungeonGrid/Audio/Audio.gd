extends Node2D

func MuteCheck():
	if Global.is_mute:
		StopAllAudio()
		return true
	return false

func StopAllAudio():
	for child in self.get_children():
		Global.MenuAudioPosition = 0
		child.stop()

func isSongPlaying():
	for child in self.get_children():
		if child.playing:
			return true
	return false

func _process(delta):
	Global.MenuAudioPosition = $MenuMusic.get_playback_position()
