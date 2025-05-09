extends CharacterBody3D

@onready var head = $Head
@onready var camera = $Head/Camera
@onready var flashlight = $Head/Camera/SpotLight3D
@onready var stamina = preload("res://Player/Stamina.gd").new()
@onready var vacuum_ray = $"Head/Camera/Camera#VacuumRay"


const SPEED := 5.0
const SPRINT_MULTIPLIER := 1.8
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.1

var is_sprinting := false
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
	hud.update_eliminations(eliminations)
	
# Lock the mouse to the window at the start
func _ready():
	print("Player.gd: Player ready!")
	add_to_group("Player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	flashlight.visible = false
	
	# Assign HUD here
	hud = get_tree().current_scene.get_node_or_null("HUD")
	if hud == null:
		push_warning("HUD node not found. HUD updates will not work.")

# Update yaw and pitch based on mouse movement
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, -90, 90)
		rotation_degrees.y = yaw
		head.rotation_degrees.x = pitch

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
		flashlight.visible = !flashlight.visible

# Handle player movement and physics
func _physics_process(delta):
	var direction = Vector3.ZERO
	var input = Input

	# Check for player movement inputs
	if input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if input.is_action_pressed("move_back"):
		direction += transform.basis.z
	if input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if input.is_action_pressed("move_right"):
		direction += transform.basis.x

	# Handle sprinting and stamina
	is_sprinting = input.is_action_pressed("sprint") and stamina.can_sprint()
	stamina.update(delta, is_sprinting)

	# Normalize direction for consistent movement speed
	direction = direction.normalized()
	var speed = SPEED * (SPRINT_MULTIPLIER if is_sprinting else 1.0)

	# Update velocity based on input direction
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Apply gravity if not on the ground
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	elif input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	# Move the character
	move_and_slide()

	# Check if vacuum OR loot action is active
	if input.is_action_pressed("vacuum") or input.is_action_pressed("loot"):
		attempt_vacuum()

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
