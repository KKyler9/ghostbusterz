extends Node3D  # or another relevant type (e.g., MeshInstance3D, if it's visible)

@export var weapon_id: String = "vacuum_gun"

var max_ghost_capacity := 3
var max_treasure_capacity := 3

func apply_upgrades():
	var upgrade_manager = get_node("/root/UpgradeManager")
	if upgrade_manager.is_upgrade_active("extra_storage"):
		max_ghost_capacity += 2
		max_treasure_capacity += 2
