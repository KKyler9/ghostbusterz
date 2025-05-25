# Player.gd
extends CharacterBody3D

# === Nodes ===
@onready var head = $Head
@onready var camera = $Head/Camera
@onready var flashlight = $Head/Camera/SpotLight3D
@onready var vacuum_ray = $"Head/Camera/Camera#VacuumRay"
@onready var weapon_holder = $Head/Camera/WeaponHolder
@onready var stamina = preload("res://Scripts/Stamina.gd").new()
# @onready var player_collider: CollisionShape3D = $CollisionShape3D # Removed as per original

# === Exported ===
@export var weapon: Node

# === Constants ===
const BASE_SPEED := 5.0
const SPRINT_MULTIPLIER := 3.0
const JUMP_VELOCITY := 5.5
const MOUSE_SENSITIVITY := 0.1
const GRAVITY := 14.0
const FALL_MULTIPLIER := 2.5
const ACCELERATION := 16.0
const DECELERATION := 40.0
const CROUCH_MULTIPLIER := 0.5 # Kept as it was in your "original" code
const SLIDE_DURATION := 0.6

# --- CROUCHING SPECIFIC CONSTANTS (Removed as per original) ---
# Your original code did not have these specific constants, so they are not included.

# === Player State ===
var yaw := 0.0
var pitch := 0.0
var speed := BASE_SPEED
var is_sprinting := false
var target_velocity := Vector3.ZERO
var hud # Will be assigned in _ready()
var is_crouching := false # Kept as it was in your "original" code
var is_sliding := false
var slide_timer := 0.0

# === Inventory ===
var ghost_inventory: Array = [] # Stores ghost data dictionaries (captured ghost info)
var treasure_inventory: Array[Dictionary] = [] # Now stores treasure DATA dictionaries
var max_ghost_capacity := 3
var max_treasure_capacity := 3

# === Persistent Progress ===
var money := 0
var materials: Dictionary = {} # Track materials if needed for crafting/upgrades

func _ready():
	add_to_group("Player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	flashlight.visible = false

	hud = get_tree().root.get_node_or_null("MainScene/SubViewportContainerHUD/HUDViewport/HUD")

	spawn_weapon()
	apply_upgrades()

	# Initialize HUD with current inventory and progress
	if hud:
		hud.update_ghost_inventory(ghost_inventory.size(), max_ghost_capacity)
		hud.update_treasure_inventory(treasure_inventory.size(), max_treasure_capacity)
		hud.update_money(money)
	else:
		push_warning("HUD node not found at specified path!")

	# Original code did not have collider/head initialization here, so it's removed.
	# This means the player's initial collider and head position will be whatever is set in Player.tscn.


# --- Weapon Setup ---
func spawn_weapon():
	var weapon_instance = LoadoutManager.get_selected_weapon_instance()
	if weapon_instance and weapon_holder:
		if weapon:
			weapon.queue_free()
		weapon = weapon_instance
		weapon_holder.add_child(weapon)
		weapon.owner = self
		if weapon.has_method("apply_upgrades"):
			weapon.apply_upgrades()
	else:
		push_warning("No valid weapon instance returned by LoadoutManager.")

# --- Upgrades ---
func apply_upgrades():
	var upgrade_manager = get_node_or_null("/root/UpgradeManager")
	if upgrade_manager:
		if upgrade_manager.is_upgrade_active("faster_sprint"):
			speed = BASE_SPEED + 2.0
	if weapon:
		weapon.apply_upgrades()

# --- Input Handling ---
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, -90, 90)
		rotation_degrees.y = yaw
		head.rotation_degrees.x = pitch

	# Original code did not have specific handling for crouch input.
	# Keeping `is_crouching` var but not using it here.

	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			flashlight.visible = !flashlight.visible
		elif event.button_index == MOUSE_BUTTON_LEFT and Input.is_action_pressed("vacuum"):
			attempt_vacuum()
		elif event.button_index == MOUSE_BUTTON_RIGHT and Input.is_action_pressed("loot"):
			attempt_vacuum()

# --- Movement & Physics ---
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

	var is_moving = input_dir.length() > 0
	var sprint_input = Input.is_action_pressed("sprint")
	is_sprinting = sprint_input and stamina.can_sprint()
	var move_speed = speed * (SPRINT_MULTIPLIER if is_sprinting else 1.0)
	target_velocity = input_dir * move_speed

	stamina.update(delta, sprint_input, is_moving)

	# Apply horizontal movement
	if input_dir == Vector3.ZERO:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, ACCELERATION * delta)

	# Apply vertical movement (jumping/gravity)
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	else:
		var fall_gravity = GRAVITY
		if velocity.y < 0:
			fall_gravity *= FALL_MULTIPLIER
		elif abs(velocity.y) < 1 and is_moving:
			fall_gravity *= 0.6
		velocity.y -= fall_gravity * delta

	move_and_slide()

	# Removed the FINAL FIX for position.y as it was not in your "original" code.
	# You'll need to manually manage character position in Player.tscn
	# and ensure your SpawnPoint is correct.

	if hud:
		hud.update_stamina(round(stamina.current_stamina_percent() * 100.0) / 100.0)

# --- Vacuuming (Loot & Ghosts) ---
func attempt_vacuum():
	if not weapon:
		push_warning("No weapon assigned to player.")
		return

	if vacuum_ray.is_colliding():
		var target = vacuum_ray.get_collider()
		print("Ray hit: ", target)

		# Walk up parent chain to find node with vacuumed() method and correct group
		var parent = target
		while parent and not (parent.has_method("vacuumed") and (parent.is_in_group("Ghost") or parent.is_in_group("Loot"))):
			parent = parent.get_parent()

		if parent:
			# Handle treasure loot vacuuming
			if Input.is_action_pressed("loot") and parent.is_in_group("Loot") and parent is Lootable:
				if treasure_inventory.size() < max_treasure_capacity:
					var treasure_data = parent.vacuumed()
					if treasure_data != null and not treasure_data.is_empty():
						add_treasure(treasure_data)
						print("Player collected treasure data: ", treasure_data)
					else:
						print("Failed to get treasure data or treasure already collected.")
				else:
					print("Treasure capacity reached! Cannot collect more.")

			# Handle ghost vacuuming: add ghost *data* to inventory, free ghost node
			elif Input.is_action_pressed("vacuum") and parent.is_in_group("Ghost"):
				if ghost_inventory.size() < max_ghost_capacity:
					add_ghost_data_from_node(parent)
				else:
					print("Ghost capacity reached! Cannot capture more.")

# --- Inventory Management ---
func add_ghost_data_from_node(ghost_node: Node):
	if ghost_inventory.size() < max_ghost_capacity:
		var ghost_data = ghost_node.vacuumed()
		if ghost_data != null and not ghost_data.is_empty():
			ghost_inventory.append(ghost_data)
			if hud:
				hud.update_ghost_inventory(ghost_inventory.size(), max_ghost_capacity)
			print("Added ghost data to inventory:", ghost_data)
		else:
			print("Failed to get ghost data or ghost already captured.")

func add_treasure(treasure_data: Dictionary):
	if treasure_inventory.size() < max_treasure_capacity:
		treasure_inventory.append(treasure_data)
		if hud:
			hud.update_treasure_inventory(treasure_inventory.size(), max_treasure_capacity)
		print("Added treasure data to inventory. Current count: ", treasure_inventory.size())
	else:
		push_warning("add_treasure called when capacity is full. This should be prevented earlier.")

# --- Deposit Items to Depot ---
func deposit_to_depot(depot_area):
	if depot_area:
		print("Depositing items to depot: ", depot_area.name)
		depot_area.drop_items(self)

# --- Clear Inventory (after deposit or reset) ---
func clear_inventory():
	ghost_inventory.clear()
	treasure_inventory.clear()

	if hud:
		hud.update_ghost_inventory(ghost_inventory.size(), max_ghost_capacity)
		hud.update_treasure_inventory(treasure_inventory.size(), max_treasure_capacity)
		hud.update_money(money)
