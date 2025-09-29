extends "res://scripts/Spells/Spell.gd"

func _init() -> void:
	name = "Cobalt Bullet"
	damage = 3
	cool_down_rate = 0.15
	speed = 400.0
	mana_cost = 1
	muzzle_offset = Vector2(9, 3)
	semi_auto = false
	projectile_scene = preload("res://scenes/Spells/cobalt_bullet.tscn")
	crit_chance_var = 0.05
	crit_multipier = 1.1
