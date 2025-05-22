extends Resource

const MAX_STAMINA := 100.0
const DRAIN_RATE := 20.0
const RECOVERY_RATE := 15.0
const REGEN_COOLDOWN := 1.5  # Seconds to wait after hitting 0
const MIN_REGEN_BEFORE_SPRINT := 25.0

var current_stamina := MAX_STAMINA
var regen_timer := 0.0
var in_cooldown := false

func update(delta: float, is_sprinting_input: bool, is_moving: bool):
	var should_drain = is_sprinting_input and is_moving and not in_cooldown

	if should_drain:
		current_stamina -= DRAIN_RATE * delta
		if current_stamina <= 0.0:
			current_stamina = 0.0
			in_cooldown = true
			regen_timer = 0.0
	else:
		if in_cooldown:
			regen_timer += delta
			if regen_timer >= REGEN_COOLDOWN:
				current_stamina += RECOVERY_RATE * delta
				if current_stamina >= MIN_REGEN_BEFORE_SPRINT:
					in_cooldown = false
		else:
			current_stamina += RECOVERY_RATE * delta

	current_stamina = clamp(current_stamina, 0.0, MAX_STAMINA)

func can_sprint() -> bool:
	return not in_cooldown and current_stamina > 0.0

func current_stamina_percent() -> float:
	return current_stamina / MAX_STAMINA
