extends CharacterBody3D

@export var float_speed := 0.1  # Speed at which the ghost floats up and down
@export var float_range := 0.5  # How high or low the ghost can float
@export var move_speed := 1.0  # Speed at which the ghost moves randomly

var original_y := 0.0
var random_move_dir := Vector3.ZERO
var time_passed := 0.0

# Called when the ghost is vacuumed
func vacuumed():
	print("Ghost vacuumed!")
	queue_free()  # Or any other logic you want when the ghost is vacuumed

# Called every frame to update the ghost's behavior
func _ready():
	original_y = global_transform.origin.y  # Store the original y position

# Update the ghost's floating and movement
func _process(delta):
	# Floating effect: Move up and down
	var float_offset = sin(time_passed * float_speed) * float_range
	global_transform.origin.y = original_y + float_offset
	
	# Move the ghost in random directions (x and z axes)
	random_move_dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	
	# Set velocity based on movement direction
	velocity.x = random_move_dir.x * move_speed
	velocity.z = random_move_dir.z * move_speed
	
	# Apply gravity manually
	if not is_on_floor():
		velocity.y -= 9.8 * delta  # Apply gravity downward

	# Move using the move_and_slide method (no snap needed for a character body)
	move_and_slide()

	# Increase time to drive the sine wave for floating
	time_passed += delta
