extends "res://scripts/Enemies/enemy.gd"

@export var orb_shot_scene: PackedScene
@export var orb_speed: float = 150.0 
var max_health: int = 150

var is_firing = false
var fire_duration = 2.0       
var fire_cooldown = 2.0       
var fire_rate = 0.09
var fire_timer: Timer
var cooldown_timer: Timer

func _init() -> void:
	health = max_health
	damage = 2
	speed = 110
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
	
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false
	fire_timer.timeout.connect(Callable(self, "_on_fire_timer_timeout"))
	add_child(fire_timer)

	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = fire_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(Callable(self, "_on_cooldown_timer_timeout"))
	add_child(cooldown_timer)
	
	start_firing()

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

func start_firing():
	is_firing = true
	fire_timer.start()
	var t = Timer.new()
	t.wait_time = fire_duration
	t.one_shot = true
	t.autostart = true
	t.timeout.connect(Callable(self, "stop_firing"))
	add_child(t)
	t.start()
	
func stop_firing():
	is_firing = false
	fire_timer.stop()
	cooldown_timer.start()

func _on_fire_timer_timeout():
	if player_ref == null:
		return

	# Direction toward player
	var direction = (player_ref.global_position - global_position).normalized()

	# Spawn orb/bullet
	if orb_shot_scene:
		var orb = orb_shot_scene.instantiate()
		orb.global_position = global_position
		get_tree().current_scene.add_child(orb)
		orb.set_direction(direction, orb_speed)

func _on_cooldown_timer_timeout():
	# Start next burst
	start_firing()

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
