extends Node2D

signal remove_chests

var player_in_area: bool = false

# Rewards
@export var possible_spells: Array[Spell] = []  
@export var mana_upgrade_amount: int = 5

var is_opened: bool = false

func _on_chest_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = true

func _on_chest_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = false
		
func _process(delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("e") and not is_opened:
		is_opened = true
		emit_signal("remove_chests")
		grant_reward()

# Grants the reward.
func grant_reward():
	var player = get_tree().current_scene.get_node("Player")
	if not player:
		return
	
	var reward_scene = preload("res://scenes/Levels/reward_item.tscn")
	var reward = reward_scene.instantiate()
	get_tree().current_scene.add_child(reward)
	reward.global_position = self.global_position
	
	var available_spells = []
	for s in possible_spells:
		if not player.spells_inventory.has(s):
			available_spells.append(s)

	if randf() < 0.5 and available_spells.size() > 0:
		var chosen_spell = available_spells[randi() % available_spells.size()]
		reward.set_reward(chosen_spell)
	elif randf() < 0.6:
		reward.set_reward(null, mana_upgrade_amount)
	elif randf() < 0.7:
		var bonus = randi_range(5, 20)
		reward.set_reward(null, 0, bonus)  # time bonus
	elif randf() < 0.7:
		var penalty = -randi_range(5, 10)
		reward.set_reward(null, 0, penalty)  # time penalty
