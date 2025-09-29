extends Node2D

@export var bullet_scene: PackedScene
@export var bullet_speed: float = 420.0
@onready var muzzle: Marker2D = $Muzzle
var health: int = 2
var is_dead: bool = false

func _on_shoot_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position
	get_tree().current_scene.add_child(bullet)
	bullet.set_direction(Vector2.DOWN, bullet_speed)

# Takes the damage from the weapon.
func take_damage(amount: int) -> void:
	health -= amount
	
	# No health = no life.
	if health <= 0:
		die()

# Enemy dies
func die() -> void:
	if is_dead:
		return
	is_dead = true
	
	# Death animation
	# Create tween
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2) 
	tween.tween_callback(Callable(self, "queue_free"))
