extends CharacterBody2D

signal died
signal health_changed(current: int, max: int)

var health: int
var speed: int
var damage: int
var time_increase: int

var attack_cool_down = 0.4
var attack_cool_down_timer = 0.0

var player_ref: Node2D = null
var player_in_area: Node2D = null

var is_knockback = false
var is_dead = false

var flash_timer: Timer

var original_color: Color
var hurt_sound: AudioStream
var audio_player: AudioStreamPlayer

func _ready() -> void:
	player_ref = get_parent().get_node("Player")
	add_to_group("enemies")
	
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

func _physics_process(delta: float) -> void:
	if player_ref == null:
		return
	
	if is_dead:
		speed = 0
		return
		
	look_at(player_ref.global_position)
	move_to_player(delta)

# Moves towards the player.
func move_to_player(delta: float) -> void:
	var direction = (player_ref.global_position - global_position).normalized()
	
	# Repulsion from nearby enemies
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self:
			continue
		var dist = global_position.distance_to(other.global_position)
		
		# The minimum spacing between each other.
		if dist < 20: 
			direction += (global_position - other.global_position).normalized() * (30 - dist) * 0.04
	
	# Normalize so it's not too strong.
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	velocity = direction * speed
	move_and_slide()

# Takes the damage from the weapon.
func take_damage(amount: int) -> void:
	health -= amount
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
		
# Enemy dies
func die() -> void:
	if is_dead:
		return
	emit_signal("died")
	is_dead = true
	GameState.player_time += time_increase
	
	# Death animation
	# Create tween
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2) 
	tween.tween_callback(Callable(self, "queue_free"))

func _on_flash_timeout():
	modulate = original_color 
