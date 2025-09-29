class_name Spell
extends Resource

# Weapon stats.
@export var name: String
@export var damage: int
@export var mana_cost: int
@export var cool_down_rate: float
@export var speed: float
@export var semi_auto: bool = false
@export var crit_chance_var: float
@export var crit_multipier: float
@export var muzzle_offset: Vector2 = Vector2.ZERO
@export var projectile_scene: PackedScene
@export var reward_item_icon: Texture2D
@export var spell_sound: AudioStream
@export var projectile_count: int = 1   
@export var spread_angle: float = 0.0   

# Internal timer for the fire rate.
var cooldown = 0.0

# Checks if the weapon can shoot.
func can_shoot() -> bool:
	return cooldown <= 0.0

# Shoots the weapon.
func shoot(owner: Node2D):
	if not can_shoot():
		return
	
	# Check if the player has a mana system.
	if not owner.has_method("use_mana"):
		push_warning("Owner has no mana system")
		return
		
	# Not enough mana? Too bad
	if not owner.has_enough_mana(mana_cost):
		return
		
	# Deduction
	owner.use_mana(mana_cost)
	
	# Play sound
	if spell_sound:
		# Create a temporary AudioStreamPlayer
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = spell_sound
		audio_player.volume_db = -8
		audio_player.bus = "SFX"
		owner.add_child(audio_player)  
		audio_player.play()
	
	# Cooldown
	cooldown = cool_down_rate
	
	# Spawn the bullet.
	for i in range(projectile_count):
		var bullet = projectile_scene.instantiate()
		owner.get_tree().current_scene.add_child(bullet)

		# Position at muzzle
		var muzzle_global = owner.to_global(muzzle_offset)
		bullet.global_position = muzzle_global

		# Base direction is where the player is facing
		var base_dir = Vector2.RIGHT.rotated(owner.global_rotation)

		# Calculate spread (centered around the base direction)
		var angle_offset = deg_to_rad((i - (projectile_count - 1) / 2.0) * spread_angle)
		var final_dir = base_dir.rotated(angle_offset)

		bullet.direction = final_dir.normalized()

		# Apply stats
		var final_damage = crit_chance(crit_chance_var, crit_multipier)
		bullet.damage = final_damage
		bullet.speed = speed

# Decrease the timer.
func process(delta: float) -> void:
	if cooldown > 0:
		cooldown -= delta

# The crictal chance for a weapon to do damage.
func crit_chance(chance: float, multiplier: float) -> int:
	if randf() < chance:
		return int(damage * multiplier)
	return damage

func get_icon() -> Texture2D:
	return reward_item_icon
