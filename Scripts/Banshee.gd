extends CharacterBody3D

# === Exported Properties ===
@export var float_speed := 0.1  # Speed at which the ghost floats up and down
@export var float_range := 0.5  # How high or low the ghost can float
@export var move_speed := 1.0  # Speed at which the ghost moves randomly
@export var ghost_type: String = "banshee"  # Type of Ghost (used for quests and inventory)
@export var drops: Array[String] = ["dust"]  # Materials dropped when deposited (can expand for crafting)

# === Internal State ===
var original_y := 0.0
var random_move_dir := Vector3.ZERO
var time_passed := 0.0
var is_captured := false  # Prevent duplicate vacuuming or movement after capture

func _ready():
	original_y = global_transform.origin.y  # Store original y for floating

func _process(delta):
	if is_captured:
		return  # Stop processing after capture

	# Floating effect (sin wave)
	var float_offset = sin(time_passed * float_speed) * float_range
	global_transform.origin.y = original_y + float_offset

	# Random horizontal movement direction
	random_move_dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()

	velocity.x = random_move_dir.x * move_speed
	velocity.z = random_move_dir.z * move_speed

	# Gravity down if not on floor
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	move_and_slide()

	time_passed += delta

# Returns a dictionary of ghost data
func get_ghost_data() -> Dictionary:
	return {
		"ghost_type": ghost_type,
		"drops": drops,
		# Add other relevant data if needed
	}

# Called by Player when vacuumed
func vacuumed() -> Dictionary:
	if is_captured:
		return {}  # empty dictionary instead of null
	is_captured = true

	print("Ghost vacuumed!")

	var data = get_ghost_data()
	queue_free()
	return data
