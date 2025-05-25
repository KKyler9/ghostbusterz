# Lootable.gd
class_name Lootable # Keep this for global recognition

extends Node3D

@export var value: int = 10 # Value of this specific treasure instance
@export var loot_id: String = "" # Optional: A unique ID for this type of loot (e.g., "coin", "bronze_trophy")
@export var loot_name: String = "Treasure" # Optional: Display name for the loot

var is_collected := false # Internal state to prevent double-collection

# Returns a dictionary of this lootable's data
func get_loot_data() -> Dictionary:
	return {
		"value": value,
		"loot_id": loot_id,
		"loot_name": loot_name,
		# Add any other properties you might need to track in inventory
	}

# Called by Player when vacuumed. Returns the loot data and queues itself for removal.
func vacuumed() -> Dictionary:
	if is_collected:
		print("Loot already collected.")
		return {} # Return empty dictionary if already collected

	is_collected = true
	print("Loot vacuumed! Worth: ", value)

	var data = get_loot_data()
	queue_free() # CRITICAL: The lootable node frees itself immediately
	return data
