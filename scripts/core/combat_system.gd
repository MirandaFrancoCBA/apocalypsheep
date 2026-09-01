extends Node
class_name CombatSystem

var rng = RandomNumberGenerator.new()



func _init():
	rng.randomize()

# ─────────────────────────────────────────
# ATAQUE JUGADOR
# ─────────────────────────────────────────
func player_attack(player: Player, enemy: Enemy) -> Dictionary:

	if _consume_stun(player):
		return {
			"damage": 0,
			"is_crit": false,
			"skipped": true
		}

	var damage := _calculate_damage(player.damage)

	var is_crit := _is_critical()
	if is_crit:
		damage = int(damage * Constants.CRIT_MULTIPLIER)

	# 🛡️ aplicar defensa del enemigo
	damage = _apply_defense(enemy, damage)

	enemy.hp -= damage

	# 🔫 efecto del arma
	if player.equipped_weapon != null:
		_apply_weapon_effect(player.equipped_weapon, enemy)

	return {
		"damage": damage,
		"is_crit": is_crit,
		"skipped": false
	}

# ─────────────────────────────────────────
# ATAQUE ENEMIGO
# ─────────────────────────────────────────
func enemy_attack(player: Player, enemy: Enemy) -> Dictionary:

	if _consume_stun(enemy):
		return {
			"damage": 0,
			"is_crit": false,
			"skipped": true
		}

	var damage := _calculate_damage(enemy.damage)

	var is_crit := _is_critical()
	if is_crit:
		damage = int(damage * Constants.CRIT_MULTIPLIER)

	# 🛡️ aplicar defensa del jugador
	damage = _apply_defense(player, damage)

	player.take_damage(damage)

	_apply_enemy_effect(enemy, player)

	return {
	"damage": damage,
	"is_crit": is_crit,
	"skipped": false,
	"effect": enemy.effect
	}

# ─────────────────────────────────────────
# DEFENDER (clave para tu botón nuevo)
# ─────────────────────────────────────────
func defend(player: Player) -> Dictionary:

	if _consume_stun(player):
		return {
			"skipped": true
		}

	player.start_defense()

	return {
		"skipped": false
	}

# ─────────────────────────────────────────
# EFECTOS POR TURNO
# ─────────────────────────────────────────
func apply_effects(target) -> Array[String]:

	var logs: Array[String] = []
	var new_effects: Array[Dictionary] = []

	for effect in target.effects:

		# El stun no se consume aquí.
		# Se consume cuando la entidad intenta realizar su acción.
		if effect["type"] == "stun":
			new_effects.append(effect)
			continue

		match effect["type"]:

			"bleed":
				target.take_damage(effect["value"])
				logs.append("🩸 Sangrado -" + str(effect["value"]))

			"poison":
				target.take_damage(effect["value"])
				logs.append("☠️ Veneno -" + str(effect["value"]))

			"burn":
				target.take_damage(effect["value"])
				logs.append("🔥 Quemadura -" + str(effect["value"]))

		effect["duration"] -= 1

		if effect["duration"] > 0:
			new_effects.append(effect)

	target.effects = new_effects

	return logs

# ─────────────────────────────────────────
# EFECTOS DE ARMAS
# ─────────────────────────────────────────
func _apply_weapon_effect(
	weapon: Dictionary,
	target
) -> void:

	var effect_type = weapon.get("effect", null)

	if effect_type == null:
		return

	var chance = Constants.EFFECT_CHANCES.get(
		effect_type,
		0
	)

	if rng.randi_range(1, 100) > chance:
		return

	match effect_type:

		"bleed":
			_add_effect(
				target,
				"bleed",
				Constants.EFFECT_DURATIONS["bleed"],
				Constants.EFFECT_DAMAGE["bleed"]
			)

		"poison":
			_add_effect(
				target,
				"poison",
				Constants.EFFECT_DURATIONS["poison"],
				Constants.EFFECT_DAMAGE["poison"]
			)

		"burn":
			_add_effect(
				target,
				"burn",
				Constants.EFFECT_DURATIONS["burn"],
				Constants.EFFECT_DAMAGE["burn"]
			)

		"stun":
			_add_effect(
				target,
				"stun",
				Constants.EFFECT_DURATIONS["stun"],
				0
			)

func _apply_enemy_effect(enemy: Enemy, player: Player) -> void:

	if enemy.effect.is_empty():
		return

	var chance = Constants.EFFECT_CHANCES.get(
		enemy.effect,
		0
	)

	if rng.randi_range(1, 100) > chance:
		return

	match enemy.effect:

		"bleed":
			_add_effect(
				player,
				"bleed",
				Constants.EFFECT_DURATIONS["bleed"],
				Constants.EFFECT_DAMAGE["bleed"]
			)

		"poison":
			_add_effect(
				player,
				"poison",
				Constants.EFFECT_DURATIONS["poison"],
				Constants.EFFECT_DAMAGE["poison"]
			)

		"burn":
			_add_effect(
				player,
				"burn",
				Constants.EFFECT_DURATIONS["burn"],
				Constants.EFFECT_DAMAGE["burn"]
			)

		"stun":
			_add_effect(
				player,
				"stun",
				Constants.EFFECT_DURATIONS["stun"],
				0
			)
# ─────────────────────────────────────────
# ADD EFFECT (no stackea mal)
# ─────────────────────────────────────────
func _add_effect(target, type: String, duration: int, value: int) -> void:

	for e in target.effects:
		if e["type"] == type:
			e["duration"] = max(e["duration"], duration)
			return

	target.effects.append({
		"type": type,
		"duration": duration,
		"value": value
	})

# ─────────────────────────────────────────
# DEFENSE SYSTEM (LO IMPORTANTE)
# ─────────────────────────────────────────
func _apply_defense(target, damage: int) -> int:

	if target.is_defending:
		damage = int(damage * Constants.DEFENSE_MULTIPLIER)
		target.is_defending = false

	return max(damage, 0)

# ─────────────────────────────────────────
# UTILS
# ─────────────────────────────────────────
func _calculate_damage(base: int) -> int:
	var multiplier := rng.randf_range(
		Constants.DAMAGE_VARIATION_MIN,
		Constants.DAMAGE_VARIATION_MAX
	)

	return max(int(round(base * multiplier)), 1)

func _is_critical() -> bool:
	return rng.randf() <= Constants.CRIT_CHANCE

func _consume_stun(entity) -> bool:

	var new_effects: Array[Dictionary] = []
	var stunned := false

	for effect in entity.effects:

		if effect["type"] == "stun" and not stunned:
			stunned = true
			effect["duration"] -= 1

			if effect["duration"] > 0:
				new_effects.append(effect)

			continue

		new_effects.append(effect)

	entity.effects = new_effects

	return stunned
