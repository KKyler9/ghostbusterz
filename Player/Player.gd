extends CharacterBody3D

@onready var head = $Head
@onready var camera = $Head/Camera
@onready var flashlight = $Head/Camera/SpotLight3D
@onready var stamina = preload("res://Player/Stamina.gd").new()
@onready var vacuum_ray = $"Head/Camera/Camera#VacuumRay"


const SPEED := 5.0
const SPRINT_MULTIPLIER := 3.0
const JUMP_VELOCITY := 5.5
const MOUSE_SENSITIVITY := 0.1
const CROUCH_MULTIPLIER := 0.5
const SLIDE_DURATION := 0.6
const GRAVITY := 14.0
const FALL_MULTIPLIER := 2.5
const ACCELERATION := 16.0
const DECELERATION := 20.0


var is_sprinting := false
var is_crouching := false
var is_sliding := false
var slide_timer := 0.0
var target_velocity := Vector3.ZERO

var yaw := 0.0
var pitch := 0.0
var money: int = 0
var eliminations: int = 0
var hud

# Money
func add_money(amount: int):
	money += amount
	print("Money: ", money)
	if hud:
		hud.update_money(money)
	else:
		push_warning("HUD is not available.")

# Eliminations
func add_elimination():
	eliminations += 1
	print("Eliminations: ", eliminations)
	if hud:
		hud.update_eliminations(eliminations)
	else:
		push_warning("HUD is not available.")
	
# Lock the mouse to the window at the start
func _ready():
	print("Player.gd: Player ready!")
	add_to_group("Player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	flashlight.visible = false
	
	# Find HUD in the scene tree
	hud = get_tree().root.get_node("MainScene/SubViewportContainerHUD/HUDViewport/HUD")

# Update yaw and pitch based on mouse movement
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, -90, 90)
		rotation_degrees.y = yaw
		head.rotation_degrees.x = pitch

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			flashlight.visible = !flashlight.visible

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Input.is_action_pressed("vacuum"):
			attempt_vacuum()

		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and Input.is_action_pressed("loot"):
			attempt_vacuum()


# Handle player movement and physics
func _physics_process(delta):
	var input_dir = Vector3.ZERO

	# WASD movement inputs
	if Input.is_action_pressed("move_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += transform.basis.x

	input_dir = input_dir.normalized()

	# Sprinting logic

    var sprint_input = Input.is_action_pressed("sprint")
	is_sprinting = sprint_input and stamina.can_sprint()
	var target_speed = SPEED * (SPRINT_MULTIPLIER if is_sprinting else 1.0)
	var target_velocity = input_dir * target_speed

	# Update stamina before applying sprint
	stamina.update(delta, sprint_input, is_moving)
	# Apply acceleration/deceleration for horizontal movement
	if input_dir == Vector3.ZERO:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, ACCELERATION * delta)
	# Update HUD stamina bar
	if hud:
		hud.update_stamina(round(stamina.current_stamina_percent() * 100.0) / 100.0)

	# Handle jumping and gravity
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	else:
		var fall_gravity = GRAVITY
		if velocity.y < 0:
			fall_gravity *= FALL_MULTIPLIER
		elif abs(velocity.y) < 1 and input_dir.length() > 0:
			fall_gravity *= 0.6  # glide when jumping and moving
		velocity.y -= fall_gravity * delta

	move_and_slide()

# Function for vacuum interaction
func attempt_vacuum():
	if vacuum_ray.is_colliding():
		var target = vacuum_ray.get_collider()
		print("Ray hit: ", target)

		if target:
			var parent = target
			# Walk up the tree to find a valid vacuum target
			while parent and not (parent.has_method("vacuumed") and (parent.is_in_group("Ghost") or parent.is_in_group("Loot"))):
				parent = parent.get_parent()

			if parent:
				# Left click - vacuum ghosts
				if Input.is_action_pressed("vacuum") and parent.is_in_group("Ghost"):
					add_elimination()
					parent.vacuumed()

				# Right click - vacuum loot
				elif Input.is_action_pressed("loot") and parent.is_in_group("Loot"):
					print("vacuuming")
					parent.vacuumed()
