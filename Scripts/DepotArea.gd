extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("drop_items"):
			print("Depot: Dropping items from player.")
			body.drop_items()
		else:
			print("Depot: Player has no drop_items() method.")
