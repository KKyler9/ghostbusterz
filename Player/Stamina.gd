extends Resource

const MAX_STAMINA := 100.0
const DRAIN_RATE := 20.0
const RECOVERY_RATE := 15.0

var current_stamina := MAX_STAMINA

func update(delta, is_sprinting):
	if is_sprinting:
		current_stamina -= DRAIN_RATE * delta
	else:
		current_stamina += RECOVERY_RATE * delta
	current_stamina = clamp(current_stamina, 0, MAX_STAMINA)

func can_sprint() -> bool:
	return current_stamina > 5.0
	
func current_stamina_percent() -> float:
	return current_stamina / MAX_STAMINA
