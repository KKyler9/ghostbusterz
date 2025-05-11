extends Node

var upgrades = {
	"extra_storage": {"unlocked": true, "purchased": false},
	"faster_sprint": {"unlocked": true, "purchased": false}
}

func is_upgrade_active(upgrade_name: String) -> bool:
	return upgrades.has(upgrade_name) and upgrades[upgrade_name]["purchased"]

func purchase_upgrade(upgrade_name: String):
	if upgrades.has(upgrade_name) and upgrades[upgrade_name]["unlocked"]:
		upgrades[upgrade_name]["purchased"] = true

func reset_all():
	for key in upgrades.keys():
		upgrades[key]["purchased"] = false
