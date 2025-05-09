extends Node3D

@export var value: int = 10

func vacuumed():
	print("Loot vacuumed! Worth: ", value)
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		players[0].add_money(value)
	else:
		print("No Player found in group.")
	queue_free()
