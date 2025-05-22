extends Area3D


@onready var depot_ghost_label: Label3D = $"../DepotGhostLabel"
@onready var depot_treasure_label: Label3D = $"../DepotLootLabel"

# Total collected ghosts by type across all deposits
var total_ghosts_collected := {}
# Total collected treasure
var total_treasure_collected := 0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	update_labels()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		drop_items(body)

func drop_items(player):
	# player.ghost_inventory now holds ghost data dicts, not ghost nodes
	var ghost_type_counts := {}

	for ghost_data in player.ghost_inventory:
		if ghost_data == null:
			continue
		# Expect ghost_data to be a Dictionary with a "ghost_type" key
		if typeof(ghost_data) == TYPE_DICTIONARY and ghost_data.has("ghost_type"):
			var gtype = ghost_data["ghost_type"]
			ghost_type_counts[gtype] = ghost_type_counts.get(gtype, 0) + 1
		else:
			# Unexpected data format, skip
			continue

	# Debug print ghost counts before updating quest
	print("Ghosts ready to deposit:", ghost_type_counts)

	# Update quest progress before clearing player's ghost inventory
	var quest_manager = get_node_or_null("/root/Quest")
	if quest_manager:
		print("Quest manager found, updating progress...")
		quest_manager.update_progress(ghost_type_counts)
	else:
		print("Quest manager not found!")

	# Clear player's ghost inventory now that data deposited
	player.ghost_inventory.clear()

	# Deposit treasure value
	var treasure_deposited = player.treasure_inventory
	var treasure_value = 10  # Set value per treasure unit
	player.money += treasure_deposited * treasure_value
	player.treasure_inventory = 0

	# Update player HUD
	if player.hud:
		player.hud.update_ghost_inventory(0, player.max_ghost_capacity)
		player.hud.update_treasure_inventory(0, player.max_treasure_capacity)
		player.hud.update_money(player.money)

	# Update depot totals
	_update_totals(ghost_type_counts, treasure_deposited)
	update_labels()

	print("Deposited ghost types: ", ghost_type_counts)
	print("Deposited treasure: ", treasure_deposited)
	print("Player money: ", player.money)

func _update_totals(new_ghosts: Dictionary, new_treasure: int) -> void:
	for gtype in new_ghosts.keys():
		total_ghosts_collected[gtype] = total_ghosts_collected.get(gtype, 0) + new_ghosts[gtype]
	total_treasure_collected += new_treasure

func update_labels() -> void:
	var ghost_total := 0
	for count in total_ghosts_collected.values():
		ghost_total += count

	depot_ghost_label.text = "Ghosts Deposited: %d" % ghost_total
	depot_treasure_label.text = "Treasure Desposited: %d" % total_treasure_collected
