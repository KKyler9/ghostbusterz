extends Node3D

@export var ghost_scene: PackedScene
@export var banshee_scene: PackedScene
@export var spawn_points: Array[Node3D] = []  # Properly typed array of Node3D

@onready var spawn_timer: Timer = Timer.new()

func _ready():
	randomize()
	add_child(spawn_timer)
	spawn_timer.wait_time = 5.0
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(spawn_ghost)
	spawn_timer.start()
	spawn_ghost()

func spawn_ghost():
	if spawn_points.is_empty():
		push_warning("No spawn points assigned!")
		return

	var ghost_scenes = [ghost_scene, banshee_scene]
	var selected_scene: PackedScene = ghost_scenes.pick_random()

	if not selected_scene:
		push_warning("No valid ghost scene selected.")
		return

	var ghost = selected_scene.instantiate()

	var spawn_point = spawn_points.pick_random()
	if not spawn_point:
		push_warning("Spawn point is invalid.")
		return

	ghost.global_transform.origin = spawn_point.global_transform.origin
	get_tree().current_scene.add_child(ghost)

	print("Spawned ghost: %s at %s" % [selected_scene.resource_path, spawn_point.name])
