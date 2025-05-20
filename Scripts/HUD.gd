extends CanvasLayer

@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var money_label: Label = $MoneyLabel
@onready var captures_label: Label = $CapturesLabel
@onready var ghost_inventory_label: Label = $GhostInventoryLabel
@onready var treasure_inventory_label: Label = $TreasureInventoryLabel
@onready var quest_label: Label = $QuestLabel

func update_stamina(ratio: float):
	stamina_bar.value = ratio * 100.0

func update_money(amount: int):
	money_label.text = "Money: $" + str(amount)

func update_captures(count: int):
	captures_label.text = "Captures: " + str(count)

func update_ghost_inventory(current: int, max: int):
	ghost_inventory_label.text = "Ghosts: %d/%d" % [current, max]

func update_treasure_inventory(current: int, max: int):
	treasure_inventory_label.text = "Treasure: %d/%d" % [current, max]

func update_quest_progress(current: int, goal: int):
	quest_label.text = "Quest: %d/%d Ghosts" % [current, goal]
