extends Node

class_name PlayerStateMachine

enum PlayerState { NORMAL, SPEED_BOOST, POWER_VACUUM }

var current_state: PlayerState = PlayerState.NORMAL

func set_state(new_state: PlayerState):
	current_state = new_state
	print("Player upgraded to state:", new_state)

func get_speed_multiplier() -> float:
	match current_state:
		PlayerState.SPEED_BOOST:
			return 1.5
		_:
			return 1.0

func get_vacuum_range() -> float:
	match current_state:
		PlayerState.POWER_VACUUM:
			return 3.0
		_:
			return 2.0
