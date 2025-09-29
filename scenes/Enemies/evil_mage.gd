extends "res://scripts/Enemies/enemy.gd"

@export var bullet_scene: PackedScene
@export var bullet_speed: float = 450.0
@onready var muzzle: Marker2D = $Muzzle

func _init() -> void:
	health = 10
	damage = 1
	speed = 50
	attack_cool_down = 0.2
	time_increase = 1
	hurt_sound = preload("res://sounds/enemy_hurt.mp3")

func _process(delta: float) -> void:
	if is_dead:
		$AttackArea.monitorable = false
		$AttackArea.monitoring = false
		speed = 0
	
	damage_player(delta)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = body

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == player_in_area:
		player_in_area = null

# Damage the player, should be called in _process.
func damage_player(delta: float) -> void:
	if player_in_area:
		attack_cool_down -= delta
		if attack_cool_down <= 0.0:
			player_in_area.take_damage(damage)
			attack_cool_down = 0.2


func _on_spell_timer_timeout() -> void:
	if player_ref == null:
		return
		
	if player_ref:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = muzzle.global_position
		get_tree().current_scene.add_child(bullet)
		var direction = Vector2.RIGHT.rotated(global_rotation)
		bullet.set_direction(direction, bullet_speed)
