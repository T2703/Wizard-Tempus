extends Node2D

var speed: float = 400.0
var damage: int = 1
var velocity: Vector2 = Vector2.ZERO

# Direction of the bullet.
var direction: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	position += direction  * speed * delta

func _on_maho_timer_timeout() -> void:
	self.queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is PhysicsBody2D:
		var layer2_mask = 1 << 1
		
		if body.collision_layer & layer2_mask == layer2_mask:
			if "take_damage" in body:
				body.take_damage(damage)
				self.queue_free()
	self.queue_free()


func set_direction(dir: Vector2, speed: float) -> void:
	velocity = dir.normalized() * speed

func _physics_process(delta: float) -> void:
	position += velocity * delta
