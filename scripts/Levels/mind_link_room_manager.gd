extends Node

@onready var spawn_area_node: Area2D = $SpawnArea
@onready var spawn_collision_shape: CollisionShape2D = $SpawnArea/CollisionShape2D
@onready var spawn_shape_rect: RectangleShape2D = spawn_collision_shape.shape as RectangleShape2D

@export var portal_scene: PackedScene

var portal_spawned: bool = false

var playerRef = null

func _ready() -> void:
	playerRef = get_node("Player")
	playerRef.global_position = get_random_spawn_point()
	
	var boss = get_node_or_null("MindLink") 
	if boss and boss.has_signal("died"):
		boss.died.connect(_on_boss_died)

func _on_boss_died():
	spawn_portal()

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
