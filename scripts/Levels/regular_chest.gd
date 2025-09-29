extends Node2D

var player_in_area: bool = false

# Rewards (possible)
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
		grant_reward()
		is_opened = true
		var tween := get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2.ZERO, 0.3) 
		tween.tween_callback(Callable(self, "queue_free"))

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
	else:
		reward.set_reward(null, mana_upgrade_amount)
