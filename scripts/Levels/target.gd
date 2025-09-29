extends Node2D

@export var portal_scene: PackedScene   
@export var portal_lifetime: float = 5.0
var pickup_sound = preload("res://sounds/target_hit.mp3")
var audio_player: AudioStreamPlayer

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = pickup_sound
	audio_player.bus = "SFX"
	add_child(audio_player)

func _on_hitbox_area_entered(area: Area2D) -> void:
	# Spawn portal instantly
	if portal_scene:
		audio_player.play()
		var portal = portal_scene.instantiate()
		get_tree().current_scene.add_child(portal)
		
		var spawn_point = get_tree().current_scene.get_node("PortalSpawnPoint")
		portal.global_position = spawn_point.global_position
		
		portal.start_lifetime(portal_lifetime)
