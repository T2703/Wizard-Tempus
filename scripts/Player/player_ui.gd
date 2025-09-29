extends CanvasLayer

@onready var timer: Label = $Time
@onready var room: Label = $Room
@onready var mana: ProgressBar = $Mana
@onready var mana_label: Label = $Mana/ManaLabel
@onready var spell_icon: TextureRect = $SpellIcon

func _process(delta: float) -> void:
	if GameState.timer_started:
		GameState.player_time -= delta
		GameState.player_time = max(GameState.player_time, 0) 
		timer.text = str(int(GameState.player_time))
	
	# Mana bar
	if mana:
		mana.max_value = float(GameState.mana_max)
		mana.value = lerp(float(mana.value), float(GameState.mana), 0.1)
		mana_label.text = str(int(GameState.mana)) + " / " + str(GameState.mana_max)
	
	if room:
		room.text = "Rooms Cleared: " + str((GameState.rooms_cleared))
	
	# Spell Icon.
	var player = get_parent()
	if player and player.current_spell:
		spell_icon.texture = player.current_spell.reward_item_icon
