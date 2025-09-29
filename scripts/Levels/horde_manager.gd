extends Node

# Stuff for the spawner
@export var enemy_scenes: Array[PackedScene] = []
@export var enemies_per_wave: int
@export var time_before_start: float = 0.1
@export var time_between_spawns: float = 0.6
@export var spawn_indicator_scene: PackedScene
@export var indicator_lifetime: float = 0.15
@onready var spawn_area_node: Area2D = $SpawnArea
@onready var spawn_collision_shape: CollisionShape2D = $SpawnArea/CollisionShape2D
@onready var spawn_shape_rect: RectangleShape2D = spawn_collision_shape.shape as RectangleShape2D
@export var portal_scene: PackedScene
@export var chest_scene: PackedScene

# How many enemies are left
var enemies_left: int = 0

var portal_spawned: bool = false
var chest_spawned: bool = false
var playerRef = null

func _ready() -> void:
	if GameState.rooms_cleared >= 3:
		enemy_scenes.append(preload("res://scenes/Enemies/living_plant.tscn"))
	if GameState.rooms_cleared >= 4:
		enemy_scenes.append(preload("res://scenes/Enemies/evil_mage.tscn"))
		
	enemies_per_wave = randi_range(5, 10) +  GameState.rooms_cleared
	playerRef = get_node("Player")
	playerRef.global_position = get_random_spawn_point()
	get_tree().create_timer(time_before_start, false, true).timeout.connect(start_wave)
	
	
func start_wave():
	enemies_left = enemies_per_wave  
	for i in range(enemies_per_wave):
		get_tree().create_timer(i * time_between_spawns, false, true).timeout.connect(spawn_enemy)

# Spawns the enemies.
func spawn_enemy():
	if enemy_scenes.is_empty():
		return
	
	# Random position.
	var pos = get_random_spawn_point()
	
	# Spawn indicator
	if spawn_indicator_scene:
		var indicator = spawn_indicator_scene.instantiate()
		indicator.global_position = pos
		add_child(indicator)
		
		# Remove after lifetime
		get_tree().create_timer(indicator_lifetime, false, true).timeout.connect(func():
			indicator.queue_free()
			_spawn_enemy_at(pos))
	else:
		_spawn_enemy_at(pos)

# Spawns the portal (should happen upon completion).
func spawn_portal():
	if portal_spawned:
		return
		
	if portal_scene:
		portal_spawned = true
		var portal = portal_scene.instantiate()
		var pos = get_random_spawn_point()
		portal.global_position = pos
		call_deferred("add_child", portal)

# Spawns the chest (should happen upon completion).
func spawn_chest():
	if chest_spawned:
		return
		
	if portal_scene:
		chest_spawned = true
		var chest = chest_scene.instantiate()
		var pos = get_random_spawn_point()
		chest.global_position = pos
		call_deferred("add_child", chest)
		
func get_random_spawn_point() -> Vector2:
	if not spawn_shape_rect:
		# fallback
		return spawn_area_node.global_position

	var extents = spawn_shape_rect.extents
	var local_point = Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)

	# Transform the point from the collision_shape's local space to world space.
	return spawn_collision_shape.global_transform * local_point
	
# Helper function for spawning in the enemy.
func _spawn_enemy_at(pos: Vector2):
	if enemy_scenes.is_empty():
		return
	
	var enemy_scene = enemy_scenes.pick_random()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	call_deferred("add_child", enemy) 
	
	enemy.died.connect(_on_enemy_died)

func _on_enemy_died():
	enemies_left -= 1
	if enemies_left <= 0:
		spawn_portal()
		spawn_chest()

func _on_start_wave():
	start_wave()
