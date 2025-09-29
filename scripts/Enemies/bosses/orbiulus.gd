extends "res://scripts/Enemies/enemy.gd"

@export var orb_shot_scene: PackedScene
@export var orb_count: int = 25 
@export var gap_size: int = 2 
@export var orb_speed: float = 150.0 
var max_health: int = 125

func _init() -> void:
	health = max_health
	damage = 1
	speed = 80
	attack_cool_down = 0.2
	time_increase = 0
	hurt_sound = preload("res://sounds/enemy_hurt.mp3")
	
	original_color = modulate
	flash_timer = Timer.new()
	flash_timer.wait_time = 0.1
	flash_timer.one_shot = true
	flash_timer.timeout.connect(Callable(self, "_on_flash_timeout"))
	add_child(flash_timer)
	
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = hurt_sound
	audio_player.volume_db = -4
	audio_player.bus = "SFX"
	add_child(audio_player)

func _process(delta: float) -> void:
	if is_dead:
		$AttackArea.monitorable = false
		$AttackArea.monitoring = false
		speed = 0
	
	damage_player(delta)

func _physics_process(delta: float) -> void:
	if player_ref == null:
		return
	move_to_player(delta)

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

		orb_shot.set_direction(direction, orb_speed)


func _on_orb_shot_timer_timeout() -> void:
	if player_ref == null:
		return
	shoot_orbs()

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

func take_damage(amount: int) -> void:
	health -= amount
	emit_signal("health_changed", health, max_health)
	modulate = Color.DARK_RED
	
	# Restarts the timer
	flash_timer.start()
	
	if hurt_sound:
		if audio_player.playing:
			audio_player.stop() 
		audio_player.play()
	
	# No health = no life.
	if health <= 0:
		die()
