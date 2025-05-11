extends Node

var available_weapons := {}  # Dictionary of weapon_id: PackedScene
var selected_weapon_id := "Weapon01"

func register_weapon(id: String, scene: PackedScene):
	available_weapons[id] = scene

func select_weapon(id: String):
	if available_weapons.has(id):
		selected_weapon_id = id
	else:
		push_warning("Weapon ID not found: %s" % id)

func get_selected_weapon_instance() -> Node:
	if available_weapons.has(selected_weapon_id):
		return available_weapons[selected_weapon_id].instantiate()
	push_warning("Failed to get selected weapon instance.")
	return null

func _ready():
	register_weapon("Weapon01", preload("res://Weapon/weapon01.tscn"))
	#register_weapon("flamethrower", preload("res://Weapons/Flamethrower.tscn"))
