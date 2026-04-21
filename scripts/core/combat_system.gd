extends Node
class_name CombatSystem

var rng = RandomNumberGenerator.new()

const CRIT_CHANCE = 20
const CRIT_MULTIPLIER = 2.0

func _init():
	rng.randomize()

# ─────────────────────────────────────────
# 🆕 EFECTOS
# ─────────────────────────────────────────
func apply_effects(target) -> Array[String]:
	var logs: Array[String] = []
	var remaining_effects: Array[Dictionary] = []

	for effect in target.effects:
		match effect["type"]:
			"bleed":
				target.take_damage(effect["value"])
				logs.append("🩸 Sangrado: -" + str(effect["value"]))

		effect["turns"] -= 1

		if effect["turns"] > 0:
			remaining_effects.append(effect)

	target.effects = remaining_effects

	return logs


# ─────────────────────────────────────────
# ATAQUES
# ─────────────────────────────────────────
func player_attack(player: Player, enemy: Enemy) -> Dictionary:
	var variation = int(player.damage * 0.2)
	var damage = player.damage + rng.randi_range(-variation, variation)
	damage = max(damage, 1)

	var is_crit = _is_critical()

	if is_crit:
		damage = int(damage * CRIT_MULTIPLIER)

	enemy.take_damage(damage)

	# 🆕 шанс de aplicar bleed
	if rng.randi_range(1, 100) <= 30:
		enemy.effects.append({
			"type": "bleed",
			"value": 3,
			"turns": 2
		})

	if is_crit:
		print("Jugador pega:", damage, "💥 CRIT!")
	else:
		print("Jugador pega:", damage)

	return {
		"damage": damage,
		"is_crit": is_crit
	}


func enemy_attack(player: Player, enemy: Enemy) -> Dictionary:
	var variation = int(enemy.damage * 0.2)
	var damage = enemy.damage + rng.randi_range(-variation, variation)
	damage = max(damage, 1)

	var is_crit = _is_critical()

	if is_crit:
		damage = int(damage * CRIT_MULTIPLIER)

	player.take_damage(damage)

	if is_crit:
		print("Enemigo pega:", damage, "💥 CRIT!")
	else:
		print("Enemigo pega:", damage)

	return {
		"damage": damage,
		"is_crit": is_crit
	}


func _is_critical() -> bool:
	return rng.randi_range(1, 100) <= CRIT_CHANCE