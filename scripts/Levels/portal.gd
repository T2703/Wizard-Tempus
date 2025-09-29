extends Node2D

var timer: Timer

# List of rooms. And rarity is determined by the weight.
var rooms := [
	{"path": "res://scenes/Levels/horde_room_1.tscn", "weight": 5, "type": "horde", "time_bonus": 10},
	{"path": "res://scenes/Levels/horde_room_2.tscn", "weight": 6, "type": "horde", "time_bonus": 15},
	{"path": "res://scenes/Levels/horde_room_3.tscn", "weight": 4, "type": "horde", "time_bonus": 10},
	{"path": "res://scenes/Levels/mind_link_room.tscn", "weight": 2, "type": "horde", "time_bonus": 18},
	{"path": "res://scenes/Levels/timed_room_1.tscn", "weight": 4, "type": "timed", "time_bonus": 5},
	{"path": "res://scenes/Levels/timed_room_2.tscn", "weight": 3, "type": "timed", "time_bonus": 5},
	{"path": "res://scenes/Levels/timed_room_3.tscn", "weight": 3, "type": "timed", "time_bonus": 10},
	{"path": "res://scenes/Levels/timed_room_4.tscn", "weight": 3, "type": "timed", "time_bonus": 10},
	{"path": "res://scenes/Levels/gamble_room.tscn", "weight": 2, "type": "gamble", "time_bonus": 1},
	{"path": "res://scenes/Levels/boss_room.tscn", "weight": 0, "type": "boss", "time_bonus": 21},
]

var current_room: Dictionary = {}

func _ready() -> void:
	randomize() 
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	# Set the current room based on the current scene path
	set_current_room_from_scene()

func set_current_room_from_scene() -> void:
	var current_scene_path = get_tree().current_scene.scene_file_path
	for room in rooms:
		if room["path"] == current_scene_path:
			current_room = room
			break

func pick_random_room() -> String:
	# Every 7 rooms -> force boss
	if (GameState.rooms_cleared + 1) % 7 == 0:
		for room in rooms:
			if room["type"] == "boss":
				current_room = room
				GameState.last_room = room["path"]
				return room["path"]
	
	# Normal pickings
	var pool: Array = []

	# Build weighted pool, excluding last_room
	for room in rooms:
		if room["path"] != GameState.last_room:
			for i in range(room["weight"]):
				pool.append(room)

	# If no rooms left after excluding last_room, allow last_room
	if pool.size() == 0:
		for room in rooms:
			for i in range(room["weight"]):
				pool.append(room)

	# Pick a random dictionary from the pool
	var next_room = pool[randi() % pool.size()]
	GameState.last_room = next_room["path"]
	return next_room["path"]
	
func _on_trigger_body_entered(body: Node2D) -> void:
	if body is PhysicsBody2D:
		var layer1_mask = 1 << 0
		if body.collision_layer & layer1_mask == layer1_mask:

			# Apply time bonus from the CURRENT room before picking the next one
			if GameState.timer_started and not current_room.is_empty():
				if current_room.has("time_bonus"):
					var bonus = current_room["time_bonus"]
					GameState.player_time += bonus
			else:
				# First room - initialize the timer only if it hasn't been started
				if not GameState.timer_started:
					GameState.player_time = 60.0  
					GameState.timer_started = true

			# Pick next room
			var next_room_path = pick_random_room()
			
			# Room clears
			GameState.rooms_cleared += 1
			
			# Max mana
			GameState.mana = GameState.mana_max

			# Scene transition
			var transition = get_tree().root.get_node("Transition")
			transition.play_wipe_in(func ():
				get_tree().change_scene_to_file(next_room_path)
			)

func start_lifetime(duration: float) -> void:
	timer.start(duration)

func _on_timer_timeout() -> void:
	queue_free()
