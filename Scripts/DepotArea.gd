# DepotArea.gd
extends Area3D

@onready var depot_ghost_label: Label3D = $"../DepotGhostLabel"
@onready var depot_treasure_label: Label3D = $"../DepotLootLabel"

var total_ghosts_collected := {}
var total_treasure_collected_count := 0 # This is for the DepotArea's own display (count)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	update_labels()

func _on_body_entered(body: Node3D):
	if body.is_in_group("Player"):
		print("Player entered DepotArea. Attempting to drop items.")
		drop_items(body)

func drop_items(player_node: CharacterBody3D):
	# --- Ghost Deposit Logic ---
	var ghost_type_counts := {}
	for ghost_data in player_node.ghost_inventory:
		if ghost_data == null or not ghost_data.has("ghost_type"): # Ensure it's valid ghost data
			push_warning("Invalid ghost data in player's ghost_inventory!")
			continue
		var gtype = ghost_data["ghost_type"]
		ghost_type_counts[gtype] = ghost_type_counts.get(gtype, 0) + 1

	print("Ghosts ready to deposit (DepotArea.drop_items):", ghost_type_counts)

	var quest_manager = get_node_or_null("/root/Quest")
	if quest_manager:
		quest_manager.update_progress(ghost_type_counts)
	else:
		push_warning("Quest manager not found!")

	player_node.ghost_inventory.clear() # Clear player's ghost inventory

	# --- TREASURE DEPOSIT LOGIC (Now processes DATA dictionaries) ---
	var current_deposit_money_value = 0 # Sum of values for player's money
	var treasures_deposited_count_for_depot = 0 # Count of treasures for depot label

	# Iterate through the player's treasure inventory (which now holds DATA DICTIONARIES)
	for treasure_data in player_node.treasure_inventory:
		# Ensure it's a valid treasure data dictionary and has a 'value' key
		if typeof(treasure_data) == TYPE_DICTIONARY and treasure_data.has("value"):
			current_deposit_money_value += treasure_data["value"] # Sum the VALUE from the dictionary
			treasures_deposited_count_for_depot += 1 # COUNT the treasure dictionary
			print("Depot processing treasure data: ", treasure_data.get("loot_name", "Unknown Loot"), ", Value: ", treasure_data["value"])
		else:
			push_warning("Invalid treasure data found in player's inventory during deposit!")

	# UPDATE PLAYER'S MONEY
	player_node.money += current_deposit_money_value
	print("Added $", current_deposit_money_value, " to player's money. New total: $", player_node.money)

	# CLEAR PLAYER'S TREASURE INVENTORY AFTER DEPOSIT
	player_node.treasure_inventory.clear()
	print("Player's treasure inventory cleared. New size: ", player_node.treasure_inventory.size())

	# --- HUD UPDATES ---
	if player_node.hud:
		player_node.hud.update_ghost_inventory(player_node.ghost_inventory.size(), player_node.max_ghost_capacity)
		player_node.hud.update_treasure_inventory(player_node.treasure_inventory.size(), player_node.max_treasure_capacity)
		player_node.hud.update_money(player_node.money)
		print("HUD updated: Ghosts (0), Treasure Count (0), Money (new total).")
	else:
		push_warning("Player HUD not found during deposit!")

	# --- DEPOT TOTALS UPDATE ---
	_update_totals(ghost_type_counts, treasures_deposited_count_for_depot)
	update_labels()
	print("Depot totals and labels updated.")

	print("--- Deposit Summary ---")
	print("Total Ghosts deposited this time: ", ghost_type_counts)
	print("Total Treasure Count deposited this time (for depot label): ", treasures_deposited_count_for_depot)
	print("Total Treasure Value deposited this time (for player money): ", current_deposit_money_value)
	print("Player final money after deposit: ", player_node.money)
	print("-----------------------")

func _update_totals(new_ghosts: Dictionary, new_treasure_count: int) -> void:
	for gtype in new_ghosts.keys():
		total_ghosts_collected[gtype] = total_ghosts_collected.get(gtype, 0) + new_ghosts[gtype]
	total_treasure_collected_count += new_treasure_count
	print("Depot running total ghost count:", total_ghosts_collected)
	print("Depot running total treasure count:", total_treasure_collected_count)


func update_labels() -> void:
	var ghost_total := 0
	for count in total_ghosts_collected.values():
		ghost_total += count

	depot_ghost_label.text = "Ghosts Deposited: %d" % ghost_total
	depot_treasure_label.text = "Treasure Deposited: %d" % total_treasure_collected_count
	print("Depot 3D labels updated to show counts.")
