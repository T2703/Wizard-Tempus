extends Node2D

var velocity: Vector2 = Vector2.ZERO
var damage: int = 1

func set_direction(dir: Vector2, speed: float) -> void:
	velocity = dir.normalized() * speed

func _physics_process(delta: float) -> void:
	position += velocity * delta


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is PhysicsBody2D:
		var layer1_mask = 1 << 0
		
		if body.collision_layer & layer1_mask == layer1_mask:
			if "take_damage" in body:
				body.take_damage(damage)
			self.queue_free() 
	else:
		self.queue_free()


func _on_bullet_life_timeout() -> void:
	self.queue_free()
