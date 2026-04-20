# scripts/core/enemy.gd
extends Resource
class_name Enemy

var id: String = ""
var name: String = "Enemy"

var hp: int = 1
var max_hp: int = 1
var damage: int = 1

# ─────────────────────────────────────────
# FACTORY
# ─────────────────────────────────────────
static func from_dict(data: Dictionary) -> Enemy:
	var e = Enemy.new()

	e.id     = data.get("id", "")
	e.name   = data.get("name", "Enemy")

	e.hp     = data.get("hp", 10)
	e.max_hp = e.hp   # 🔥 clave para barras

	e.damage = data.get("damage", 1)

	return e

# ─────────────────────────────────────────
# UTILIDADES
# ─────────────────────────────────────────
func take_damage(amount: int) -> void:
	hp = max(hp - amount, 0)

func is_alive() -> bool:
	return hp > 0

func debug_string() -> String:
	return "[Enemy] %s HP: %s/%s | DMG: %s" % [
		name, hp, max_hp, damage
	]