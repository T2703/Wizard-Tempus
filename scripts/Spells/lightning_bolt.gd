extends "res://scripts/Spells/Spell.gd"

func _init() -> void:
	name = "Lightning Bolt"
	damage = 8
	cool_down_rate = 0.20
	speed = 300.0
	mana_cost = 3
	muzzle_offset = Vector2(9, 3)
	semi_auto = true
	projectile_scene = preload("res://scenes/Spells/lightning_bolt.tscn")
	crit_chance_var = 0.10
	crit_multipier = 1.1
