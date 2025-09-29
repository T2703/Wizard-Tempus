extends Node

@export var boss_scenes: Array[PackedScene] = []
@export var spawn_indicator_scene: PackedScene
@export var indicator_lifetime: float = 0.5
@onready var spawn_area_node: Area2D = $SpawnArea
@onready var spawn_collision_shape: CollisionShape2D = $SpawnArea/CollisionShape2D
@onready var spawn_shape_rect: RectangleShape2D = spawn_collision_shape.shape as RectangleShape2D

@export var portal_scene: PackedScene
@export var chest_scene: PackedScene

var boss_spawned: bool = false
var chest_spawned: bool = false
var portal_spawned: bool = false

var playerRef = null

func _ready() -> void:
	spawn_boss_with_indicator()
	playerRef = get_node("Player")
	playerRef.global_position = get_random_spawn_point()

func spawn_boss_with_indicator():
	if boss_scenes.is_empty() or boss_spawned:
		return

	var pos = get_random_spawn_point()

	# Spawn indicator first
	if spawn_indicator_scene:
		var indicator = spawn_indicator_scene.instantiate()
		indicator.global_position = pos
		add_child(indicator)

		get_tree().create_timer(indicator_lifetime, false, true).timeout.connect(func ():
			indicator.queue_free()
			_spawn_boss_at(pos))
	else:
		_spawn_boss_at(pos)

func _spawn_boss_at(pos: Vector2):
	if boss_spawned:
		return

	boss_spawned = true
	var boss_scene = boss_scenes.pick_random()
	var boss = boss_scene.instantiate()
	boss.global_position = pos
	call_deferred("add_child", boss)
	
	# Find the boss UI and attach
	var boss_ui = get_tree().current_scene.get_node("BossUI")
	boss_ui.set_boss(boss)

	# Make sure boss has a "died" signal
	if boss.has_signal("died"):
		boss.died.connect(_on_boss_died)

func _on_boss_died():
	spawn_chest()
	spawn_portal()

func spawn_chest():
	if chest_spawned or chest_scene == null:
		return

	chest_spawned = true
	var pos = get_random_spawn_point()
	var chest = chest_scene.instantiate()
	chest.global_position = pos
	call_deferred("add_child", chest)

func spawn_portal():
	if portal_spawned or portal_scene == null:
		return

	portal_spawned = true
	var pos = get_random_spawn_point()
	var portal = portal_scene.instantiate()
	portal.global_position = pos
	call_deferred("add_child", portal)

func get_random_spawn_point() -> Vector2:
	if not spawn_shape_rect:
		return spawn_area_node.global_position

	var extents = spawn_shape_rect.extents
	var local_point = Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)

	return spawn_collision_shape.global_transform * local_point
