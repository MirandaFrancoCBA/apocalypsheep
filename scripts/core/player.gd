# scripts/core/player.gd
extends Resource
class_name Player

# ─────────────────────────────────────────
# STATS BASE
# ─────────────────────────────────────────
var hp: int = 1
var max_hp: int = 1
var damage: int = 1

# ─────────────────────────────────────────
# META
# ─────────────────────────────────────────
var level: int = 1
var xp: int = 0

# ─────────────────────────────────────────
# EQUIPO
# ─────────────────────────────────────────
var equipped_weapon: Dictionary = {}  # ⚠️ nunca null

# ─────────────────────────────────────────
# FACTORY
# ─────────────────────────────────────────
static func from_game_manager() -> Player:
	var data = GameManager.get_player_data()

	var p = Player.new()

	# 🧠 stats base
	p.hp     = data.get("hp", 1)
	p.max_hp = data.get("max_hp", p.hp)
	p.damage = data.get("damage", 1)

	# 📈 meta
	p.level  = data.get("level", 1)
	p.xp     = data.get("xp", 0)

	# 🗡️ equipo (evita null)
	var weapon = data.get("equipped_weapon")
	if weapon != null:
		p.equipped_weapon = weapon
		p.damage += weapon.get("damage", 0)
	else:
		p.equipped_weapon = {}

	return p

# ─────────────────────────────────────────
# UTILIDADES
# ─────────────────────────────────────────
func take_damage(amount: int) -> void:
	hp = max(hp - amount, 0)

func heal(amount: int) -> void:
	hp = min(hp + amount, max_hp)

func is_alive() -> bool:
	return hp > 0

func debug_string() -> String:
	return "[Player] HP: %s/%s | DMG: %s | LVL: %s" % [
		hp, max_hp, damage, level
	]