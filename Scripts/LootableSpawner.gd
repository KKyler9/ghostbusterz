extends Node3D

@export var lootable_scenes: Array[PackedScene]
@export var spawn_points: Array[Marker3D]

func _ready():
	print("LootableSpawner ready")
	if lootable_scenes.size() == 0:
		print("No lootable scenes provided!")
		return

	for spawn_point in spawn_points:
		print("Spawn point:", spawn_point.name, "position:", spawn_point.global_transform.origin)

		var loot_scene = lootable_scenes.pick_random()
		print("Spawning:", loot_scene.resource_path)

		var loot_instance = loot_scene.instantiate()
		if loot_instance:
			loot_instance.transform.origin = spawn_point.global_position
			loot_instance.add_to_group("Loot")  # Add loot to group for easier access
			loot_instance.visible = true  # Ensure the loot is visible
			print("Spawned:", loot_instance.name, "at", loot_instance.transform.origin)
			get_tree().current_scene.add_child.call_deferred(loot_instance)
		else:
			print("Failed to instantiate loot scene!")
