extends CharacterBody3D

@export var speed = 5.0
@export var air_control = 0.5
@export var mouse_sensitivity = 0.1
@export var jump_velocity = 8.0
@export var gravity = 20.0
@export var coyote_time_max = 0.2

var y_rotation = 0.0
var coyote_timer = 0.0
var was_on_floor = false
var landing_bob_strength = 0.1
var head_bob_velocity = 0.0
var jump_pressed = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		$Camera3D.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += transform.basis.x

	input_dir = input_dir.normalized()

	# Coyote time timer
	if is_on_floor():
		coyote_timer = coyote_time_max
	else:
		coyote_timer -= delta

	# Jumping
	if Input.is_action_just_pressed("jump"):
		jump_pressed = true

	if jump_pressed and (is_on_floor() or coyote_timer > 0.0):
		velocity.y = jump_velocity
		coyote_timer = 0.0
		jump_pressed = false

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0:
		velocity.y = 0.0

	# Air or ground movement
	var target_velocity = input_dir * speed
	if is_on_floor():
		velocity.x = target_velocity.x
		velocity.z = target_velocity.z
	else:
		velocity.x = lerp(velocity.x, target_velocity.x, air_control)
		velocity.z = lerp(velocity.z, target_velocity.z, air_control)

	# Landing head bob
	if not was_on_floor and is_on_floor() and abs(velocity.y) > 1.0:
		head_bob_velocity = landing_bob_strength

	was_on_floor = is_on_floor()

	# Apply head bobbing
	if head_bob_velocity > 0.001:
		$Camera3D.translate(Vector3(0, -head_bob_velocity, 0))
		head_bob_velocity = lerp(head_bob_velocity, 0.0, delta * 10)

	move_and_slide()
