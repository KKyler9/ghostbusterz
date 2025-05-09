extends Node3D

@export var ghost_scene: PackedScene  # Packed scene for the ghost
@export var spawn_points: Array[Node3D]  # Array of spawn points for the ghosts

@onready var spawn_timer = Timer.new()  # Timer for periodic spawning

# Initialize and start the timer on ready
func _ready():
	# Add the timer to the current scene
	add_child(spawn_timer)
	spawn_timer.wait_time = 5.0  # Spawn a ghost every 5 seconds
	
	# Correct way to connect the signal in Godot 4.5
	spawn_timer.timeout.connect(spawn_ghost)  # Directly connecting the function
	spawn_timer.start()
	
	# Initially spawn a ghost when the scene starts
	spawn_ghost()

# Function to spawn a ghost at a random spawn point
func spawn_ghost():
	if spawn_points.is_empty():  # Using is_empty() instead of empty()
		print("No spawn points available!")
		return

	# Instantiate the ghost
	var ghost = ghost_scene.instantiate()

	# Pick a random spawn point from the spawn_points array
	var spawn_point = spawn_points.pick_random()

	# Set the ghost's global position to the spawn point's global position
	ghost.global_transform.origin = spawn_point.global_transform.origin

	# Add the ghost to the current scene
	get_tree().current_scene.add_child(ghost)
