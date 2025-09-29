extends Node

# Tracks the last room so no repetion
var last_room: String = "" 

# The starting spell chosen from the player
var starting_spell: Spell

# The inventory of the player spells
var spells_inventory: Array[Spell] = []

# The player's mana.
var mana: int = 50

# The player's max mana.
var mana_max: int = 50

# The player's heatlh it's in seconds
var player_time: float = 60.0 
var timer_started: bool = false  

# Amount of rooms cleared
var rooms_cleared: int = 0

# Currently equipped spell
var current_spell_index: int = 0

func _process(delta: float) -> void:
	# decrease player time
	player_time -= delta
	player_time = max(player_time, 0)  
