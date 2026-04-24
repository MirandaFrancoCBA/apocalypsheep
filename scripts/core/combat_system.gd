extends Node
class_name CombatSystem

var rng = RandomNumberGenerator.new()

const CRIT_CHANCE = 20
const CRIT_MULTIPLIER = 2.0

func _init():
	rng.randomize()

# ─────────────────────────────────────────
# ATAQUE JUGADOR
# ─────────────────────────────────────────
func player_attack(player: Player, enemy: Enemy) -> Dictionary:
	if _is_stunned(player):
		return {"damage": 0, "is_crit": false, "skipped": true}

	var damage = _calculate_damage(player.damage)

	var is_crit = _is_critical()
	if is_crit:
		damage = int(damage * CRIT_MULTIPLIER)

	enemy.hp -= damage

	# 🔫 aplicar efecto del arma
	var weapon = player.equipped_weapon
	if weapon != null:
		_apply_weapon_effect(weapon, enemy)

	return {
		"damage": damage,
		"is_crit": is_crit
	}

# ─────────────────────────────────────────
# ATAQUE ENEMIGO
# ─────────────────────────────────────────
func enemy_attack(player: Player, enemy: Enemy) -> Dictionary:
	if _is_stunned(enemy):
		return {"damage": 0, "is_crit": false, "skipped": true}

	var damage = _calculate_damage(enemy.damage)

	var is_crit = _is_critical()
	if is_crit:
		damage = int(damage * CRIT_MULTIPLIER)

	player.take_damage(damage)

	return {
		"damage": damage,
		"is_crit": is_crit
	}

# ─────────────────────────────────────────
# EFECTOS POR TURNO (LO IMPORTANTE)
# ─────────────────────────────────────────
func apply_effects(target) -> Array[String]:
	var logs: Array[String] = []
	var new_effects: Array[Dictionary] = []

	for effect in target.effects:
		match effect["type"]:

			"bleed":
				target.hp -= effect["value"]
				logs.append("🩸 Sangrado -" + str(effect["value"]))

			"poison":
				target.hp -= effect["value"]
				logs.append("☠️ Veneno -" + str(effect["value"]))

			"burn":
				target.hp -= effect["value"]
				logs.append("🔥 Quemadura -" + str(effect["value"]))

			"stun":
				logs.append("💫 Aturdido")

		effect["duration"] -= 1

		if effect["duration"] > 0:
			new_effects.append(effect)

	target.effects = new_effects

	return logs

# ─────────────────────────────────────────
# APLICAR EFECTO DE ARMA
# ─────────────────────────────────────────
func _apply_weapon_effect(weapon: Dictionary, target) -> void:
	var effect_type = weapon.get("effect", null)

	if effect_type == null:
		return

	match effect_type:

		"bleed":
			_add_effect(target, "bleed", 3, 2)

		"poison":
			_add_effect(target, "poison", 4, 1)

		"burn":
			_add_effect(target, "burn", 2, 3)

		"stun":
			if rng.randi_range(1, 100) <= 25:
				_add_effect(target, "stun", 1, 0)

# ─────────────────────────────────────────
# ADD EFFECT (INTELIGENTE)
# ─────────────────────────────────────────
func _add_effect(target, type: String, duration: int, value: int):
	for e in target.effects:
		if e["type"] == type:
			# refresh o stack
			e["duration"] = max(e["duration"], duration)
			return

	target.effects.append({
		"type": type,
		"duration": duration,
		"value": value
	})

# ─────────────────────────────────────────
# UTILS
# ─────────────────────────────────────────
func _calculate_damage(base: int) -> int:
	var variation = int(base * 0.2)
	return max(base + rng.randi_range(-variation, variation), 1)

func _is_critical() -> bool:
	return rng.randi_range(1, 100) <= CRIT_CHANCE

func _is_stunned(entity) -> bool:
	for e in entity.effects:
		if e["type"] == "stun":
			return true
	return false