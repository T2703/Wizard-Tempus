extends CanvasLayer

@onready var health: ProgressBar = $Health

func set_boss(boss: Node):
	if boss.has_signal("health_changed"):
		print("BOSS")
		boss.health_changed.connect(_on_boss_health_changed)
		# Initialize values
		_on_boss_health_changed(boss.health, boss.max_health)

func _on_boss_health_changed(current: int, max: int) -> void:
	health.max_value = max
	health.value = current
