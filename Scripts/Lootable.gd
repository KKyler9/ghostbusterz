extends Node3D

@export var value: int = 10

func vacuumed():
	print("Loot vacuumed! Worth: ", value)
	queue_free()
