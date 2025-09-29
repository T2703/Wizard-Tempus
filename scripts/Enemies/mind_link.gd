extends CharacterBody2D
signal died

@export var eye_scene: PackedScene
@onready var shield: CharacterBody2D = $MindLinkShield
var health: int = 2
var is_dead: bool = false
var hurt_sound = preload("res://sounds/enemy_hurt.mp3")


func _ready():
	var orbs = get_tree().get_nodes_in_group("mindorbs")
	for orb in orbs:
		orb.orb_died.connect(_on_orb_died)
		
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
	emit_signal("died") 
	
	# Death animation
	# Create tween
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2) 
	tween.tween_callback(Callable(self, "queue_free"))

func _on_orb_died(orb):
	var orbs = get_tree().get_nodes_in_group("mindorbs")
	if orbs.is_empty():
		shield.queue_free()


func _on_eye_spawner_timer_timeout() -> void:
	if is_dead:
		return
	var eye = eye_scene.instantiate()
	get_tree().current_scene.add_child(eye)
	eye.global_position = global_position
