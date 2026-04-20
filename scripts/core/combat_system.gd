# scripts/core/combat_system.gd
extends Node
class_name CombatSystem

var rng = RandomNumberGenerator.new()

const CRIT_CHANCE = 20
const CRIT_MULTIPLIER = 2.0

func _init():
	rng.randomize()

# ─────────────────────────────────────────
# PLAYER ATTACK
# ─────────────────────────────────────────
func player_attack(player: Player, enemy: Enemy) -> Dictionary:
	var variation = int(player.damage * 0.2)
	var damage = player.damage + rng.randi_range(-variation, variation)
	damage = max(damage, 1)

	var is_crit = _is_critical()

	if is_crit:
		damage = int(damage * CRIT_MULTIPLIER)

	enemy.take_damage(damage)

	if is_crit:
		print("Jugador pega:", damage, "💥 CRIT!")
	else:
		print("Jugador pega:", damage)

	return {
		"damage": damage,
		"is_crit": is_crit
	}

# ─────────────────────────────────────────
# ENEMY ATTACK
# ─────────────────────────────────────────
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

# ─────────────────────────────────────────
# CRÍTICO
# ─────────────────────────────────────────
func _is_critical() -> bool:
	return rng.randi_range(1, 100) <= CRIT_CHANCE