extends Node2D

signal orb_died

var health: int = 4
var is_dead: bool = false
var hurt_sound = preload("res://sounds/enemy_hurt.mp3")
var audio_player: AudioStreamPlayer

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = hurt_sound
	audio_player.volume_db = -4
	audio_player.bus = "SFX"
	add_child(audio_player)

# Takes the damage from the weapon.
func take_damage(amount: int) -> void:
	health -= amount
	
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
	is_dead = true
	remove_from_group("mindorbs")
	emit_signal("orb_died", self) 
	
	# Death animation
	# Create tween
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2) 
	tween.tween_callback(Callable(self, "queue_free"))
