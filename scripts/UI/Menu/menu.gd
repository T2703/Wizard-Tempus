extends Control

@onready var music_manager = $MainMenuMusic

func _ready() -> void:
	MusicPlayer.play_song(preload("res://sounds/main_menu.mp3"))

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	GameState.player_time = 60
	GameState.timer_started = false
	get_tree().change_scene_to_file("res://scenes/UI/choose_spell.tscn")


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/settings.tscn")
