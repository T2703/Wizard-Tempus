extends Node2D

@export var chest_scene: PackedScene
@export var spawn_chance: float = 0.50

func _ready() -> void:
	if randf() < spawn_chance:
		spawn_chest()

func spawn_chest() -> void:
	if chest_scene:
		var chest = chest_scene.instantiate()
		var spawn_point = get_tree().current_scene.get_node("ChestSpawnPoint")
		get_tree().current_scene.add_child(chest)
		chest.global_position = spawn_point.global_position
