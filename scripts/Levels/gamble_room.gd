extends Node2D

@export var portal_scene: PackedScene   
@onready var spawn_area_node: Area2D = $SpawnArea
@onready var spawn_collision_shape: CollisionShape2D = $SpawnArea/CollisionShape2D
@onready var spawn_shape_rect: RectangleShape2D = spawn_collision_shape.shape as RectangleShape2D

func _ready() -> void:
	for chest in $Chests.get_children():
		chest.connect("remove_chests", Callable(self, "_on_remove_chests"))

func _on_remove_chests() -> void:
	for chest in $Chests.get_children():
		var tween := get_tree().create_tween()
		tween.tween_property(chest, "scale", Vector2.ZERO, 0.3) 
		tween.tween_callback(Callable(chest, "queue_free"))
