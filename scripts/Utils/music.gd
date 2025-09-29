extends Node

var player: AudioStreamPlayer

func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = "Music" 
	print("MusicPlayer ready, player in scene tree:", player.is_inside_tree())

func play_song(stream: AudioStream):
	if player.stream != stream:
		player.stream = stream
		player.play()
	else:
		player.play()

func stop_song():
	if player and player.playing:
		player.stop()
