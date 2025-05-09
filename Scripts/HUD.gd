extends CanvasLayer


@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var money_label: Label = $MoneyLabel
@onready var eliminations_label: Label = $EliminationsLabel

func update_money(money: int):
	money_label.text = "Money: $" + str(money)

func update_eliminations(count: int):
	eliminations_label.text = "Eliminations: " + str(count)

func update_stamina(ratio: float):
	stamina_bar.value = ratio * 100.0
