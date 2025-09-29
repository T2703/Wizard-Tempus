extends Node2D

@onready var reward_item: Sprite2D = $RewardItem

@export var spell: Spell
var mana_upgrade: int = 5
var time_increase: int
var player: Node2D = null
var pickup_sound = preload("res://sounds/reward_pickup.mp3")
var audio_player: AudioStreamPlayer


func _ready() -> void:
	update_visual()
	
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = pickup_sound
	audio_player.bus = "SFX"
	add_child(audio_player)

func update_visual() -> void:
	if spell:
		reward_item.texture = spell.reward_item_icon
		#else:
			#reward_item.texture = preload("res://assets/spell_default.png")
	elif mana_upgrade > 0:
		reward_item.texture = preload("res://assets/Spells/Items/Mana_Item.png")
	
	elif time_increase != 0:
		reward_item.texture = preload("res://assets/Spells/Items/Time_Item.png")
		
func _on_reward_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body


func _on_reward_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null

func _process(delta: float) -> void:
	if player and Input.is_action_just_pressed("e"):
		audio_player.play()
		grant_reward(player)
		var tween := get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2.ZERO, 0.3) 
		tween.tween_callback(Callable(self, "queue_free"))

func grant_reward(player):
	if spell:
		player.add_spell(spell)
	elif mana_upgrade > 0:
		player.set_mana_max(player.mana_max + mana_upgrade)
	elif time_increase != 0:
		GameState.player_time += time_increase

func set_reward(new_spell: Spell = null, new_mana_upgrade: int = 0, new_time_increase: int = 0) -> void:
	spell = new_spell
	mana_upgrade = new_mana_upgrade
	time_increase = new_time_increase
	update_visual()  
