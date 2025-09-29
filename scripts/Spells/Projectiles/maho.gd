extends Node2D

@export var speed: float = 400.0
@export var damage: int = 1
@export var orb_count: int = 18 
@export var gap_size: int = 2
@export var orb_shot_scene: PackedScene

# Direction of the bullet.
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	scale = Vector2.ZERO
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	position += direction  * speed * delta


func _on_maho_timer_timeout() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.6) 
	tween.tween_callback(Callable(self, "queue_free"))


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is PhysicsBody2D:
		var layer2_mask = 1 << 1
		
		if body.collision_layer & layer2_mask == layer2_mask:
			if "take_damage" in body:
				body.take_damage(damage)
				shoot_orbs()
			shoot_orbs()
	shoot_orbs()

func shoot_orbs():
	if orb_shot_scene == null:
		return

	# Full circle in radians
	var full_circle = TAU 
	var angle_step = full_circle / orb_count

	for i in range(orb_count):
		# Skip some projectiles to create gaps
		if i % (gap_size + 1) == 0:
			continue

		var angle = i * angle_step
		var direction = Vector2.RIGHT.rotated(angle) 

		# Spawn orb
		var orb_shot = orb_shot_scene.instantiate()
		get_tree().current_scene.add_child(orb_shot)
		orb_shot.global_position = global_position
	
		orb_shot.set_direction(direction, speed)
	
	self.queue_free()
