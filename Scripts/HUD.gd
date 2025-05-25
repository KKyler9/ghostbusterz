# HUD.gd
extends CanvasLayer

@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var money_label: Label = $MoneyLabel
@onready var ghost_inventory_label: Label = $GhostInventoryLabel
@onready var treasure_inventory_label: Label = $TreasureInventoryLabel
@onready var quest_progress_label: Label = $QuestProgressLabel

func update_stamina(ratio: float):
	stamina_bar.value = ratio * 100.0

func update_money(amount: int):
	money_label.text = "Money: $" + str(amount)

func update_ghost_inventory(current: int, max: int):
	ghost_inventory_label.text = "Ghosts: %d/%d" % [current, max]

# THIS IS CORRECT FOR DISPLAYING TREASURE COUNT
func update_treasure_inventory(current: int, max: int):
	treasure_inventory_label.text = "Treasure: %d/%d" % [current, max]

func update_quest_progress(current: Dictionary, goal: Dictionary):
	if quest_progress_label == null:
		push_error("quest_progress_label is null!")
		return

	if current == null or goal == null:
		push_error("Current or goal data is null!")
		return

	var text := "Quest Progress:\n"
	for key in goal.keys():
		var cur = current.get(key, 0)
		var req = goal[key]
		var display_key = key.capitalize()
		if key == "ghost":
			display_key += " (any type)"
		text += "- %s: %d/%d\n" % [display_key, cur, req]

	# Assuming Quest is an Autoload (set in Project Settings -> Autoload)
	if Quest and Quest.is_quest_complete():
		text += "\n✅ Quest Complete!"

	quest_progress_label.text = text.strip_edges()

func clear_quest_progress():
	quest_progress_label.text = ""

func _ready():
	if not has_node("QuestProgressLabel"):
		push_error("QuestProgressLabel node missing!")

	# Assuming Quest is an Autoload (set in Project Settings -> Autoload)
	if Quest and not Quest.is_connected("progress_updated", Callable(self, "update_quest_progress")):
		Quest.connect("progress_updated", Callable(self, "update_quest_progress"))

	# Initial update for quest progress
	if Quest:
		update_quest_progress(Quest.progress, Quest.current_quest)
	else:
		push_warning("Quest Autoload not found!")

	# Initialize inventory labels (use Player's max capacities if known, or sensible defaults)
	# You might want to get these from the Player script instead of hardcoding
	update_ghost_inventory(0, 3) # Assuming Player.max_ghost_capacity is 3
	update_treasure_inventory(0, 3) # Assuming Player.max_treasure_capacity is 3
