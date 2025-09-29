extends CanvasLayer

@onready var clear: Label = $Clear

func _ready() -> void:
	MusicPlayer.stop_song()

func _on_retry_pressed() -> void:
	GameState.player_time = 60
	GameState.timer_started = false
	GameState.spells_inventory.clear()
	GameState.starting_spell = null 
	GameState.rooms_cleared = 0 
	GameState.mana = 50
	GameState.mana_max = 50
	get_tree().change_scene_to_file("res://scenes/UI/choose_spell.tscn")
	MusicPlayer.call_deferred("play_song", preload("res://sounds/main_menu.mp3"))


func _on_quit_pressed() -> void:
	GameState.player_time = 60
	GameState.timer_started = false
	GameState.spells_inventory.clear()
	GameState.starting_spell = null 
	GameState.rooms_cleared = 0 
	GameState.mana = 50
	GameState.mana_max = 50
	get_tree().change_scene_to_file("res://scenes/UI/menu.tscn")
	MusicPlayer.call_deferred("play_song", preload("res://sounds/main_menu.mp3"))

func _process(delta: float) -> void:
	if clear:
		clear.text = "You Cleared " +  str((GameState.rooms_cleared)) + " Rooms"
