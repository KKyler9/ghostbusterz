extends Node3D

@onready var spawn_point = $SpawnPoint
var player_scene = preload("res://Player/Player.tscn")

func _ready():
	print("World: Ready, waiting for scene to fully load...")
	await get_tree().process_frame  # Waits one frame to ensure everything is in the tree
	_spawn_player()

func _spawn_player():
	if spawn_point == null:
		push_error("SpawnPoint is null! Check your scene tree.")
		return

	print("World: Spawning player")
	var player = player_scene.instantiate()
	player.global_transform.origin = spawn_point.global_transform.origin
	add_child(player)
	print("World: Player spawned at ", spawn_point.global_transform.origin)
