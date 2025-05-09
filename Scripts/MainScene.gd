extends Node

@onready var world_viewport := $WorldViewportContainer/WorldViewport
@onready var playground_scene := preload("res://Scenes/Playground.tscn")

# HUD nodes directly in the scene
@onready var stamina_bar := $HUDViewportContainer/HUDViewport/HUDCanvasLayer/StaminaBar
@onready var money_label := $HUDViewportContainer/HUDViewport/HUDCanvasLayer/MoneyLabel
@onready var elimination_label := $HUDViewportContainer/HUDViewport/HUDCanvasLayer/EliminationLabel

func _ready():
	print("MainScene: Setting up world and HUD...")
	
	# Load and add the Playground scene
	var playground = playground_scene.instantiate()
	world_viewport.add_child(playground)
	print("MainScene: Playground added to WorldViewport.")

	# After scene loads, find the player and assign HUD reference
	await get_tree().process_frame
	var player = world_viewport.get_node("Playground/Player") # Adjust path if needed
	if player:
		player.hud = self  # Pass self so the player can call `update_money()` etc.
	else:
		push_warning("Player not found in Playground!")

func update_money(amount: int):
	money_label.text = "Money: $" + str(amount)

func update_eliminations(count: int):
	elimination_label.text = "Eliminations: " + str(count)

func update_stamina(value: float):
	stamina_bar.value = value
