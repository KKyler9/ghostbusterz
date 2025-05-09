extends CanvasLayer

@onready var stamina_bar = $Control/TextureRect/Control/StaminaBar
@onready var money_label = $Control/TextureRect/Control/MoneyLabel
@onready var elimination_label = $Control/TextureRect/Control/EliminationLabel

func update_money(amount: int):
	money_label.text = "Money: $" + str(amount)

func update_eliminations(count: int):
	elimination_label.text = "Eliminations: " + str(count)

func update_stamina(ratio: float):
	stamina_bar.value = ratio * 100.0
