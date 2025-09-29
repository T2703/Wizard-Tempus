extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _process(_delta): 
	if Input.is_action_just_pressed("esc"):
		get_tree().paused = !get_tree().paused
		visible = get_tree().paused
	
func _on_resume_pressed() -> void:
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused


func _on_restart_pressed() -> void:
	GameState.player_time = 60
	GameState.timer_started = false
	GameState.spells_inventory.clear()
	GameState.starting_spell = null 
	GameState.rooms_cleared = 0 
	GameState.mana = 50
	GameState.mana_max = 50
	get_tree().paused = !get_tree().paused
	get_tree().change_scene_to_file("res://scenes/UI/choose_spell.tscn")


func _on_quit_pressed() -> void:
	GameState.player_time = 60
	GameState.timer_started = false
	GameState.rooms_cleared = 0 
	GameState.mana = 50
	GameState.mana_max = 50
	get_tree().paused = !get_tree().paused
	get_tree().change_scene_to_file("res://scenes/UI/menu.tscn")
