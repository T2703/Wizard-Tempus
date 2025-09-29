extends Node2D

# Stats of the bullet.
@export var speed: float = 400.0
@export var damage: int = 1

# Direction of the bullet.
var direction: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	position += direction  * speed * delta
	
func _on_scatter_timer_timeout() -> void:
	self.queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is PhysicsBody2D:
		var layer2_mask = 1 << 1
		
		if body.collision_layer & layer2_mask == layer2_mask:
			if "take_damage" in body:
				body.take_damage(damage)
			self.queue_free() 
		self.queue_free() 
	else:
		self.queue_free()
