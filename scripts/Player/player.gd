
extends CharacterBody2D

# Speed of the player movement.
const SPEED: int = 200

# Accleration of the player.
const ACCELERATION: float = 0.2

# Movement friction for sliding and moving.
const FRICTION: int = 1

# The current speed of the player.
var current_speed: int = SPEED

# Every wizard needs this duh.
var mana: int 
var mana_max: int 
@onready var mana_regen_timer: Timer = $ManaRegenTimer

# The flash cooldown.
@onready var flash_timer = $FlashTimer
var original_color = modulate


# The direction of the player from getting the input.
var direction: Vector2 = Vector2.ZERO

# The inventory of spells (Should be max 3)
@export var spells_inventory: Array[Spell] 
var current_spell: Spell


# Checks if the player is shooting.
var is_shooting: bool = false

@export var hurt_sound: AudioStream

@export var tombstone_scene: PackedScene

# Gets the input of the player.
func get_input():
	# Movement
	var input = Input.get_vector("left", "right", "up", "down")
		
	return input
	
func _ready() -> void:
	# Restore spell inventory from GameState
	if GameState.spells_inventory.size() > 0:
		spells_inventory = GameState.spells_inventory.duplicate()
		var i = clamp(GameState.current_spell_index, 0, spells_inventory.size() - 1)
		equip_spell(i)
	else:
		# fallback if no inventory exists yet
		if GameState.starting_spell:
			spells_inventory = [GameState.starting_spell]
			equip_spell(0)
		elif spells_inventory.size() > 0:
			equip_spell(0)
	
	mana = GameState.mana
	mana_max = GameState.mana_max

func _process(delta: float) -> void:
	# No health = no life.
	if GameState.player_time <= 0:
		var tombstone = tombstone_scene.instantiate()
		get_tree().current_scene.add_child(tombstone)
		tombstone.global_position = global_position
		self.queue_free()
		
# Anything related to the movement
func _physics_process(delta: float) -> void:
	# Look around from mouse position.
	look_at(get_global_mouse_position())
	
	# Movement with the physics
	direction = get_input()
	
	# Regular movement
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * current_speed, ACCELERATION)
	else:	
		velocity = velocity.lerp(Vector2.ZERO, FRICTION)
		
	move_and_slide()

	# Weapon Stuff
	if current_spell:
		current_spell.process(delta)
	
	if Input.is_action_just_pressed("tab") and not is_shooting:
		var i = (spells_inventory.find(current_spell) + 1) % spells_inventory.size()
		equip_spell(i)
	
	# CAST
	var should_shoot = false
	if current_spell:
		if current_spell.semi_auto:
			should_shoot = Input.is_action_just_pressed("lclick")
		else:
			should_shoot = Input.is_action_pressed("lclick")
	if should_shoot and current_spell:
		is_shooting = true
		current_spell.shoot(self)
	else:
		is_shooting = false

# Equip/switch spells based on the player's inventory.
func equip_spell(index: int):
	current_spell = spells_inventory[index]
	GameState.spells_inventory = spells_inventory.duplicate()
	GameState.current_spell_index = index

# Adds the spell to the player's inventory.
func add_spell(spell: Spell):
	if spells_inventory.size() < 3:
		spells_inventory.append(spell)
	else:
		var current_index = spells_inventory.find(current_spell)
		spells_inventory[current_index] = spell
		equip_spell(current_index)
		
	GameState.spells_inventory = spells_inventory.duplicate()

func has_enough_mana(cost: int) -> bool:
	return mana >= cost

func use_mana(cost: int) -> void:
	mana = clamp(mana - cost, 0, mana_max)
	GameState.mana = mana 

# Upgrade system for mana.
func set_mana_max(new_max: int) -> void:
	mana_max = new_max
	if mana > mana_max:
		mana = mana_max
	GameState.mana_max = mana_max
	GameState.mana = mana
	
func _on_mana_regen_timer_timeout() -> void:
	if not is_shooting and mana < mana_max:
		mana += 1
		mana = clamp(mana, 0, mana_max)
		GameState.mana = mana 

# Takes the damage from whatever gives you damage.
func take_damage(amount: int):
	GameState.player_time -= amount
	modulate = Color.RED
	
	# Restarts the timer
	flash_timer.start()
	
	# Play sound
	if hurt_sound:
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = hurt_sound
		audio_player.volume_db = -8
		audio_player.bus = "SFX"
		owner.add_child(audio_player)  
		audio_player.play()


func _on_flash_timer_timeout() -> void:
	modulate = original_color
